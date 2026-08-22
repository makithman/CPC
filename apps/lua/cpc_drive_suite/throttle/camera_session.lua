return [====[
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
]====]
