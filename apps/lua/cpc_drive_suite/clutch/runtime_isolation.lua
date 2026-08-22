return [====[
-- CPC Drive Suite 3.9.2 — Adaptive clutch, telemetry and gear-isolation runtime
-- Generated from the former monolithic core. Shared runtime values live in __CPC.

return function(__CPC)
  function __CPC.copyDefaultsWithPrefix(prefix)
    for key, value in pairs(__CPC.DEFAULTS) do
      if string.sub(key, 1, #prefix) == prefix then __CPC.settings[key] = value end
    end
  end

  __CPC.telemetry = {
    rpm = 0,
    idleRPM = 850,
    limiterRPM = 7000,
    launchRPM = 2300,
    kickRPM = 3900,
    gas = 0,
    brake = 0,
    rawClutch = 1,
    steer = 0,
    speed = 0,
    gear = 0,
    builtInAutoClutch = false,
    clutchOverrideActive = false,
    accelerationX = 0,
    accelerationY = 0,
    accelerationZ = 0
  }

  -- Adaptive clutch runtime ----------------------------------------------------

  __CPC.clutchCommand = 1
  __CPC.clutchTarget = 1
  __CPC.rpmTrend = 0
  __CPC.previousRPM = nil
  __CPC.previousGear = nil
  __CPC.previousEngagedGear = nil
  __CPC.previousGearUp = false
  __CPC.previousGearDown = false
  __CPC.previousRequestedGear = 0
  __CPC.previousStrongTurn = 0
  __CPC.previousResetCounter = nil
  __CPC.clutchHistoryReady = false
  __CPC.shiftElapsed = 0
  __CPC.shiftActive = false
  __CPC.kickRemaining = 0
  __CPC.kickCooldownRemaining = 0
  __CPC.rpmLimiterFallback = nil
  __CPC.clutchStatus = 'Waiting for physics'
  __CPC.clutchStatusKind = 'idle'
  __CPC.actionFlash = 0
  __CPC.elapsedTime = 0
  __CPC.launchControlArmed = false
  __CPC.launchControlReady = false
  __CPC.launchControlWasDown = false
  __CPC.launchGearPulsePending = false
  __CPC.launchGearPulseCooldown = 0
  __CPC.launchDumpButton = ac.ControlButton
    and ac.ControlButton('cpc.drive.suite/Launch dump', { hold = true })
    or nil

  function __CPC.setClutchOverride(value)
    __CPC.clutchCommand = __CPC.Math.saturate(value)
    if __CPC.controlsOverride then __CPC.controlsOverride.clutch = __CPC.clutchCommand end
  end

  function __CPC.setGasOverride(value)
    if __CPC.controlsOverride then
      __CPC.controlsOverride.gas = __CPC.Math.saturate(value or 0)
    end
  end

  function __CPC.releaseClutch(reason, kind)
    __CPC.clutchTarget = 1
    __CPC.setClutchOverride(1)
    __CPC.shiftActive = false
    __CPC.kickRemaining = 0
    __CPC.clutchStatus = reason or 'Clutch assist disabled'
    __CPC.clutchStatusKind = kind or 'idle'
  end

  function __CPC.resetClutchRuntime(car)
    __CPC.clutchCommand, __CPC.clutchTarget, __CPC.rpmTrend = 1, 1, 0
    __CPC.previousRPM = car and car.rpm or nil
    __CPC.previousGear = car and car.gear or nil
    __CPC.previousEngagedGear = car and car.engagedGear or nil
    __CPC.previousGearUp, __CPC.previousGearDown = false, false
    __CPC.previousRequestedGear, __CPC.previousStrongTurn = 0, 0
    __CPC.shiftElapsed, __CPC.kickRemaining, __CPC.kickCooldownRemaining = 0, 0, 0
    __CPC.rpmLimiterFallback = nil
    __CPC.shiftActive, __CPC.clutchHistoryReady = false, false
    __CPC.launchControlArmed, __CPC.launchControlReady = false, false
    __CPC.launchControlWasDown = false
    __CPC.launchGearPulsePending = false
    __CPC.launchGearPulseCooldown = 0
    __CPC.setClutchOverride(1)
    __CPC.setGasOverride(0)
    if __CPC.controlsOverride then
      __CPC.controlsOverride.requestedGearIndex = 0
    end
  end

  function __CPC.rpmBounds(car)
    local idle = __CPC.Math.finiteNumber(car.rpmMinimum, 850)
    if not idle or idle < 400 then idle = 850 end
    local limiter = __CPC.Math.finiteNumber(car.rpmLimiter, 0)
    if not limiter or limiter < idle + 1200 then
      if __CPC.rpmLimiterFallback == nil then
        __CPC.rpmLimiterFallback = math.max(7000,
          __CPC.Math.finiteNumber(car.rpm, 0) + 1500)
      end
      limiter = __CPC.rpmLimiterFallback
    else
      __CPC.rpmLimiterFallback = limiter
    end
    return idle, limiter
  end

  function __CPC.getRawInputs(car)
    local raw = physics and physics.getCarInputControls and physics.getCarInputControls() or nil
    if not raw then
      return nil, __CPC.Math.finiteNumber(car.gas, 0), __CPC.Math.finiteNumber(car.brake, 0),
        __CPC.Math.finiteNumber(car.clutch, 1), __CPC.Math.finiteNumber(car.steer, 0),
        0
    end
    return raw, __CPC.Math.finiteNumber(raw.gas, 0), __CPC.Math.finiteNumber(raw.brake, 0),
      __CPC.Math.finiteNumber(raw.clutch, 1), __CPC.Math.finiteNumber(raw.steer, 0),
      __CPC.Math.finiteNumber(raw.handbrake, 0)
  end

  function __CPC.resetGearShiftIsolation(car)
    __CPC.gearIsolationRemaining = 0
    __CPC.gearIsolationHeldThrottle = 0
    __CPC.gearIsolationLastThrottle = 0
    __CPC.gearIsolationPreviousGear = car and car.gear or nil
    __CPC.gearIsolationPreviousEngagedGear = car and car.engagedGear or nil
    __CPC.gearIsolationPreviousGearUp = false
    __CPC.gearIsolationPreviousGearDown = false
    __CPC.gearIsolationPreviousRequestedGear = 0
    __CPC.gearIsolationResetCounter = car and car.resetCounter or nil
    __CPC.gearIsolationReady = car ~= nil
    __CPC.gearIsolationActive = false
  end

  function __CPC.updateGearShiftIsolation(dt, car)
    if not car then
      __CPC.resetGearShiftIsolation(nil)
      return
    end
    if __CPC.gearIsolationResetCounter ~= nil
        and car.resetCounter ~= __CPC.gearIsolationResetCounter then
      __CPC.resetGearShiftIsolation(car)
    end
    __CPC.gearIsolationResetCounter = car.resetCounter

    local raw = physics and physics.getCarInputControls
      and physics.getCarInputControls() or nil
    local gearUp = raw and raw.gearUp or false
    local gearDown = raw and raw.gearDown or false
    local requestedGear = raw and raw.requestedGearIndex or 0
    local gearButtonEdge = (gearUp and not __CPC.gearIsolationPreviousGearUp)
      or (gearDown and not __CPC.gearIsolationPreviousGearDown)
    local directGearEdge = requestedGear ~= 0
      and requestedGear ~= __CPC.gearIsolationPreviousRequestedGear
    local gearChanged = __CPC.gearIsolationReady
      and (car.gear ~= __CPC.gearIsolationPreviousGear
        or car.engagedGear ~= __CPC.gearIsolationPreviousEngagedGear)
    local speedForwardGearReset = __CPC.gearIsolationReady
      and (gearButtonEdge or directGearEdge or gearChanged)

    if speedForwardGearReset then
      __CPC.gearIsolationRemaining = __CPC.Math.clamp(__CPC.settings.throttleGearIsolationTime, 0.05, 1.0)
      __CPC.gearIsolationHeldThrottle = __CPC.gearIsolationLastThrottle
    end

    __CPC.gearIsolationPreviousGear = car.gear
    __CPC.gearIsolationPreviousEngagedGear = car.engagedGear
    __CPC.gearIsolationPreviousGearUp = gearUp
    __CPC.gearIsolationPreviousGearDown = gearDown
    __CPC.gearIsolationPreviousRequestedGear = requestedGear
]====]
