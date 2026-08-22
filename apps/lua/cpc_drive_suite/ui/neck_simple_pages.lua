return [====[
      __CPC.slider('Entry response speed', 'throttleCornerEntrySpeed', 0.1, 30, '%.1f')
      ui.separator()
      __CPC.toggle('Enable corner-exit response', 'throttleCornerExitEnabled')
      __CPC.slider('Exit camera movement', 'throttleCornerExitDistance', -0.10, 0.10, '%+.3f m')
      __CPC.slider('Exit view-width change', 'throttleCornerExitFov', -10, 10, '%+.1f deg')
      __CPC.slider('Exit response speed', 'throttleCornerExitSpeed', 0.1, 30, '%.1f')
      ui.text(string.format('Entry / exit: %.0f%% / %.0f%%',
        __CPC.renderedCornerEntry * 100, __CPC.renderedCornerExit * 100))

    elseif __CPC.settings.throttlePage == 8 then
      __CPC.drawThrottleAdvancedPage()

    else
      __CPC.drawThrottleAdvancedPage()
    end

    __CPC.section('THROTTLE CAMERA CONTROLS')
    if ui.button('RETURN TO REST') then
      __CPC.resetThrottleMotion()
      if __CPC.settings.throttleEnabled and __CPC.sim.cameraMode == ac.CameraMode.Cockpit then
        local fovMin, fovMax = __CPC.fovHardBounds()
        ac.setFirstPersonCameraFOV(__CPC.Math.clamp(__CPC.settings.throttleRestingFov, fovMin, fovMax))
        __CPC.fovWasApplied = true
        __CPC.applyCameraPose(0, 0, 0, 0, 0)
      end
    end
    ui.sameLine()
    if ui.button('RESET THROTTLE') then
      __CPC.copyDefaultsWithPrefix('throttle')
      __CPC.resetThrottleMotion()
    end
  end

  function __CPC.drawNeckPage()
    if not __CPC.drawingSubwheelSettings then
      __CPC.section('DYNAMIC 6DOF NECKFX')
      __CPC.toggle('Enable NeckFX output', 'neckEnabled')
      ui.sameLine()
      ui.textColored(__CPC.neckIsOnline() and 'BACKEND ONLINE' or 'BACKEND OFFLINE',
        __CPC.neckIsOnline() and __CPC.Theme.COLOR_ACTIVE or __CPC.Theme.COLOR_WARNING)
    end

    if __CPC.settings.neckPage == 1 then
      __CPC.section('MASTER EFFECTS')
      __CPC.drawSectionPresets('neckMaster')
      __CPC.toggle('Enable all six dynamic axes', 'neckDynamicMovement')
      __CPC.slider('Overall effects speed', 'neckOverallSpeed', 0.1, 3.0, '%.1fx')
      __CPC.slider('Full movement at G-force', 'neckGForceAtFull', 0.2, 6.0, '%.2f G')
      __CPC.slider('Position master scale', 'neckMoveScale', 0, 3.0, '%.2fx')
      __CPC.slider('Angle master scale', 'neckAngleScale', 0, 3.0, '%.2fx')
      __CPC.slider('Hidden-jerk master scale', 'neckHiddenScale', 0, 3.0, '%.2fx')
      __CPC.slider('Cross-axis mix master scale', 'neckMixScale', 0, 3.0, '%.2fx')
      __CPC.slider('Following master scale', 'neckFollowScale', 0, 3.0, '%.2fx')
      __CPC.toggle('Use mph for effects cap', 'neckEffectSpeedCapMph')
      local unit = __CPC.settings.neckEffectSpeedCapMph and 'mph' or 'km/h'
      __CPC.slider('Effects reach full at', 'neckEffectSpeedCap', 1,
        __CPC.settings.neckEffectSpeedCapMph and 120 or 200, '%.0f ' .. unit)
      ui.textWrapped('Overall speed multiplies every individual response speed plus slide, steering and track-following response. Amounts remain unchanged.')

      __CPC.section('LIVE BACKEND OUTPUT')
      ui.progressBar(__CPC.neckTelemetry.effectStrength, vec2(ui.availableSpaceX(), 18),
        string.format('Road-speed effect strength %.0f%%', __CPC.neckTelemetry.effectStrength * 100))
      ui.text(string.format('Position X/Y/Z: %+.1f / %+.1f / %+.1f mm',
        __CPC.neckTelemetry.outputX * 1000, __CPC.neckTelemetry.outputY * 1000,
        __CPC.neckTelemetry.outputZ * 1000))
      ui.text(string.format('Yaw / pitch / roll: %+.2f / %+.2f / %+.2f deg',
        __CPC.neckTelemetry.outputYaw, __CPC.neckTelemetry.outputPitch, __CPC.neckTelemetry.outputRoll))
      ui.text(string.format('Car acceleration X/Y/Z: %+.2f / %+.2f / %+.2f G',
        __CPC.telemetry.accelerationX, __CPC.telemetry.accelerationY, __CPC.telemetry.accelerationZ))
      if not __CPC.neckIsOnline() then
        ui.textColored('Select CPC Drive Suite - NeckFX Backend in CSP and reload the session.',
          __CPC.Theme.COLOR_WARNING)
      end

    elseif __CPC.settings.neckPage == 2 then
      __CPC.section('X — LATERAL HEAD MOVEMENT')
      __CPC.drawSectionPresets('neckX')
      __CPC.slider('X movement distance', 'neckMoveXDistance', 0, 0.15, '%.3f m')
      __CPC.reverseToggle('Reverse X movement', 'neckMoveXReverse')
      __CPC.slider('X response speed', 'neckMoveXSpeed', 0.5, 30, '%.1f')
      __CPC.section('Y — VERTICAL HEAD MOVEMENT')
      __CPC.drawSectionPresets('neckY')
      __CPC.slider('Y movement distance', 'neckMoveYDistance', 0, 0.10, '%.3f m')
      __CPC.reverseToggle('Reverse Y movement', 'neckMoveYReverse')
      __CPC.slider('Y response speed', 'neckMoveYSpeed', 0.5, 30, '%.1f')
      __CPC.section('Z — FORWARD / BACK MOVEMENT')
      __CPC.drawSectionPresets('neckZ')
      __CPC.slider('Z movement distance', 'neckMoveZDistance', 0, 0.15, '%.3f m')
      __CPC.reverseToggle('Reverse Z movement', 'neckMoveZReverse')
      __CPC.slider('Z response speed', 'neckMoveZSpeed', 0.5, 30, '%.1f')
      __CPC.section('OVAL XY MOVEMENT')
      __CPC.slider('Oval width', 'neckOvalWidth', 0, 0.15, '%.3f m')
      __CPC.slider('Oval height', 'neckOvalHeight', 0, 0.10, '%.3f m')
      __CPC.slider('Oval rotation speed', 'neckOvalSpeed', 0, 5, '%.2f rotations/s')

    elseif __CPC.settings.neckPage == 3 then
      __CPC.section('PRIMARY ROTATION')
      __CPC.drawSectionPresets('neckPrimaryRotation')
      __CPC.slider('Yaw angle', 'neckYawAngle', 0, 45, '%.1f deg')
      __CPC.reverseToggle('Reverse yaw movement', 'neckYawReverse')
      __CPC.slider('Yaw response speed', 'neckYawSpeed', 0.5, 30, '%.1f')
      __CPC.slider('Roll angle', 'neckRollAngle', 0, 45, '%.1f deg')
      __CPC.reverseToggle('Reverse roll movement', 'neckRollReverse')
      __CPC.slider('Roll response speed', 'neckRollSpeed', 0.5, 30, '%.1f')
      __CPC.toggle('Traditional roll', 'neckTraditionalRollEnabled')
      __CPC.toggle('Roll shake', 'neckRollShakeEnabled')
      __CPC.toggle('Combine roll + shake', 'neckCombineRollShake')
      __CPC.slider('Roll shake speed', 'neckRollShakeSpeed', 0, 5, '%.2f cycles/s')

      __CPC.section('EXTRA ROAD AND SLIDE ROTATION')
      __CPC.drawSectionPresets('neckRoadRotation')
      __CPC.slider('Drift yaw angle', 'neckDriftYawAngle', 0, 45, '%.1f deg')
      __CPC.reverseToggle('Reverse drift yaw movement', 'neckDriftYawReverse')
      __CPC.slider('Drift yaw response', 'neckDriftYawSpeed', 0.5, 30, '%.1f')
      __CPC.slider('Drift roll angle', 'neckDriftRollAngle', 0, 45, '%.1f deg')
      __CPC.reverseToggle('Reverse drift roll movement', 'neckDriftRollReverse')
      __CPC.slider('Drift roll response', 'neckDriftRollSpeed', 0.5, 30, '%.1f')
      __CPC.slider('Drift yaw rearward travel', 'neckDriftYawBackDistance', 0, 0.15, '%.3f m')
      __CPC.toggle('Reverse drift rearward travel', 'neckDriftYawBackReverse')
      __CPC.slider('Track banking roll', 'neckBankRollAngle', 0, 45, '%.1f deg')
      __CPC.reverseToggle('Reverse banking roll movement', 'neckBankRollReverse')
      __CPC.slider('Banking roll response', 'neckBankRollSpeed', 0.5, 30, '%.1f')

    elseif __CPC.settings.neckPage == 4 then
      __CPC.section('HIGH-SPEED ANGLE WINDOW')
      __CPC.drawSectionPresets('neckSpeedWindow')
      __CPC.slider('Speed angles begin', 'neckSpeedAngleStartKmh', 0, 200, '%.0f km/h')
      if __CPC.settings.neckSpeedAngleFullKmh <= __CPC.settings.neckSpeedAngleStartKmh then
        __CPC.settings.neckSpeedAngleFullKmh = __CPC.settings.neckSpeedAngleStartKmh + 10
      end
      __CPC.slider('Speed angles reach full', 'neckSpeedAngleFullKmh',
        __CPC.settings.neckSpeedAngleStartKmh + 10, 400, '%.0f km/h')
      __CPC.slider('Speed yaw angle', 'neckSpeedYawAngle', -45, 45, '%+.1f deg')
      __CPC.reverseToggle('Reverse speed yaw movement', 'neckSpeedYawReverse')
      __CPC.slider('Speed yaw response', 'neckSpeedYawSpeed', 0.5, 30, '%.1f')
      __CPC.slider('Speed roll angle', 'neckSpeedRollAngle', -45, 45, '%+.1f deg')
      __CPC.reverseToggle('Reverse speed roll movement', 'neckSpeedRollReverse')
      __CPC.slider('Speed roll response', 'neckSpeedRollSpeed', 0.5, 30, '%.1f')

      __CPC.section('HIDDEN TRANSIENT NECK LAG')
      __CPC.drawSectionPresets('neckTransient')
      __CPC.slider('Full response at acceleration jerk', 'neckHiddenJerkAtFull', 1, 30, '%.1f G/s')
      __CPC.slider('Full response at yaw rate', 'neckHiddenYawRateAtFull', 0.2, 3.0, '%.1f rad/s')
      __CPC.slider('Hidden yaw angle', 'neckHiddenYawAngle', -20, 20, '%+.1f deg')
      __CPC.reverseToggle('Reverse hidden yaw movement', 'neckHiddenYawReverse')
      __CPC.slider('Hidden yaw response', 'neckHiddenYawSpeed', 0.5, 30, '%.1f')
      __CPC.slider('Hidden roll angle', 'neckHiddenRollAngle', -20, 20, '%+.1f deg')
      __CPC.reverseToggle('Reverse hidden roll movement', 'neckHiddenRollReverse')
      __CPC.slider('Hidden roll response', 'neckHiddenRollSpeed', 0.5, 30, '%.1f')

    else
      __CPC.section('NON-RECURSIVE ANGLE MIXES')
      __CPC.drawSectionPresets('neckAngleMix')
      __CPC.slider('Yaw into roll', 'neckMixYawToRoll', -2, 2, '%+.2f')
      __CPC.slider('Roll into yaw', 'neckMixRollToYaw', -2, 2, '%+.2f')
      __CPC.section('NON-RECURSIVE POSITION MIXES')
      __CPC.drawSectionPresets('neckPositionMix')
      __CPC.slider('X lateral into Z forward/back', 'neckMixXToZ', -2, 2, '%+.2f')
      __CPC.slider('Z forward/back into X lateral', 'neckMixZToX', -2, 2, '%+.2f')
      __CPC.slider('Y vertical into Z forward/back', 'neckMixYToZ', -2, 2, '%+.2f')
      __CPC.slider('Z forward/back into Y vertical', 'neckMixZToY', -2, 2, '%+.2f')

      __CPC.section('DIRECTION FOLLOWING')
      __CPC.drawSectionPresets('neckFollow')
      __CPC.toggle('Follow car sliding direction', 'neckSlideFollowing')
      __CPC.slider('Slide following amount', 'neckSlidingLookMult', 0, 1.5, '%.2f')
      __CPC.toggle('Follow track trajectory', 'neckTrackFollowing')
      __CPC.slider('Track following amount', 'neckTrackFollowingMult', 0, 1.5, '%.2f')
      __CPC.slider('Track look-ahead distance', 'neckLookaheadDistance', 5, 50, '%.0f m')
      __CPC.slider('Steering fallback amount', 'neckSteeringMult', 0, 2, '%.2f')
    end

    __CPC.section('NECKFX CONTROLS')
    if ui.button('STATIC HEAD') then __CPC.setStaticNeck() end
    ui.sameLine()
    if ui.button('RESET NECKFX') then __CPC.copyDefaultsWithPrefix('neck') end
  end

  function __CPC.drawSimpleSuitePanel()
    __CPC.section('SIMPLE SUITE',
      'A minimal setup for drivers who only want throttle FOV, one forward motion and four neck axes. Applying it clears every other camera channel.')
    if ui.button('APPLY SIMPLE SUITE', vec2(ui.availableSpaceX(), 32)) then
]====]
