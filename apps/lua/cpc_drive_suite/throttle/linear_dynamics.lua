return [====[
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

]====]
