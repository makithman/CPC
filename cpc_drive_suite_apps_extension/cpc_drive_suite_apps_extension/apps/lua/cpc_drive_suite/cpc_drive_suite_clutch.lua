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
    __CPC.gearIsolationReady = true
    __CPC.gearIsolationActive = __CPC.settings.throttleGearIsolationEnabled
      and __CPC.gearIsolationRemaining > 0
    __CPC.gearIsolationRemaining = math.max(0, __CPC.gearIsolationRemaining - dt)
  end

  function __CPC.updateClutchHistory(car, raw, strongTurn)
    __CPC.previousRPM = car.rpm
    __CPC.previousGear = car.gear
    __CPC.previousEngagedGear = car.engagedGear
    __CPC.previousGearUp = raw and raw.gearUp or false
    __CPC.previousGearDown = raw and raw.gearDown or false
    __CPC.previousRequestedGear = raw and raw.requestedGearIndex or 0
    if strongTurn ~= 0 then __CPC.previousStrongTurn = strongTurn end
    __CPC.clutchHistoryReady = true
  end

  local function launchDumpHeld()
    local button = __CPC.launchDumpButton
    if not button then return false end
    if button.down then return button:down() end
    return false
  end

  local function launchDumpPressed()
    local button = __CPC.launchDumpButton
    if not button or not button.pressed then return false end
    return button:pressed()
  end

  local function updateLaunchControl(dt, car, speed, launchRPM)
    __CPC.launchGearPulseCooldown = math.max(0, (__CPC.launchGearPulseCooldown or 0) - dt)
    if __CPC.launchGearPulsePending and __CPC.controlsOverride then
      __CPC.controlsOverride.gearDown = false
      __CPC.launchGearPulsePending = false
    end

    local enabled = __CPC.settings.suiteEnabled and __CPC.settings.clutchEnabled
      and __CPC.settings.clutchLaunchControlEnabled
    local held = enabled and launchDumpHeld()
    local pressed = enabled and launchDumpPressed()
    local holdMode = __CPC.launchDumpButton and __CPC.launchDumpButton.holdMode
      and __CPC.launchDumpButton:holdMode()
    local stationary = speed < math.max(__CPC.settings.clutchLaunchEndSpeed, 5) + 4
    local canArm = stationary and (car.gear or 0) >= 0

    if not enabled then
      if __CPC.launchControlArmed and __CPC.controlsOverride then
        __CPC.controlsOverride.requestedGearIndex = 0
      end
      __CPC.launchControlArmed, __CPC.launchControlReady = false, false
      __CPC.launchControlWasDown = false
      return false
    end

    if holdMode then
      if held and canArm then
        __CPC.launchControlArmed = true
      elseif __CPC.launchControlWasDown and __CPC.launchControlArmed then
        __CPC.launchControlArmed = false
      elseif not canArm then
        __CPC.launchControlArmed = false
      end
    else
      if pressed then
        if __CPC.launchControlArmed then
          __CPC.launchControlArmed = false
        elseif canArm then
          __CPC.launchControlArmed = true
        end
      elseif __CPC.launchControlArmed and not canArm then
        __CPC.launchControlArmed = false
      end
    end
    __CPC.launchControlWasDown = held

    if not __CPC.launchControlArmed then
      __CPC.launchControlReady = false
      if __CPC.controlsOverride then __CPC.controlsOverride.requestedGearIndex = 0 end
      return false
    end

    if __CPC.controlsOverride then
      __CPC.controlsOverride.requestedGearIndex = 1
      local sim = ac.getSim and ac.getSim() or nil
      local paddleCar = not car.hShifter and not (sim and sim.controlsWithShifter)
      if paddleCar and (car.gear or 0) > 1 and __CPC.launchGearPulseCooldown <= 0 then
        __CPC.controlsOverride.gearDown = true
        __CPC.launchGearPulsePending = true
        __CPC.launchGearPulseCooldown = 0.14
      end
    end

    local bite = __CPC.Math.clamp(__CPC.settings.clutchLaunchControlBite, 0.05, 0.70)
    local rpm = car.rpm or 0
    if rpm > launchRPM + 80 then
      local extra = __CPC.Math.saturate((rpm - launchRPM) / 500)
      bite = bite * (1 - extra * 0.85)
    end
    __CPC.setGasOverride(__CPC.settings.clutchLaunchControlThrottle)
    __CPC.launchControlReady = rpm >= launchRPM * 0.97
    return {
      target = bite,
      reason = __CPC.launchControlReady and 'Launch ready — dump to go' or 'Launch hold — building RPM',
      kind = 'action'
    }
  end

  function __CPC.updateAdaptiveClutch(dt, car)
    if not car then
      __CPC.releaseClutch('No player car')
      return
    end

    local raw, gas, brake, rawClutch, steer, handbrake = __CPC.getRawInputs(car)
    local speed = math.abs(car.speedKmh or 0)
    local idleRPM, limiterRPM = __CPC.rpmBounds(car)
    local launchRPM = idleRPM + (limiterRPM - idleRPM) * __CPC.settings.clutchLaunchRPMPercent / 100
    local kickRPM = idleRPM + (limiterRPM - idleRPM) * __CPC.settings.clutchKickRPMPercent / 100

    if __CPC.previousRPM then
      local rawTrend = __CPC.Math.clamp((car.rpm - __CPC.previousRPM) / math.max(dt, 1 / 240), -20000, 20000)
      __CPC.rpmTrend = __CPC.Math.expSmooth(__CPC.rpmTrend, rawTrend, 9, dt)
    end

    local turnDeadzone = math.max(__CPC.settings.clutchTurnLoadStart, 0.02)
    local strongTurn = __CPC.Math.signWithDeadzone(steer,
      math.max(__CPC.settings.clutchKickSteer, turnDeadzone))
    local directionChanged = __CPC.clutchHistoryReady and strongTurn ~= 0
      and __CPC.previousStrongTurn ~= 0 and strongTurn ~= __CPC.previousStrongTurn

    __CPC.telemetry.rpm = car.rpm or 0
    __CPC.telemetry.idleRPM = idleRPM
    __CPC.telemetry.limiterRPM = limiterRPM
    __CPC.telemetry.launchRPM = launchRPM
    __CPC.telemetry.kickRPM = kickRPM
    __CPC.telemetry.gas = gas
    __CPC.telemetry.brake = brake
    __CPC.telemetry.rawClutch = rawClutch
    __CPC.telemetry.steer = steer
    __CPC.telemetry.speed = speed
    __CPC.telemetry.gear = car.gear or 0
    __CPC.telemetry.gearCount = car.gearCount or 0
    __CPC.telemetry.builtInAutoClutch = car.autoClutch or false
    __CPC.telemetry.clutchOverrideActive = __CPC.controlsOverride and __CPC.controlsOverride:active() or false
    __CPC.telemetry.accelerationX = car.acceleration and car.acceleration.x or 0
    __CPC.telemetry.accelerationY = car.acceleration and car.acceleration.y or 0
    __CPC.telemetry.accelerationZ = car.acceleration and car.acceleration.z or 0

    if __CPC.previousResetCounter ~= nil and car.resetCounter ~= __CPC.previousResetCounter then
      __CPC.resetClutchRuntime(car)
    end
    __CPC.previousResetCounter = car.resetCounter

    if not __CPC.settings.suiteEnabled or not __CPC.settings.clutchEnabled then
      if __CPC.launchControlArmed and __CPC.controlsOverride then
        __CPC.controlsOverride.requestedGearIndex = 0
      end
      __CPC.launchControlArmed, __CPC.launchControlReady = false, false
      __CPC.releaseClutch(__CPC.settings.suiteEnabled and 'Clutch assist disabled' or 'Suite paused')
      __CPC.updateClutchHistory(car, raw, strongTurn)
      return
    end
    if not __CPC.controlsOverride then
      __CPC.releaseClutch('CSP control override unavailable', 'warning')
      __CPC.updateClutchHistory(car, raw, strongTurn)
      return
    end
    if not car.physicsAvailable or car.isAIControlled or not car.isUserControlled then
      __CPC.releaseClutch('Waiting for player physics')
      __CPC.updateClutchHistory(car, raw, strongTurn)
      return
    end

    __CPC.kickCooldownRemaining = math.max(0, __CPC.kickCooldownRemaining - dt)
    local launchHold = updateLaunchControl(dt, car, speed, launchRPM)
    if not launchHold then __CPC.setGasOverride(0) end

    local gearUp = raw and raw.gearUp or false
    local gearDown = raw and raw.gearDown or false
    local requestedGear = raw and raw.requestedGearIndex or 0
    local gearButtonEdge = (gearUp and not __CPC.previousGearUp) or (gearDown and not __CPC.previousGearDown)
    local directGearEdge = requestedGear ~= 0 and requestedGear ~= __CPC.previousRequestedGear
    local gearChanged = __CPC.clutchHistoryReady
      and (car.gear ~= __CPC.previousGear or car.engagedGear ~= __CPC.previousEngagedGear)
    if __CPC.settings.clutchShiftEnabled and __CPC.clutchHistoryReady
        and not __CPC.launchControlArmed
        and (gearButtonEdge or directGearEdge or gearChanged) then
      __CPC.shiftElapsed, __CPC.shiftActive = 0, true
    end

    local target, reason, kind = 1, 'Clutch coupled', 'active'
    local inGear = car.gear ~= 0 or car.engagedGear ~= 0

    if launchHold then
      target, reason, kind = launchHold.target, launchHold.reason, launchHold.kind
    elseif __CPC.settings.clutchLaunchEnabled and inGear and speed < __CPC.settings.clutchLaunchEndSpeed then
      local speedFactor = __CPC.Math.saturate(speed / math.max(__CPC.settings.clutchLaunchEndSpeed, 1))
      local launchStartRPM = idleRPM + math.min(260, __CPC.settings.clutchAntiStallMargin * 0.55)
      local rpmFactor = __CPC.Math.saturate((car.rpm - launchStartRPM) /
        math.max(launchRPM - launchStartRPM, 200))
      if gas < __CPC.settings.clutchLaunchThrottle then
        target = speed < 1.5 and 0 or speedFactor
        reason = brake >= __CPC.settings.clutchBrakeThreshold
          and 'Holding clutch at stop' or 'Waiting for launch throttle'
      else
        target = math.max(speedFactor, rpmFactor)
        if target < 0.98 then reason = 'Adaptive launch slip' end
      end
      if brake >= __CPC.settings.clutchBrakeThreshold and speed < 2.5 then
        target, reason = 0, 'Brake hold - clutch disengaged'
      end
      if target < 0.98 then kind = 'action' end
    end

    if not launchHold then
      if __CPC.settings.clutchAntiStallEnabled and inGear and speed < __CPC.settings.clutchAntiStallSpeed then
        local steerLoad = __CPC.Math.saturate((math.abs(steer) - __CPC.settings.clutchTurnLoadStart) /
          math.max(1 - __CPC.settings.clutchTurnLoadStart, 0.05))
        local turnRPM = __CPC.settings.clutchTurnAware and steerLoad * __CPC.settings.clutchTurnExtraMargin or 0
        local brakeRPM = brake >= __CPC.settings.clutchBrakeThreshold and 100 * brake or 0
        local threshold = idleRPM + __CPC.settings.clutchAntiStallMargin + turnRPM + brakeRPM
        local predictedRPM = car.rpm + math.min(__CPC.rpmTrend, 0) * __CPC.settings.clutchRPMLookahead
        local loadingEngine = brake >= __CPC.settings.clutchBrakeThreshold or gas < 0.38
          or __CPC.rpmTrend < -250 or car.rpm < idleRPM + 130
        if predictedRPM < threshold and loadingEngine then
          local danger = __CPC.Math.saturate((threshold - predictedRPM) /
            math.max(__CPC.settings.clutchAntiStallMargin, 120))
          local antiStallTarget = 1 - danger
          if car.rpm < idleRPM + 90 then antiStallTarget = 0 end
          if antiStallTarget < target then
            target = antiStallTarget
            reason = math.abs(steer) >= __CPC.settings.clutchTurnLoadStart
              and 'Turn-aware anti-stall' or 'Predictive anti-stall'
            kind = 'action'
          end
        end
      end

      local kickCondition = __CPC.settings.clutchKickEnabled and inGear
        and speed >= __CPC.settings.clutchKickMinSpeed
        and gas >= __CPC.settings.clutchKickThrottle and brake < 0.25
        and math.abs(steer) >= __CPC.settings.clutchKickSteer and car.rpm < kickRPM
        and (__CPC.rpmTrend <= -__CPC.settings.clutchKickRPMDrop or directionChanged)
      if kickCondition and __CPC.kickCooldownRemaining <= 0 and __CPC.kickRemaining <= 0 then
        __CPC.kickRemaining = __CPC.settings.clutchKickDuration
        __CPC.kickCooldownRemaining = __CPC.settings.clutchKickCooldown
      end
      if __CPC.kickRemaining > 0 then
        target = 0
        reason = directionChanged and 'Direction-change clutch kick' or 'Low-RPM clutch kick'
        kind = 'action'
        __CPC.kickRemaining = math.max(0, __CPC.kickRemaining - dt)
      end

      if __CPC.shiftActive then
        local total = __CPC.settings.clutchShiftHold + __CPC.settings.clutchShiftRelease
        local shiftTarget = __CPC.shiftElapsed < __CPC.settings.clutchShiftHold and 0
          or __CPC.Math.saturate((__CPC.shiftElapsed - __CPC.settings.clutchShiftHold) /
            math.max(__CPC.settings.clutchShiftRelease, 0.02))
        target = math.min(target, shiftTarget)
        reason = __CPC.shiftElapsed < __CPC.settings.clutchShiftHold
          and 'Shift - clutch pressed' or 'Shift - clutch releasing'
        kind = 'action'
        __CPC.shiftElapsed = __CPC.shiftElapsed + dt
        if __CPC.shiftElapsed >= total then __CPC.shiftActive = false end
      end
    end

    if __CPC.settings.clutchHandbrakeEnabled and handbrake > 0.05 then
      target = 0
      reason = 'Handbrake - clutch disengaged'
      kind = 'action'
    end

    __CPC.clutchTarget = __CPC.Math.saturate(target)
    local rate = __CPC.clutchTarget < __CPC.clutchCommand
      and __CPC.settings.clutchPressRate or __CPC.settings.clutchReleaseRate
    __CPC.setClutchOverride(__CPC.Math.moveTowards(__CPC.clutchCommand, __CPC.clutchTarget,
      math.max(rate, 0.1) * dt))
    if kind == 'action' and (__CPC.clutchStatusKind ~= 'action' or __CPC.clutchStatus ~= reason) then
      __CPC.actionFlash = 1
    end
    __CPC.clutchStatus, __CPC.clutchStatusKind = reason, kind
    __CPC.updateClutchHistory(car, raw, strongTurn)
  end

end