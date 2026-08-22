return [====[
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
]====]
