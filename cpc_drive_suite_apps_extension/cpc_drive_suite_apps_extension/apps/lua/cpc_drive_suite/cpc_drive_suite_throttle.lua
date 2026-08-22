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
      override = { atFull = 'throttleDriftAngleAtFull',
        fovMix = 'throttleFovDriftMix', fovLimit = 'throttleFovDriftLimit' },
      hint = 'Chassis slip angle offsets the head across the cockpit.',
      source = function(f) return f.slipAngle end },

    __CPC.makeChannel{ base = 'SteerKick', axis = 'x', group = 3, unit = 'turn/s',
      label = 'Steering-rate kick', distRange = 0.15,
      atFullMin = 0.1, atFullMax = 6.0, signed = true, extended = true,
      hint = 'Fast wheel inputs snap the head sideways, then settle.',
      source = function(f) return f.steerRate end },

    __CPC.makeChannel{ base = 'YawSway', axis = 'x', group = 3, unit = 'rad/s',
      label = 'Yaw-rate sway', distRange = 0.15,
      atFullMin = 0.05, atFullMax = 4.0, signed = true, extended = true,
      hint = 'Rotation rate of the car itself, independent of steering input.',
      source = function(f) return f.yawRate end },

    __CPC.makeChannel{ base = 'SpeedDraw', axis = 'z', group = 4, unit = 'km/h',
      label = 'High-speed drawback', distRange = 0.30,
      atFullMin = 20, atFullMax = 500, extended = true,
      hint = 'Pure road speed pulls the seat back for a longer sightline.',
      source = function(f) return f.speedKmh end },

    __CPC.makeChannel{ base = 'Boost', axis = 'z', group = 4, unit = 'bar',
      label = 'Turbo boost surge', distRange = 0.15,
      atFullMin = 0.05, atFullMax = 5.0, extended = true,
      hint = 'Turbo pressure adds its own shove on top of measured G.',
      source = function(f) return f.boost end },

    __CPC.makeChannel{ base = 'RPMShake', axis = 'y', group = 4, unit = 'ratio',
      label = 'Engine shake', distRange = 0.02,
      atFullMin = 0.05, atFullMax = 1.0, extended = true, oscillator = true,
      hint = 'Engine speed drives a vibration whose frequency tracks the revs.',
      frequency = function(f)
        return f.rpm / 1000 * math.max(__CPC.settings.throttleRPMShakeFrequency, 0)
      end,
      source = function(f) return f.rpmRatio end },

    __CPC.makeChannel{ base = 'Impact', axis = 'z', group = 5, unit = 'G',
      label = 'Impact recoil', distRange = 0.20, atFullMin = 0.5, atFullMax = 10.0,
      signed = true,
      override = { releaseSpeed = 'throttleImpactRecoverySpeed',
        atFull = 'throttleImpactGThreshold' },
      hint = 'Fires only above the trigger threshold, then recovers.',
      source = function(f)
        local trigger = math.max(__CPC.settings.throttleImpactGThreshold, 0.1)
        if math.abs(f.impactG) >= trigger then return -f.impactG end
        return 0
      end },

    __CPC.makeChannel{ base = 'ShiftJolt', axis = 'z', group = 5, unit = 'pulse',
      label = 'Gear-shift jolt (disabled)', distRange = 0.15,
      atFullMin = 0.1, atFullMax = 3.0, signed = true, extended = true,
      hint = 'Disabled in 3.9.1: gear changes no longer create any Z-force camera pulse.',
      source = function(f) return f.shiftPulse end },

    __CPC.makeChannel{ base = 'SlipJudder', axis = 'y', group = 5, unit = 'slip',
      label = 'Wheel-slip judder', distRange = 0.05,
      atFullMin = 0.05, atFullMax = 4.0, extended = true, oscillator = true,
      hint = 'Excess tyre slip beyond peak grip becomes a vertical judder.',
      source = function(f) return f.tyreSlip end },

    __CPC.makeChannel{ base = 'BrakePulse', axis = 'z', group = 5, unit = 'slip',
      label = 'Brake-lock pulse', distRange = 0.05,
      atFullMin = 0.05, atFullMax = 4.0, extended = true, oscillator = true,
      hint = 'Locking or ABS activity under braking pulses the head along Z.',
      source = function(f) return f.absActivity end }
  }

  __CPC.LINEAR_GROUPS = {
    'G-FORCE', 'CHASSIS', 'ROTATION', 'SPEED', 'IMPULSE'
  }

  function __CPC.linearValue(base)
    local state = __CPC.linearState[base]
    return state and state.value or 0
  end

  function __CPC.axisLimitValue(key)
    local limit = math.abs(__CPC.settings[key] or 0)
    if limit <= 0 then return 1e9 end
    return limit
  end

  function __CPC.shapeCurve(value, curve)
    curve = __CPC.Math.clamp(curve or 1, 0.20, 4.0)
    if curve == 1 then return value end
    local sign = value < 0 and -1 or 1
    return sign * math.pow(math.abs(value), curve)
  end

  function __CPC.shapeBlend(value, curveKey)
    return __CPC.shapeCurve(value, __CPC.settings[curveKey])
  end

  function __CPC.channelSpeed(attackKey, releaseKey, rising, overall)
    local attack = math.max(__CPC.Math.finiteNumber(__CPC.settings[attackKey], 8), 0.05)
    local release = __CPC.Math.finiteNumber(__CPC.settings[releaseKey], 0)
    if release <= 0 then release = attack end
    return (rising and attack or release) * math.max(__CPC.Math.finiteNumber(overall, 1), 0.01)
  end

  function __CPC.advanceBase(current, target, attackKey, releaseKey, limitKey, overall, dt)
    local rising = math.abs(target) >= math.abs(current)
    local result = __CPC.Math.expSmooth(current, target,
      __CPC.channelSpeed(attackKey, releaseKey, rising, overall), dt)
    local limit = math.abs(__CPC.settings[limitKey] or 0)
    if limit > 0 then result = __CPC.Math.clamp(result, -limit, limit) end
    return result
  end

  function __CPC.smoothLinear(state, target, speed, dt)
    speed = math.max(__CPC.Math.finiteNumber(speed, 0.02), 0.02)
    dt = math.max(__CPC.Math.finiteNumber(dt, 0), 0)
    if math.floor(__CPC.settings.throttleSmoothingMode + 0.5) == 2 then
      local offset = state.value - target
      local decay = math.exp(-speed * dt)
      local step = (state.vel + speed * offset) * dt
      state.vel = (state.vel - speed * step) * decay
      return target + (offset + step) * decay
    end
    state.vel = 0
    return __CPC.Math.expSmooth(state.value, target, speed, dt)
  end

  function __CPC.channelGate(channel, frame)
    local keys = channel.keys
    local startKmh = math.max(__CPC.settings[keys.gateStart] or 0, 0)
    local fullKmh = math.max(__CPC.settings[keys.gateFull] or (startKmh + 1), startKmh + 1)
    local gate = __CPC.Math.saturate((frame.speedKmh - startKmh) / (fullKmh - startKmh))
    return __CPC.shapeCurve(gate, __CPC.settings[keys.gateCurve])
  end

  function __CPC.updateLinearChannel(channel, frame, dt, overall, masterOn)
    local keys, state = channel.keys, __CPC.linearState[channel.base]
    local active = masterOn and __CPC.settings[keys.enabled] ~= false
    local raw = active and (channel.source(frame) or 0) or 0
    local atFull = math.max(math.abs(__CPC.settings[keys.atFull] or 1), 0.0001)
    local floor = channel.signed and -1 or 0
    local normalized = __CPC.Math.clamp(raw / atFull, floor, 1)
    local shaped = __CPC.shapeCurve(normalized, __CPC.settings[keys.curve])
    if active then shaped = shaped * __CPC.channelGate(channel, frame) else shaped = 0 end
    state.norm = shaped

    local distance = __CPC.directedMovement(__CPC.settings[keys.distance] or 0, keys.reverse)
      * math.max(__CPC.settings.throttleLinearMasterScale, 0)

    if channel.oscillator then
      local amplitude = math.abs(shaped)
      local rising = amplitude >= state.amp
      state.amp = __CPC.Math.expSmooth(state.amp, amplitude,
        __CPC.channelSpeed(keys.speed, keys.releaseSpeed, rising, overall), dt)
      local hertz = channel.frequency and channel.frequency(frame)
        or math.max(__CPC.settings[keys.frequency] or 10, 0)
      state.phase = (state.phase + math.max(hertz, 0) * dt) % 1
      state.target = state.amp * distance
      state.value = state.target * math.sin(state.phase * math.pi * 2)
    else
      local target = shaped * distance
      local rising = math.abs(target) >= math.abs(state.value)
      state.target = target
      state.value = __CPC.smoothLinear(state, target,
        __CPC.channelSpeed(keys.speed, keys.releaseSpeed, rising, overall), dt)
    end

    local limit = math.abs(__CPC.settings[keys.limit] or 0)
    if limit > 0 then state.value = __CPC.Math.clamp(state.value, -limit, limit) end
    return state.value
  end

  function __CPC.updateLinearFrame(dt, car, filterDynamicG)
    local frame = __CPC.linearFrame
    local accel = car.acceleration
    frame.rawLongG = -__CPC.Math.finiteNumber(accel and accel.z, 0)
    frame.latG = __CPC.Math.finiteNumber(accel and accel.x, 0)
    frame.vertG = __CPC.Math.finiteNumber(accel and accel.y, 0)
    if not filterDynamicG then frame.longG = frame.rawLongG end
    frame.impactG = filterDynamicG and 0 or frame.rawLongG
    frame.speedKmh = math.abs(__CPC.Math.finiteNumber(car.speedKmh, 0))

    local sliding = __CPC.Math.finiteNumber(car.localVelocity and car.localVelocity.x, 0)
      / math.max(3, math.abs(__CPC.Math.finiteNumber(car.speedMs, 0)))
    frame.slipAngle = math.deg(math.atan(sliding))
    frame.yawRate = __CPC.Math.finiteNumber(car.localAngularVelocity and car.localAngularVelocity.y, 0)

    local steerNow = __CPC.Math.finiteNumber(car.steer, 0)
    if __CPC.linearRuntime.steerSample == nil then __CPC.linearRuntime.steerSample = steerNow end
    frame.steerRate = (steerNow - __CPC.linearRuntime.steerSample) / math.max(dt, 0.001) / 360
    __CPC.linearRuntime.steerSample = steerNow

    frame.rpm = __CPC.Math.finiteNumber(car.rpm, 0)
    local _, limiter = __CPC.rpmBounds(car)
    frame.rpmRatio = __CPC.Math.saturate(frame.rpm / math.max(limiter, 1000))
    frame.boost = math.max(__CPC.Math.finiteNumber(car.turboBoost, 0), 0)

    local slip = 0
    if car.wheels then
      for index = 0, 3 do
        local wheel = car.wheels[index]
        if wheel then slip = math.max(slip, math.abs(__CPC.Math.finiteNumber(wheel.ndSlip, 0))) end
      end
    end
    frame.tyreSlip = math.max(slip - 1, 0)
    frame.absActivity = __CPC.Math.finiteNumber(car.brake, 0) > 0.15 and frame.tyreSlip or 0

    __CPC.linearRuntime.rumbleBaseline = __CPC.Math.expSmooth(__CPC.linearRuntime.rumbleBaseline, frame.vertG, 2.5, dt)
    frame.rumbleG = frame.vertG - __CPC.linearRuntime.rumbleBaseline

    local gear = car.gear or 0
    if __CPC.linearRuntime.gear == nil then __CPC.linearRuntime.gear = gear end
    if gear ~= __CPC.linearRuntime.gear then
      __CPC.linearRuntime.shiftPulse = gear > __CPC.linearRuntime.gear and 1 or -1
      __CPC.linearRuntime.gear = gear
    end
    __CPC.linearRuntime.shiftPulse = __CPC.linearRuntime.shiftPulse - __CPC.linearRuntime.shiftPulse * math.min(dt * 6, 1)
    frame.shiftPulse = __CPC.linearRuntime.shiftPulse
  end

  function __CPC.resetLinearEngine()
    for _, state in pairs(__CPC.linearState) do
      state.value, state.target, state.amp = 0, 0, 0
      state.phase, state.vel, state.norm = 0, 0, 0
    end
    __CPC.linearAxis.x, __CPC.linearAxis.y, __CPC.linearAxis.z = 0, 0, 0
    __CPC.linearRuntime.fovMix = 0
    __CPC.linearRuntime.rumbleBaseline = 0
    __CPC.linearRuntime.steerSample = nil
    __CPC.linearRuntime.gear = nil
    __CPC.linearRuntime.shiftPulse = 0
    __CPC.linearRuntime.throttleInput = 0
    for key in pairs(__CPC.linearFrame) do __CPC.linearFrame[key] = 0 end
  end

  function __CPC.copySeat(params)
    if not params or not params.position then return nil end
    return {
      position = vec3(params.position.x, params.position.y, params.position.z),
      pitch = params.pitch or 0,
      yaw = params.yaw or 0
    }
  end

  function __CPC.captureBaseSeat()
    if __CPC.baseSeat then return true end
    __CPC.baseSeat = __CPC.copySeat(ac.getOnboardCameraParams(__CPC.PLAYER))
    return __CPC.baseSeat ~= nil
  end

  function __CPC.resetThrottleMotion()
    __CPC.throttleInput, __CPC.steeringInput, __CPC.throttleEffectScale = 0, 0, 0
    __CPC.cameraStartReady = false
    __CPC.cameraStartThrottleBlend = 0
    __CPC.cameraStartFov = nil
    __CPC.cameraStartRestingFov = nil
    __CPC.cameraStartMaximumFov = nil
    __CPC.cameraLiveStartFov = nil
    __CPC.cameraFovEndpointsLive = false
    __CPC.fovBlend, __CPC.forwardBlend, __CPC.renderedFovMix = 0, 0, 0
    __CPC.fovSpeedBlend = 0
    __CPC.fovMixPositionTarget, __CPC.fovMixAngleTarget = 0, 0
    __CPC.fovMixDynamicTarget, __CPC.fovMixSpeedTarget = 0, 0
    local resetFovMin, resetFovMax = __CPC.fovHardBounds()
    __CPC.renderedFov = __CPC.Math.clamp(__CPC.settings.throttleRestingFov, resetFovMin, resetFovMax)
    __CPC.renderedForward, __CPC.renderedSpeedForward, __CPC.renderedVertical, __CPC.renderedLateral = 0, 0, 0, 0
    __CPC.renderedPitch, __CPC.renderedYaw = 0, 0
    __CPC.renderedAccelGZ, __CPC.renderedBrakeDiveZ = 0, 0
    __CPC.renderedHeaveY, __CPC.renderedDriftX, __CPC.renderedImpactZ = 0, 0, 0
    __CPC.renderedGearAnticipation, __CPC.renderedCornerEntry, __CPC.renderedCornerExit = 0, 0, 0
    __CPC.filteredLongitudinalG, __CPC.dynamicVerticalG, __CPC.dynamicSlipAngle = 0, 0, 0
    __CPC.outputForward, __CPC.outputVertical, __CPC.outputLateral = 0, 0, 0
    __CPC.outputPitch, __CPC.outputYaw = 0, 0
    __CPC.gearIsolationHeldThrottle, __CPC.gearIsolationLastThrottle = 0, 0
    __CPC.speedForwardBaselineKmh = 0
    __CPC.speedForwardBaselineReady = false
    __CPC.speedForwardResetRequested = false
    __CPC.speedForwardReverseRemaining = 0
    __CPC.speedForwardThrottleReleased = nil
    __CPC.renderedSpeedForwardFov = 0
    __CPC.resetLinearEngine()
  end

  function __CPC.restoreThrottleOutputs()
    if __CPC.originalFov and __CPC.fovWasApplied then ac.setFirstPersonCameraFOV(__CPC.originalFov) end
    if __CPC.baseSeat and __CPC.seatWasApplied then
      ac.setOnboardCameraParams(__CPC.PLAYER,
        ac.SeatParams(__CPC.baseSeat.position, __CPC.baseSeat.pitch, __CPC.baseSeat.yaw), false)
    end
    __CPC.fovWasApplied, __CPC.seatWasApplied = false, false
  end

  function __CPC.resetThrottleCameraSession()
    __CPC.restoreThrottleOutputs()
    __CPC.originalFov, __CPC.baseSeat = nil, nil
    __CPC.throttleResetCounter = nil
    __CPC.resetThrottleMotion()
  end

  function __CPC.applyCameraPose(forward, lateral, vertical, pitch, yaw)
    if not __CPC.captureBaseSeat() then return end
    local position = vec3(
      __CPC.baseSeat.position.x + __CPC.Math.finiteNumber(__CPC.settings.throttleStartX, 0) + lateral,
      __CPC.baseSeat.position.y + __CPC.Math.finiteNumber(__CPC.settings.throttleStartY, 0) + vertical,
      __CPC.baseSeat.position.z + __CPC.Math.finiteNumber(__CPC.settings.throttleStartZ, 0) + forward)
    ac.setOnboardCameraParams(__CPC.PLAYER,
      ac.SeatParams(position,
        __CPC.baseSeat.pitch + __CPC.Math.finiteNumber(__CPC.settings.throttleStartPitch, 0) + pitch,
        __CPC.baseSeat.yaw + yaw), false)
    __CPC.seatWasApplied = true
  end

  function __CPC.updateThrottleCamera(dt, car)
    local shouldEnable = __CPC.settings.suiteEnabled and __CPC.settings.throttleEnabled
    if not shouldEnable then
      if __CPC.throttleWasEnabled then
        __CPC.resetThrottleCameraSession()
      end
      __CPC.throttleWasEnabled = false
      __CPC.throttleStatus = __CPC.settings.suiteEnabled and 'Throttle camera disabled' or 'Suite paused'
      return
    end

    if not __CPC.throttleWasEnabled then
      __CPC.originalFov = __CPC.Math.finiteNumber(__CPC.sim.firstPersonCameraFOV, __CPC.settings.throttleRestingFov)
      __CPC.baseSeat = nil
      __CPC.throttleResetCounter = car and car.resetCounter or nil
      __CPC.resetThrottleMotion()
      __CPC.throttleWasEnabled = true
    end

    local inCockpit = __CPC.sim.cameraMode == ac.CameraMode.Cockpit and __CPC.sim.focusedCar == __CPC.PLAYER
    if not inCockpit then
      __CPC.resetThrottleCameraSession()
      __CPC.throttleStatus = 'Waiting for player cockpit view'
      return
    end
    if not car then
      __CPC.resetThrottleCameraSession()
      __CPC.throttleStatus = 'Waiting for player car'
      return
    end
    if __CPC.throttleResetCounter ~= nil and car.resetCounter ~= __CPC.throttleResetCounter then
      __CPC.resetThrottleCameraSession()
    end
    __CPC.throttleResetCounter = car.resetCounter
    if not __CPC.captureBaseSeat() then
      __CPC.throttleStatus = 'Seat API unavailable'
      return
    end

    -- Use the driver's raw accelerator pedal, not car.gas. car.gas can be cut by
    -- the gearbox/auto-blip during a shift, which must never look like a throttle
    -- release to the Z/FOV/Y camera logic.
    local pedalControls = physics and physics.getCarInputControls
      and physics.getCarInputControls() or nil
    local driverGas = pedalControls and (pedalControls.gas or 0) or (car.gas or 0)
    local rawThrottleInput = __CPC.shapedThrottle(driverGas)
    -- Base Z and base FOV are driven only by the real accelerator pedal. Using
    -- physics input here makes transmission throttle cuts/auto-blips irrelevant:
    -- gear changes cannot move Z or alter FOV, but a genuine pedal release can.
    local baseThrottleTarget = rawThrottleInput
    local fovThrottleTarget = rawThrottleInput
    __CPC.throttleInput = baseThrottleTarget
    __CPC.gearIsolationLastThrottle = baseThrottleTarget
    __CPC.steeringInput = __CPC.Math.clamp((car.steer or 0) /
      math.max(__CPC.settings.throttleSteeringAtFull, 30), -1, 1)
    local capKmh = math.max(__CPC.settings.throttleEffectSpeedCap, 1)
    local floorKmh = math.max(__CPC.settings.throttleEffectSpeedFloor, 0)
    if __CPC.settings.throttleEffectSpeedCapMph then
      capKmh = capKmh * 1.609344
      floorKmh = floorKmh * 1.609344
    end
    capKmh = math.max(capKmh, floorKmh + 1)
    __CPC.throttleEffectScale = __CPC.shapeCurve(
      __CPC.Math.saturate((math.abs(car.speedKmh or 0) - floorKmh) / (capKmh - floorKmh)),
      __CPC.settings.throttleSpeedGateCurve)
    local overall = __CPC.Math.clamp(__CPC.settings.throttleOverallSpeed, 0.1, 3.0)

    -- Keep the advanced 3.5 input filter for the non-base channels. The base FOV
    -- and fore/aft camera use the direct gear-filtered throttle target so the five
    -- sync controls remain authoritative.
    local inputAttack = math.max(__CPC.settings.throttleInputAttackSpeed, 0)
    local inputRelease = math.max(__CPC.settings.throttleInputReleaseSpeed, 0)
    if inputAttack > 0 or inputRelease > 0 then
      local rising = __CPC.throttleInput >= __CPC.linearRuntime.throttleInput
      local inputSpeed = rising and (inputAttack > 0 and inputAttack or 60)
        or (inputRelease > 0 and inputRelease or 60)
      __CPC.linearRuntime.throttleInput = __CPC.Math.expSmooth(__CPC.linearRuntime.throttleInput, __CPC.throttleInput,
        inputSpeed * overall, dt)
      __CPC.throttleInput = __CPC.linearRuntime.throttleInput
    else
      __CPC.linearRuntime.throttleInput = __CPC.throttleInput
    end

    -- Base Z and FOV normally share the same throttle geometry, but FOV uses a
    -- shift-proof blend during gear changes. The first valid cockpit frame is the mathematical origin. If the app starts
    -- at 37% throttle, for example, 37% is Z=0 and FOV=startFov; travelling from
    -- there to 100% interpolates exactly to +forwardDistance/fullFov, while
    -- travelling to 0% interpolates exactly to -backDistance/restingFov.
    --
    -- The initial real FOV is preserved so enabling the app cannot snap. As soon
    -- as either endpoint slider is edited, the start FOV is smoothly re-solved
    -- from those live endpoints at the captured start throttle. That makes the
    -- Resting and Full sliders truly adjustable even when the app was enabled at
    -- 0% or 100% throttle.
    local transitionSpeed = math.max(__CPC.settings.throttleTransitionSpeed or 12, 0.20) * overall
    local fovTransitionSpeed = math.max(__CPC.settings.throttleFovTransitionSpeed or 12, 0.20) * overall
    local fovMin, fovMax = __CPC.fovHardBounds()
    if not __CPC.cameraStartReady then
      __CPC.cameraStartThrottleBlend = __CPC.Math.clamp(fovThrottleTarget, 0, 1)
      __CPC.cameraStartFov = __CPC.Math.clamp(__CPC.originalFov or __CPC.sim.firstPersonCameraFOV
        or __CPC.settings.throttleRestingFov, fovMin, fovMax)
      __CPC.cameraStartRestingFov = __CPC.Math.clamp(__CPC.settings.throttleRestingFov, fovMin, fovMax)
      __CPC.cameraStartMaximumFov = __CPC.Math.clamp(math.max(__CPC.settings.throttleMaximumFov,
        __CPC.cameraStartRestingFov), fovMin, fovMax)
      __CPC.cameraLiveStartFov = __CPC.cameraStartFov
      __CPC.cameraFovEndpointsLive = false
      __CPC.fovBlend = __CPC.cameraStartThrottleBlend
      __CPC.forwardBlend = __CPC.Math.clamp(baseThrottleTarget, 0, 1)
      __CPC.cameraStartReady = true
    else
      -- Z keeps its existing throttle/gear-filter behavior. FOV follows a separate
      -- shift-proof blend with its own response speed, so the transmission can
      -- kick the camera without changing the lens state. Outside a shift both
      -- targets are identical.
      __CPC.fovBlend = __CPC.Math.expSmooth(__CPC.fovBlend, fovThrottleTarget, fovTransitionSpeed, dt)
      __CPC.forwardBlend = __CPC.Math.expSmooth(__CPC.forwardBlend, baseThrottleTarget, transitionSpeed, dt)
    end

    local syncBlend = __CPC.Math.clamp(__CPC.forwardBlend, 0, 1)
    local startTravel = __CPC.anchoredUnitTravel(syncBlend, __CPC.cameraStartThrottleBlend)
    local fovSyncBlend = __CPC.Math.clamp(__CPC.fovBlend, 0, 1)
    local fovStartTravel = __CPC.anchoredUnitTravel(fovSyncBlend, __CPC.cameraStartThrottleBlend)
    local forwardDistance = __CPC.Math.clamp(__CPC.settings.throttleForwardDistance or 0, 0, 1.00)
    local backDistance = __CPC.Math.clamp(__CPC.settings.throttleBackDistance or 0, 0, 1.00)
    local syncedDistance = startTravel >= 0
      and forwardDistance * startTravel
      or backDistance * startTravel
    __CPC.renderedForward = __CPC.directedMovement(syncedDistance, 'throttleForwardReverse')

    local forwardLimit = math.abs(__CPC.settings.throttleForwardLimit)
    if forwardLimit > 0 then
      __CPC.renderedForward = __CPC.Math.clamp(__CPC.renderedForward, -forwardLimit, forwardLimit)
    end

    -- Vehicle-speed layer. One absolute vehicle-speed curve drives BOTH the
    -- additional forward Z movement and the additional FOV widening. The layer
    -- builds with a deliberately slower response than the direct throttle layer.
    -- A real accelerator release gates both speed outputs to zero; because the
    -- base FOV target simultaneously goes to throttle=0, the lens returns cleanly
    -- to the user-adjustable Resting FOV. Gear changes and handbrake are ignored.
    if __CPC.settings.throttleSpeedForwardEnabled then
      local currentSpeedKmh = math.abs(car.speedKmh or 0)
      local throttlePedalReleased = rawThrottleInput <= 0.01
      local speedForwardDistance = __CPC.Math.clamp(__CPC.settings.throttleSpeedForwardDistance or 0, 0, 1.00)
      local speedFovWiden = __CPC.Math.clamp(__CPC.settings.throttleSpeedFovWiden or 0, 0, 80)
      local speedStart = math.max(__CPC.settings.throttleSpeedForwardStartKmh or 0, 0)
      local speedFull = math.max(__CPC.settings.throttleSpeedForwardFullKmh or 180, speedStart + 1)
      local speedLinear = __CPC.Math.saturate((currentSpeedKmh - speedStart) / (speedFull - speedStart))
      local speedCurve = __CPC.Math.clamp(__CPC.settings.throttleSpeedForwardCurve or 1.0, 0.20, 4.0)
      local speedBlend = math.pow(speedLinear, speedCurve)

      -- Proportional pedal gate keeps the speed layer continuous at tiny throttle
      -- values and guarantees exactly zero contribution when the pedal is released.
      local pedalGate = throttlePedalReleased and 0 or __CPC.Math.saturate(rawThrottleInput)
      local speedForwardTarget = speedForwardDistance * speedBlend * pedalGate
      local speedFovTarget = speedFovWiden * speedBlend * pedalGate
      local speedLayerResponse = math.max(__CPC.settings.throttleSpeedLayerSpeed or 2.5, 0.10) * overall

      if throttlePedalReleased then
        -- Release with the normal throttle response so Resting FOV is reached
        -- promptly; only the build-up with road speed is intentionally slow.
        __CPC.renderedSpeedForward = __CPC.Math.expSmooth(__CPC.renderedSpeedForward, 0, transitionSpeed, dt)
        __CPC.renderedSpeedForwardFov = __CPC.Math.expSmooth(__CPC.renderedSpeedForwardFov, 0, transitionSpeed, dt)
      else
        __CPC.renderedSpeedForward = __CPC.Math.expSmooth(__CPC.renderedSpeedForward, speedForwardTarget,
          speedLayerResponse, dt)
        __CPC.renderedSpeedForwardFov = __CPC.Math.expSmooth(__CPC.renderedSpeedForwardFov, speedFovTarget,
          speedLayerResponse, dt)
      end

      -- Legacy reset/pulse state is deliberately neutralized. It remains declared
      -- for save/runtime compatibility but can no longer be triggered by gears,
      -- handbrake or throttle release.
      __CPC.speedForwardBaselineKmh = currentSpeedKmh
      __CPC.speedForwardBaselineReady = true
      __CPC.speedForwardResetRequested = false
      __CPC.speedForwardReverseRemaining = 0
      __CPC.speedForwardThrottleReleased = throttlePedalReleased
    else
      __CPC.renderedSpeedForward = __CPC.Math.expSmooth(__CPC.renderedSpeedForward, 0, transitionSpeed, dt)
      __CPC.renderedSpeedForwardFov = __CPC.Math.expSmooth(__CPC.renderedSpeedForwardFov, 0, transitionSpeed, dt)
      __CPC.speedForwardBaselineReady = false
      __CPC.speedForwardResetRequested = false
      __CPC.speedForwardReverseRemaining = 0
      __CPC.speedForwardThrottleReleased = nil
    end

    -- Synced Y-force layer. It uses the exact same signed interpolation as Z:
    --   start pose       => Y = 0
    --   normal Z forward => Y moves down
    --   normal Z back    => Y moves up
    -- The x-car-speed Z layer is mapped with the same normalized geometry, so
    -- acceleration pushes down while the throttle-release reverse pulse pushes
    -- up. Gear changes do not enter this Z/Y geometry at all. Since both source
    -- Z values are
    -- already smoothed, Y can never snap ahead of them.
    local syncedVerticalY = 0
    if __CPC.settings.throttleSyncedYEnabled then
      local yDownDistance = __CPC.Math.clamp(__CPC.settings.throttleSyncedYDownDistance or 0, 0, 1.00)
      local yUpDistance = __CPC.Math.clamp(__CPC.settings.throttleSyncedYUpDistance or 0, 0, 1.00)

      local baseY
      if startTravel >= 0 then
        baseY = -yDownDistance * startTravel
      else
        baseY = yUpDistance * (-startTravel)
      end

      local speedY = 0
      local speedDistance = __CPC.Math.clamp(__CPC.settings.throttleSpeedForwardDistance or 0, 0, 1.00)
      if __CPC.settings.throttleSpeedForwardEnabled and speedDistance > 0.0001 then
        local speedTravel = __CPC.Math.clamp(__CPC.renderedSpeedForward / speedDistance, -1, 1)
        if speedTravel >= 0 then
          speedY = -yDownDistance * speedTravel
        else
          speedY = yUpDistance * (-speedTravel)
        end
      end

      syncedVerticalY = baseY + speedY
    end

    local throttleSteering = __CPC.throttleInput * __CPC.steeringInput
    __CPC.renderedVertical = __CPC.advanceBase(__CPC.renderedVertical,
      __CPC.shapeBlend(__CPC.throttleInput, 'throttleVerticalCurve') * __CPC.directedMovement(
        __CPC.Math.clamp(__CPC.settings.throttleVerticalDistance, -0.40, 0.40),
        'throttleVerticalReverse'),
      'throttleVerticalSpeed', 'throttleVerticalReleaseSpeed',
      'throttleVerticalLimit', overall, dt)
    __CPC.renderedLateral = __CPC.advanceBase(__CPC.renderedLateral,
      __CPC.shapeBlend(throttleSteering, 'throttleLateralCurve') * __CPC.directedMovement(
        __CPC.Math.clamp(__CPC.settings.throttleLateralDistance, -0.40, 0.40),
        'throttleLateralReverse'),
      'throttleLateralSpeed', 'throttleLateralReleaseSpeed',
      'throttleLateralLimit', overall, dt)
    __CPC.renderedPitch = __CPC.advanceBase(__CPC.renderedPitch,
      __CPC.shapeBlend(__CPC.throttleInput, 'throttlePitchCurve') * __CPC.directedMovement(
        __CPC.Math.clamp(__CPC.settings.throttlePitchAngle, -90, 90), 'throttlePitchReverse'),
      'throttlePitchSpeed', 'throttlePitchReleaseSpeed',
      'throttlePitchLimit', overall, dt)
    __CPC.renderedYaw = __CPC.advanceBase(__CPC.renderedYaw,
      __CPC.shapeBlend(throttleSteering, 'throttleYawCurve') * __CPC.directedMovement(
        __CPC.Math.clamp(__CPC.settings.throttleYawAngle, -90, 90), 'throttleYawReverse'),
      'throttleYawSpeed', 'throttleYawReleaseSpeed',
      'throttleYawLimit', overall, dt)

    local brakeInput = __CPC.Math.saturate(pedalControls and (pedalControls.brake or 0) or (car.brake or 0))
    local steeringStrength = math.abs(__CPC.steeringInput)
    local gearAnticipationTarget = 0
    if __CPC.settings.throttleGearAnticipationEnabled and (car.gear or 0) > 0 then
      local _, limiter = __CPC.rpmBounds(car)
      local rpmRatio = __CPC.Math.saturate((car.rpm or 0) / math.max(limiter, 1000))
      local rpmStart = __CPC.Math.clamp(__CPC.settings.throttleGearAnticipationRpm or 0.88, 0.50, 0.99)
      local throttleStart = __CPC.Math.clamp(__CPC.settings.throttleGearAnticipationThrottle or 0.35, 0, 0.95)
      gearAnticipationTarget = __CPC.Math.saturate((rpmRatio - rpmStart) / math.max(1 - rpmStart, 0.01))
        * __CPC.Math.saturate((rawThrottleInput - throttleStart) / math.max(1 - throttleStart, 0.01))
    end
    local cornerEntryTarget = __CPC.settings.throttleCornerEntryEnabled and brakeInput * steeringStrength or 0
    local cornerExitTarget = __CPC.settings.throttleCornerExitEnabled and rawThrottleInput * steeringStrength or 0
    __CPC.renderedGearAnticipation = __CPC.Math.expSmooth(__CPC.renderedGearAnticipation,
      gearAnticipationTarget, math.max(__CPC.settings.throttleGearAnticipationSpeed or 7, 0.1) * overall, dt)
    __CPC.renderedCornerEntry = __CPC.Math.expSmooth(__CPC.renderedCornerEntry,
      cornerEntryTarget, math.max(__CPC.settings.throttleCornerEntrySpeed or 7, 0.1) * overall, dt)
    __CPC.renderedCornerExit = __CPC.Math.expSmooth(__CPC.renderedCornerExit,
      cornerExitTarget, math.max(__CPC.settings.throttleCornerExitSpeed or 7, 0.1) * overall, dt)

    local filterDynamicG = __CPC.gearIsolationActive
      and __CPC.settings.throttleGearIsolationGForce
    __CPC.updateLinearFrame(dt, car, filterDynamicG)
    __CPC.filteredLongitudinalG = __CPC.linearFrame.longG
    __CPC.dynamicVerticalG = __CPC.linearFrame.vertG
    __CPC.dynamicSlipAngle = __CPC.linearFrame.slipAngle

    local fovStrength = math.max(__CPC.settings.throttleFovMixStrength, 0)
    local dynamicsEnabled = __CPC.settings.throttleDynamicsEnabled
    __CPC.linearAxis.x, __CPC.linearAxis.y, __CPC.linearAxis.z = 0, 0, 0
    __CPC.linearRuntime.fovMix = 0
    for index = 1, #__CPC.LINEAR_CHANNELS do
      local channel = __CPC.LINEAR_CHANNELS[index]
      local channelOn = dynamicsEnabled
        and (not channel.extended or __CPC.settings.throttleLinearMasterEnabled)
        and channel.base ~= 'ShiftJolt'
      local value = __CPC.updateLinearChannel(channel, __CPC.linearFrame, dt, overall, channelOn)
      __CPC.linearAxis[channel.axis] = __CPC.linearAxis[channel.axis] + value
      local mix = __CPC.settings[channel.keys.fovMix]
      -- ShiftJolt is disabled above, and its saved FOV mix is also ignored so
      -- gear changes cannot modify either camera Z or FOV through this channel.
      if mix ~= nil and channel.base ~= 'ShiftJolt' then
        __CPC.linearRuntime.fovMix = __CPC.linearRuntime.fovMix + __CPC.limitedFovSource(
          __CPC.normalizedMagnitude(value, __CPC.settings[channel.keys.distance]),
          mix, __CPC.settings[channel.keys.fovLimit], fovStrength)
      end
    end
    __CPC.renderedAccelGZ = __CPC.linearValue('AccelG')
    __CPC.renderedBrakeDiveZ = __CPC.linearValue('BrakeDive')
    __CPC.renderedHeaveY = __CPC.linearValue('Heave')
    __CPC.renderedDriftX = __CPC.linearValue('DriftTranslation')
    __CPC.renderedImpactZ = __CPC.linearValue('Impact')

    -- Live normalized speed-FOV state for HUD/debug output. Z and FOV share the
    -- same speed curve and response, but each keeps its own user-set full-scale
    -- amount (metres for Z, degrees for FOV).
    local speedFovAmount = math.abs(__CPC.settings.throttleSpeedFovWiden or 0)
    if __CPC.settings.throttleSpeedForwardEnabled and speedFovAmount > 0.0001 then
      __CPC.fovSpeedBlend = __CPC.Math.clamp(__CPC.renderedSpeedForwardFov / speedFovAmount, 0, 1)
    else
      __CPC.fovSpeedBlend = 0
    end

    -- Base forward Z already owns the Resting <-> Full FOV interpolation, so do
    -- not add the old forward-motion FOV mix on top of it a second time. Vertical,
    -- lateral, angle and dynamic effects are still allowed as additional offsets.
    __CPC.fovMixPositionTarget = __CPC.limitedFovSource(__CPC.normalizedMagnitude(__CPC.renderedVertical,
          __CPC.settings.throttleVerticalDistance), __CPC.settings.throttleFovVerticalMix,
        __CPC.settings.throttleFovVerticalLimit, fovStrength)
      + __CPC.limitedFovSource(__CPC.normalizedMagnitude(__CPC.renderedLateral,
          __CPC.settings.throttleLateralDistance), __CPC.settings.throttleFovLateralMix,
        __CPC.settings.throttleFovLateralLimit, fovStrength)
    __CPC.fovMixAngleTarget = __CPC.limitedFovSource(__CPC.normalizedMagnitude(__CPC.renderedPitch,
        __CPC.settings.throttlePitchAngle), __CPC.settings.throttleFovPitchMix,
        __CPC.settings.throttleFovPitchLimit, fovStrength)
      + __CPC.limitedFovSource(__CPC.normalizedMagnitude(__CPC.renderedYaw, __CPC.settings.throttleYawAngle),
        __CPC.settings.throttleFovYawMix, __CPC.settings.throttleFovYawLimit, fovStrength)
    __CPC.fovMixDynamicTarget = __CPC.linearRuntime.fovMix
    -- The speed-forward Z/FOV pair is now solved geometrically below. Keep this
    -- live-output field at zero so the old speed-FOV mix cannot double-count it.
    __CPC.fovMixSpeedTarget = 0
    local mixTarget = __CPC.fovMixPositionTarget + __CPC.fovMixAngleTarget
      + __CPC.fovMixDynamicTarget
    local mixLimit = math.max(__CPC.settings.throttleFovMixLimit, 0)
    mixTarget = __CPC.Math.clamp(mixTarget, -mixLimit, mixLimit)
    local mixDeadzone = math.max(__CPC.settings.throttleFovMixDeadzone, 0)
    if mixDeadzone > 0 then
      if math.abs(mixTarget) <= mixDeadzone then
        mixTarget = 0
      else
        mixTarget = mixTarget - (mixTarget > 0 and mixDeadzone or -mixDeadzone)
      end
    end
    __CPC.renderedFovMix = __CPC.Math.expSmooth(__CPC.renderedFovMix, mixTarget,
      __CPC.channelSpeed('throttleFovMixSpeed', 'throttleFovMixReturnSpeed',
        math.abs(mixTarget) >= math.abs(__CPC.renderedFovMix), overall), dt)

    local translationScale = math.max(__CPC.settings.throttleMasterTranslationScale, 0)
    local angleScale = math.max(__CPC.settings.throttleMasterAngleScale, 0)
    local limitX = __CPC.axisLimitValue('throttleOutputLimitX')
    local limitY = __CPC.axisLimitValue('throttleOutputLimitY')
    local limitZ = __CPC.axisLimitValue('throttleOutputLimitZ')
    local drivingForwardOffset = (__CPC.renderedGearAnticipation
        * (__CPC.settings.throttleGearAnticipationDistance or 0)
      + __CPC.renderedCornerEntry * (__CPC.settings.throttleCornerEntryDistance or 0)
      + __CPC.renderedCornerExit * (__CPC.settings.throttleCornerExitDistance or 0))
      * __CPC.throttleEffectScale
    local baseForwardOutput = __CPC.Math.clamp((__CPC.renderedForward + __CPC.linearAxis.z * __CPC.throttleEffectScale
      + drivingForwardOffset)
      * translationScale, -limitZ, limitZ)
    -- Stack the speed push on top of the normal throttle-synced forward/back
    -- output. A final generous hard limit prevents pathological values without
    -- letting the old advanced Z clamp erase the new layer.
    __CPC.outputForward = __CPC.Math.clamp(baseForwardOutput + __CPC.renderedSpeedForward * translationScale,
      -1.50, 1.50)
    -- Keep the old advanced Y channels under their normal clamp, then stack the
    -- synced Y-force outside that clamp just like the dedicated speed-Z layer.
    -- This prevents the legacy Y limit from flattening the new geometry.
    local baseVerticalOutput = __CPC.Math.clamp((__CPC.renderedVertical + __CPC.linearAxis.y)
      * __CPC.throttleEffectScale * translationScale, -limitY, limitY)
    __CPC.outputVertical = __CPC.Math.clamp(baseVerticalOutput + syncedVerticalY * translationScale,
      -1.50, 1.50)
    __CPC.outputLateral = __CPC.Math.clamp((__CPC.renderedLateral + __CPC.linearAxis.x)
      * __CPC.throttleEffectScale * translationScale, -limitX, limitX)
    __CPC.outputPitch = __CPC.renderedPitch * __CPC.throttleEffectScale * angleScale
    __CPC.outputYaw = __CPC.renderedYaw * __CPC.throttleEffectScale * angleScale
    local restFov = __CPC.Math.clamp(__CPC.settings.throttleRestingFov, fovMin, fovMax)
    local maxFov = __CPC.Math.clamp(math.max(__CPC.settings.throttleMaximumFov, restFov), fovMin, fovMax)

    -- If either endpoint has been edited since this cockpit pose was captured,
    -- make both endpoints live/absolute. The start point is the exact linear FOV
    -- value at the captured throttle, then is smoothed from the real first-frame
    -- FOV so there is no snap when the live endpoint model takes over.
    if not __CPC.cameraFovEndpointsLive then
      local capturedRest = __CPC.cameraStartRestingFov or restFov
      local capturedMax = __CPC.cameraStartMaximumFov or maxFov
      if math.abs(restFov - capturedRest) > 0.001
          or math.abs(maxFov - capturedMax) > 0.001 then
        __CPC.cameraFovEndpointsLive = true
      end
    end
    local configuredStartFov = restFov
      + (maxFov - restFov) * __CPC.Math.clamp(__CPC.cameraStartThrottleBlend or 0, 0, 1)
    local startFovTarget = __CPC.cameraFovEndpointsLive
      and configuredStartFov
      or __CPC.Math.clamp(__CPC.cameraStartFov or __CPC.originalFov or configuredStartFov, fovMin, fovMax)
    __CPC.cameraLiveStartFov = __CPC.Math.expSmooth(
      __CPC.Math.clamp(__CPC.cameraLiveStartFov or startFovTarget, fovMin, fovMax),
      startFovTarget, fovTransitionSpeed, dt)
    local liveStartFov = __CPC.Math.clamp(__CPC.cameraLiveStartFov, fovMin, fovMax)

    -- Normal Z and FOV use the exact same signed startTravel coordinate:
    --   -1 => -backDistance and Resting FOV
    --    0 => first camera pose and live start FOV
    --   +1 => +forwardDistance and Full-throttle FOV
    local baseFov
    if fovStartTravel >= 0 then
      baseFov = liveStartFov + (maxFov - liveStartFov) * fovStartTravel
    else
      baseFov = liveStartFov + (liveStartFov - restFov) * fovStartTravel
    end

    -- The slow vehicle-speed FOV widening is already expressed in degrees and
    -- is driven by the exact same car-speed curve/response as speed-forward Z.
    -- On throttle release it decays to zero, allowing baseFov to reach Resting FOV.
    local speedFovDelta = math.max(__CPC.renderedSpeedForwardFov, 0)
    local drivingFovOffset = (__CPC.renderedGearAnticipation
        * (__CPC.settings.throttleGearAnticipationFov or 0)
      + __CPC.renderedCornerEntry * (__CPC.settings.throttleCornerEntryFov or 0)
      + __CPC.renderedCornerExit * (__CPC.settings.throttleCornerExitFov or 0))
      * __CPC.throttleEffectScale

    __CPC.renderedFov = __CPC.Math.clamp(baseFov + speedFovDelta
      + __CPC.renderedFovMix * __CPC.throttleEffectScale + drivingFovOffset, fovMin, fovMax)
    ac.setFirstPersonCameraFOV(__CPC.renderedFov)
    __CPC.fovWasApplied = true
    __CPC.applyCameraPose(__CPC.outputForward, __CPC.outputLateral, __CPC.outputVertical, __CPC.outputPitch, __CPC.outputYaw)
    __CPC.throttleStatus = 'Active in cockpit'
  end

end
