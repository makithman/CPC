return [====[
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
]====]
