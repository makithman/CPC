return [====[
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

    -- Base Z and FOV share one physical-pedal target and one smoothed blend, so
    -- both effects leave rest on the same frame. The first valid cockpit frame is the mathematical origin. If the app starts
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
    local fovTransitionSpeed = transitionSpeed
    local fovMin, fovMax = __CPC.fovHardBounds()
    if not __CPC.cameraStartReady then
      __CPC.cameraStartThrottleBlend = __CPC.Math.clamp(baseThrottleTarget, 0, 1)
      __CPC.cameraStartFov = __CPC.Math.clamp(__CPC.originalFov or __CPC.sim.firstPersonCameraFOV
        or __CPC.settings.throttleRestingFov, fovMin, fovMax)
      __CPC.cameraStartRestingFov = __CPC.Math.clamp(__CPC.settings.throttleRestingFov, fovMin, fovMax)
      __CPC.cameraStartMaximumFov = __CPC.Math.clamp(math.max(__CPC.settings.throttleMaximumFov,
        __CPC.cameraStartRestingFov), fovMin, fovMax)
      __CPC.cameraLiveStartFov = __CPC.cameraStartFov
      __CPC.cameraFovEndpointsLive = false
      __CPC.forwardBlend = __CPC.cameraStartThrottleBlend
      __CPC.fovBlend = __CPC.forwardBlend
      __CPC.cameraStartReady = true
    else
      -- The real pedal target is shift-proof, so a single blend can drive both
      -- effects without transmission cuts or auto-blips separating their timing.
      __CPC.forwardBlend = __CPC.Math.expSmooth(__CPC.forwardBlend, baseThrottleTarget, transitionSpeed, dt)
      __CPC.fovBlend = __CPC.forwardBlend
    end

    local syncBlend = __CPC.Math.clamp(__CPC.forwardBlend, 0, 1)
    local startTravel = __CPC.anchoredUnitTravel(syncBlend, __CPC.cameraStartThrottleBlend)
    local fovStartTravel = startTravel
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
]====]
