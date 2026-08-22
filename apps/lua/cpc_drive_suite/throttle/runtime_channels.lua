return [====[
-- CPC Drive Suite 3.9.2 — Dedicated throttle/FOV/Z-motion logic
-- Owns throttle input shaping, cockpit FOV, fore/aft Z motion and throttle-driven linear effects.
-- Shared runtime values live in __CPC so UI/HUD/lifecycle modules can read telemetry.

return function(__CPC)
  -- Throttle camera runtime ----------------------------------------------------

  __CPC.originalFov = nil
  __CPC.baseSeat = nil
  -- First-cockpit-frame anchors. Both the normal throttle Z/FOV pair and the
  -- speed-forward Z/FOV pair are expressed relative to this captured pose so
  -- enabling the app never jumps the seat or FOV to one of its configured ends.
  __CPC.cameraStartReady = false
  __CPC.cameraStartThrottleBlend = 0
  __CPC.cameraStartFov = nil
  -- Snapshot the two configured FOV endpoints when the first cockpit pose is
  -- captured. They let the app preserve the real first-frame FOV with zero snap,
  -- while still making later Resting/Full slider edits absolute and live.
  __CPC.cameraStartRestingFov = nil
  __CPC.cameraStartMaximumFov = nil
  __CPC.cameraLiveStartFov = nil
  __CPC.cameraFovEndpointsLive = false
  __CPC.throttleWasEnabled = false
  __CPC.seatWasApplied = false
  __CPC.fovWasApplied = false
  __CPC.throttleResetCounter = nil
  __CPC.throttleInput, __CPC.steeringInput, __CPC.throttleEffectScale = 0, 0, 0
  __CPC.fovBlend, __CPC.forwardBlend, __CPC.renderedFovMix = 0, 0, 0
  __CPC.fovSpeedBlend = 0
  __CPC.fovMixPositionTarget, __CPC.fovMixAngleTarget = 0, 0
  __CPC.fovMixDynamicTarget, __CPC.fovMixSpeedTarget = 0, 0
  __CPC.renderedFov = __CPC.settings.throttleRestingFov
  __CPC.renderedForward, __CPC.renderedSpeedForward, __CPC.renderedSpeedForwardFov, __CPC.renderedVertical, __CPC.renderedLateral = 0, 0, 0, 0, 0
  __CPC.renderedPitch, __CPC.renderedYaw = 0, 0
  __CPC.renderedAccelGZ, __CPC.renderedBrakeDiveZ = 0, 0
  __CPC.renderedHeaveY, __CPC.renderedDriftX, __CPC.renderedImpactZ = 0, 0, 0
  __CPC.renderedGearAnticipation, __CPC.renderedCornerEntry, __CPC.renderedCornerExit = 0, 0, 0
  __CPC.filteredLongitudinalG, __CPC.dynamicVerticalG, __CPC.dynamicSlipAngle = 0, 0, 0
  __CPC.outputForward, __CPC.outputVertical, __CPC.outputLateral = 0, 0, 0
  __CPC.outputPitch, __CPC.outputYaw = 0, 0
  __CPC.throttleStatus = 'Waiting for cockpit view'

  function __CPC.shapedThrottle(value)
    value = __CPC.Math.saturate(value or 0)
    local deadzone = __CPC.Math.clamp(__CPC.settings.throttleDeadzone, 0, 0.50)
    if value <= deadzone then return 0 end
    local normalized = (value - deadzone) / math.max(1 - deadzone, 0.01)
    return math.pow(normalized, __CPC.Math.clamp(__CPC.settings.throttleCurve, 0.25, 3.0))
  end

  -- Signed, normalized travel away from the throttle value that was present
  -- when the first cockpit pose was captured. 0 is the exact starting pose,
  -- +1 is full throttle and -1 is fully released. This avoids discontinuities
  -- even if the app is enabled while the pedal is already part-way down.
  function __CPC.anchoredUnitTravel(value, startValue)
    value = __CPC.Math.clamp(value or 0, 0, 1)
    startValue = __CPC.Math.clamp(startValue or 0, 0, 1)
    if value >= startValue then
      return (value - startValue) / math.max(1 - startValue, 0.0001)
    end
    return -(startValue - value) / math.max(startValue, 0.0001)
  end

  function __CPC.normalizedMagnitude(value, amount)
    amount = math.abs(amount or 0)
    if amount < 0.0001 then return 0 end
    return __CPC.Math.saturate(math.abs(value or 0) / amount)
  end

  function __CPC.limitedFovSource(input, mix, limit, strength)
    limit = math.max(math.abs(limit or 0), 0)
    return __CPC.Math.clamp((input or 0) * (mix or 0) * (strength or 1), -limit, limit)
  end

  -- Absolute safety range for every FOV computation below, user-tunable instead
  -- of a fixed constant so VR/triple-screen setups can widen or narrow it.
  function __CPC.fovHardBounds()
    local minimum = __CPC.Math.clamp(__CPC.settings.throttleFovHardMin, 10, 170)
    local maximum = __CPC.Math.clamp(__CPC.settings.throttleFovHardMax, minimum + 1, 179)
    return minimum, maximum
  end

  -- Advanced linear translation engine -----------------------------------------
  -- Every linear (translation) effect is described once in LINEAR_CHANNELS and
  -- driven by one generic evaluator, so each channel gets the same advanced
  -- controls: input curve, split attack/release, road-speed gate with its own
  -- curve, hard output clamp, optional vibration oscillator and FOV routing.

  __CPC.SMOOTHING_NAMES = { 'EXPONENTIAL', 'CRITICAL DAMP' }

  __CPC.linearState = {}
  __CPC.linearRuntime = {
    fovMix = 0,
    rumbleBaseline = 1.0,
    steerSample = 0,
    gear = 0,
    shiftPulse = 0,
    throttleInput = 0
  }
  __CPC.linearAxis = { x = 0, y = 0, z = 0 }
  __CPC.linearFrame = {
    longG = 0, rawLongG = 0, impactG = 0, latG = 0, vertG = 0, rumbleG = 0,
    speedKmh = 0, slipAngle = 0, yawRate = 0, steerRate = 0, rpm = 0,
    rpmRatio = 0, boost = 0, tyreSlip = 0, absActivity = 0, shiftPulse = 0
  }

  function __CPC.channelKeys(base, override)
    local keys = {
      enabled = 'throttle' .. base .. 'Enabled',
      distance = 'throttle' .. base .. 'Distance',
      reverse = 'throttle' .. base .. 'Reverse',
      atFull = 'throttle' .. base .. 'AtFull',
      speed = 'throttle' .. base .. 'Speed',
      releaseSpeed = 'throttle' .. base .. 'ReleaseSpeed',
      curve = 'throttle' .. base .. 'Curve',
      limit = 'throttle' .. base .. 'Limit',
      gateStart = 'throttle' .. base .. 'GateStart',
      gateFull = 'throttle' .. base .. 'GateFull',
      gateCurve = 'throttle' .. base .. 'GateCurve',
      frequency = 'throttle' .. base .. 'Frequency',
      fovMix = 'throttleFov' .. base .. 'Mix',
      fovLimit = 'throttleFov' .. base .. 'Limit'
    }
    if override then
      for name, key in pairs(override) do keys[name] = key end
    end
    return keys
  end

  function __CPC.makeChannel(spec)
    spec.keys = __CPC.channelKeys(spec.base, spec.override)
    spec.distRange = spec.distRange or 0.10
    spec.atFullMin = spec.atFullMin or 0.05
    spec.atFullMax = spec.atFullMax or 6.0
    spec.unit = spec.unit or ''
    __CPC.linearState[spec.base] = {
      value = 0, target = 0, amp = 0, phase = 0, vel = 0, norm = 0
    }
    return spec
  end

  __CPC.LINEAR_CHANNELS = {
    __CPC.makeChannel{ base = 'AccelG', axis = 'z', group = 1, unit = 'G',
      label = 'Acceleration G surge', distRange = 0.30, atFullMax = 6.0,
      hint = 'Forward thrust pushes the head along Z. Honours the shift filter.',
      source = function(f) return math.max(f.longG, 0) end },

    __CPC.makeChannel{ base = 'BrakeDive', axis = 'z', group = 1, unit = 'G',
      label = 'Brake dive', distRange = 0.30, atFullMax = 6.0,
      override = { fovMix = 'throttleFovBrakeGMix', fovLimit = 'throttleFovBrakeGLimit' },
      hint = 'Deceleration throws the head toward the windscreen.',
      source = function(f) return math.max(-f.longG, 0) end },

    __CPC.makeChannel{ base = 'CornerG', axis = 'x', group = 1, unit = 'G',
      label = 'Cornering G sway', distRange = 0.20, atFullMax = 5.0,
      signed = true, extended = true,
      hint = 'Lateral acceleration slides the head sideways in the cockpit.',
      source = function(f) return f.latG end },

    __CPC.makeChannel{ base = 'Heave', axis = 'y', group = 2, unit = 'G',
      label = 'Suspension heave', distRange = 0.20, atFullMax = 6.0,
      signed = true,
      hint = 'Vertical load lifts or drops the head over crests and compressions.',
      source = function(f) return f.vertG end },

    __CPC.makeChannel{ base = 'Downforce', axis = 'y', group = 2, unit = 'km/h',
      label = 'Downforce squat', distRange = 0.15, atFullMin = 20, atFullMax = 400,
      extended = true,
      hint = 'Aero load presses the whole cockpit down as speed builds.',
      source = function(f) return f.speedKmh end },

    __CPC.makeChannel{ base = 'RoadRumble', axis = 'y', group = 2, unit = 'G',
      label = 'Road rumble', distRange = 0.05, atFullMin = 0.05, atFullMax = 3.0,
      extended = true, oscillator = true,
      hint = 'High-passed vertical load becomes a fine vertical vibration.',
      source = function(f) return math.abs(f.rumbleG) end },

    __CPC.makeChannel{ base = 'DriftTranslation', axis = 'x', group = 3, unit = 'deg',
      label = 'Drift slide translation', distRange = 0.30,
      atFullMin = 1, atFullMax = 60, signed = true,
]====]
