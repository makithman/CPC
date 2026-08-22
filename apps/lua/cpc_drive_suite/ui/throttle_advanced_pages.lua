return [====[
      ui.text(string.format('Position X/Y/Z: %+.1f / %+.1f / %+.1f mm',
        __CPC.outputLateral * 1000, __CPC.outputVertical * 1000, __CPC.outputForward * 1000))
      ui.text(string.format('Pitch / yaw: %+.2f / %+.2f deg   FOV mix: %+.2f deg',
        __CPC.outputPitch, __CPC.outputYaw, __CPC.renderedFovMix * __CPC.throttleEffectScale))

    elseif __CPC.settings.throttlePage == 2 then
      __CPC.section('FORWARD/BACK CAMERA MOVEMENT')
      __CPC.drawSectionPresets('baseAxes')
      ui.textWrapped('The main forward/back movement is controlled at the top of this page. Use these controls only to fine-tune the movement direction and safety limits.')
      __CPC.reverseToggle('Reverse forward/back movement', 'throttleForwardReverse')
      __CPC.slider('Maximum forward/back movement', 'throttleForwardLimit', 0, 1.00, '%.4f m')
      __CPC.slider('Up/down camera movement', 'throttleVerticalDistance', -0.40, 0.40, '%+.4f m')
      __CPC.reverseToggle('Reverse up/down movement', 'throttleVerticalReverse')
      __CPC.slider('Up/down move-in speed', 'throttleVerticalSpeed', 0.1, 60, '%.1f')
      __CPC.slider('Up/down return speed', 'throttleVerticalReleaseSpeed', 0, 60, '%.1f')
      __CPC.slider('When up/down movement builds', 'throttleVerticalCurve', 0.20, 4.0, '%.2f')
      __CPC.slider('Maximum up/down movement', 'throttleVerticalLimit', 0, 0.40, '%.4f m')
      __CPC.slider('Side-to-side camera movement', 'throttleLateralDistance', -0.40, 0.40, '%+.4f m')
      __CPC.reverseToggle('Reverse side-to-side movement', 'throttleLateralReverse')
      __CPC.slider('Side-to-side move-in speed', 'throttleLateralSpeed', 0.1, 60, '%.1f')
      __CPC.slider('Side-to-side return speed', 'throttleLateralReleaseSpeed', 0, 60, '%.1f')
      __CPC.slider('When side-to-side movement builds', 'throttleLateralCurve', 0.20, 4.0, '%.2f')
      __CPC.slider('Maximum side-to-side movement', 'throttleLateralLimit', 0, 0.40, '%.4f m')
      __CPC.slider('Full steering effect at', 'throttleSteeringAtFull', 45, 1080, '%.0f deg')

    elseif __CPC.settings.throttlePage == 3 then
      __CPC.section('THROTTLE PITCH')
      __CPC.drawSectionPresets('throttlePitch')
      __CPC.slider('Pitch angle', 'throttlePitchAngle', -90, 90, '%+.2f deg')
      __CPC.reverseToggle('Reverse pitch movement', 'throttlePitchReverse')
      __CPC.slider('Pitch attack speed', 'throttlePitchSpeed', 0.1, 60, '%.1f')
      __CPC.slider('Pitch release speed (0 = match attack)', 'throttlePitchReleaseSpeed', 0, 60, '%.1f')
      __CPC.slider('Pitch input curve', 'throttlePitchCurve', 0.20, 4.0, '%.2f')
      __CPC.slider('Maximum view tilt', 'throttlePitchLimit', 0, 90, '%.2f deg')

      __CPC.section('THROTTLE + STEERING YAW')
      __CPC.drawSectionPresets('throttleYaw')
      __CPC.slider('Yaw angle', 'throttleYawAngle', -90, 90, '%+.2f deg')
      __CPC.reverseToggle('Reverse yaw movement', 'throttleYawReverse')
      __CPC.slider('Yaw attack speed', 'throttleYawSpeed', 0.1, 60, '%.1f')
      __CPC.slider('Yaw release speed (0 = match attack)', 'throttleYawReleaseSpeed', 0, 60, '%.1f')
      __CPC.slider('Yaw input curve', 'throttleYawCurve', 0.20, 4.0, '%.2f')
      __CPC.slider('Maximum side view turn', 'throttleYawLimit', 0, 90, '%.2f deg')
      ui.textWrapped('Yaw combines shaped throttle with steering direction.')

      __CPC.section('SPEED SYNCHRONIZATION')
      if ui.button('MATCH EVERY RESPONSE SPEED TO Z') then __CPC.matchThrottleSpeeds() end
      ui.textWrapped('This keeps FOV, X/Y/Z, pitch, yaw and mixed FOV response synchronized with forward/back motion.')

    elseif __CPC.settings.throttlePage == 4 then
      __CPC.section('FOV CONTROL',
        'Mix amounts are signed degrees. Each source limit is a hard cap applied after master strength.')
      local fovWidth = math.max(150, (ui.availableSpaceX() - 5) / 2)
      __CPC.settings.throttleFovPage = __CPC.tabButton(__CPC.settings.throttleFovPage,
        1, 'BASE', fovWidth, 'fov')
      ui.sameLine(0, 5)
      __CPC.settings.throttleFovPage = __CPC.tabButton(__CPC.settings.throttleFovPage,
        2, 'POSITION', fovWidth, 'fov')
      __CPC.settings.throttleFovPage = __CPC.tabButton(__CPC.settings.throttleFovPage,
        3, 'ANGLES', fovWidth, 'fov')
      ui.sameLine(0, 5)
      __CPC.settings.throttleFovPage = __CPC.tabButton(__CPC.settings.throttleFovPage,
        4, 'DYNAMIC', fovWidth, 'fov')

      if __CPC.settings.throttleFovPage == 1 then
        __CPC.section('BASE FOV')
        ui.textWrapped('Resting FOV, full-throttle FOV and their independent transition speeds are controlled by the synced section above.')

        __CPC.section('FOV SAFETY RANGE')
        __CPC.slider('Absolute minimum FOV', 'throttleFovHardMin', 10, 169, '%.0f deg',
          'Hard safety floor applied after every other FOV effect. Right-click resets.')
        if __CPC.settings.throttleFovHardMax <= __CPC.settings.throttleFovHardMin then
          __CPC.settings.throttleFovHardMax = __CPC.settings.throttleFovHardMin + 1
        end
        __CPC.slider('Absolute maximum FOV', 'throttleFovHardMax',
          __CPC.settings.throttleFovHardMin + 1, 179, '%.0f deg',
          'Hard safety ceiling applied after every other FOV effect. Right-click resets.')

        __CPC.section('FOV MIX MASTER')
        __CPC.drawSectionPresets('fovMaster')
        __CPC.slider('Mixed FOV strength', 'throttleFovMixStrength', 0, 2, '%.2fx')
        __CPC.slider('Mixed FOV response speed', 'throttleFovMixSpeed', 0.5, 30, '%.1f')
        __CPC.slider('Maximum total mixed FOV offset', 'throttleFovMixLimit', 0, 40, '%.1f deg')

        __CPC.section('TRUE VEHICLE-SPEED FOV')
        __CPC.drawSectionPresets('speedFov')
        __CPC.slider('Legacy speed-FOV mix (ignored)', 'throttleFovSpeedMix', -20, 20, '%+.1f deg')
        __CPC.slider('Legacy speed-FOV limit (ignored)', 'throttleFovSpeedLimit', 0, 20, '%.1f deg')
        ui.textDisabled('Speed-forward FOV now uses the same degrees-per-metre slope as synced Z. The legacy speed-FOV mix below is not added twice.')
        __CPC.slider('Legacy speed FOV starts at', 'throttleFovSpeedStartKmh', 0, 300, '%.0f km/h')
        if __CPC.settings.throttleFovSpeedFullKmh <= __CPC.settings.throttleFovSpeedStartKmh then
          __CPC.settings.throttleFovSpeedFullKmh = __CPC.settings.throttleFovSpeedStartKmh + 10
        end
        __CPC.slider('Legacy speed FOV reaches full at', 'throttleFovSpeedFullKmh',
          __CPC.settings.throttleFovSpeedStartKmh + 10, 400, '%.0f km/h')
        __CPC.slider('Legacy speed FOV response curve', 'throttleFovSpeedCurve', 0.25, 3.0, '%.2f')

      elseif __CPC.settings.throttleFovPage == 2 then
        __CPC.section('POSITION TO FOV')
        __CPC.drawSectionPresets('positionFov')
        __CPC.slider('Legacy synced-Z FOV mix (ignored)', 'throttleFovForwardMix', -20, 20, '%+.1f deg')
        __CPC.slider('Legacy synced-Z FOV limit (ignored)', 'throttleFovForwardLimit', 0, 20, '%.1f deg')
        __CPC.slider('Vertical motion into FOV', 'throttleFovVerticalMix', -10, 10, '%+.1f deg')
        __CPC.slider('Vertical source limit', 'throttleFovVerticalLimit', 0, 10, '%.1f deg')
        __CPC.slider('Lateral motion into FOV', 'throttleFovLateralMix', -10, 10, '%+.1f deg')
        __CPC.slider('Lateral source limit', 'throttleFovLateralLimit', 0, 10, '%.1f deg')

      elseif __CPC.settings.throttleFovPage == 3 then
        __CPC.section('ANGLE TO FOV')
        __CPC.drawSectionPresets('angleFov')
        __CPC.slider('Pitch into FOV', 'throttleFovPitchMix', -10, 10, '%+.1f deg')
        __CPC.slider('Pitch source limit', 'throttleFovPitchLimit', 0, 10, '%.1f deg')
        __CPC.slider('Yaw into FOV', 'throttleFovYawMix', -10, 10, '%+.1f deg')
        __CPC.slider('Yaw source limit', 'throttleFovYawLimit', 0, 10, '%.1f deg')

      else
        __CPC.section('DYNAMIC EFFECTS TO FOV',
          'These sources follow their smoothed Dynamics movement and become zero when that movement is disabled.')
        __CPC.drawSectionPresets('dynamicFov')
        __CPC.slider('Acceleration G into FOV', 'throttleFovAccelGMix', -10, 10, '%+.1f deg')
        __CPC.slider('Acceleration G source limit', 'throttleFovAccelGLimit', 0, 10, '%.1f deg')
        __CPC.slider('Brake G into FOV', 'throttleFovBrakeGMix', -10, 10, '%+.1f deg')
        __CPC.slider('Brake G source limit', 'throttleFovBrakeGLimit', 0, 10, '%.1f deg')
        __CPC.slider('Suspension heave into FOV', 'throttleFovHeaveMix', -10, 10, '%+.1f deg')
        __CPC.slider('Suspension heave source limit', 'throttleFovHeaveLimit', 0, 10, '%.1f deg')
        __CPC.slider('Drift / slip into FOV', 'throttleFovDriftMix', -10, 10, '%+.1f deg')
        __CPC.slider('Drift / slip source limit', 'throttleFovDriftLimit', 0, 10, '%.1f deg')
        __CPC.slider('Impact recoil into FOV', 'throttleFovImpactMix', -10, 10, '%+.1f deg')
        __CPC.slider('Impact recoil source limit', 'throttleFovImpactLimit', 0, 10, '%.1f deg')
      end

      __CPC.section('FOV MIX LIVE OUTPUT')
      ui.text(string.format('Position / angle: %+.2f / %+.2f deg',
        __CPC.fovMixPositionTarget, __CPC.fovMixAngleTarget))
      ui.text(string.format('Dynamics / speed: %+.2f / %+.2f deg   Speed curve %.0f%%',
        __CPC.fovMixDynamicTarget, __CPC.fovMixSpeedTarget, __CPC.fovSpeedBlend * 100))
      ui.text(string.format('Smoothed mixed offset: %+.2f deg',
        __CPC.renderedFovMix * __CPC.throttleEffectScale))

    elseif __CPC.settings.throttlePage == 5 then
      __CPC.section('GEAR-SHIFT CAMERA ISOLATION',
        'Prevents a gear change from pulling the throttle/FOV camera back or adding a longitudinal G-force kick.')
      __CPC.drawSectionPresets('shiftIsolation')
      __CPC.toggle('Enable gear-shift isolation', 'throttleGearIsolationEnabled')
      __CPC.toggle('Hold throttle camera and FOV through shifts', 'throttleGearIsolationFov',
        'Holds the pre-shift throttle target so FOV, position and angle motion stay stable during the shift.')
      __CPC.toggle('Filter NeckFX longitudinal G-force kick', 'throttleGearIsolationGForce',
        'Freezes only Z movement and G-force pitch during a shift. Cornering, road and speed effects continue normally.')
      __CPC.slider('Shift isolation time', 'throttleGearIsolationTime', 0.05, 1.0, '%.2f s',
        'How long the pre-shift motion target is protected after a gear request or detected gear change.')

      __CPC.section('FILTER STATUS')
      local isolationDuration = math.max(__CPC.settings.throttleGearIsolationTime, 0.05)
      local isolationStrength = __CPC.gearIsolationActive
        and __CPC.Math.saturate(__CPC.gearIsolationRemaining / isolationDuration) or 0
      ui.progressBar(isolationStrength, vec2(ui.availableSpaceX(), 18),
        __CPC.gearIsolationActive and 'SHIFT ISOLATION ACTIVE' or 'Ready for next gear change')
      ui.text(string.format('Protected throttle target: %.0f%%',
        __CPC.gearIsolationHeldThrottle * 100))
      ui.textWrapped('The filter reacts to paddle or H-pattern requests and to actual gear changes. It does not disable normal acceleration, braking or cornering movement outside the short isolation window.')

      __CPC.section('GEAR ANTICIPATION',
        'Gently prepares the camera near the limiter while the throttle is held, before the upshift request.')
      __CPC.toggle('Enable gear anticipation', 'throttleGearAnticipationEnabled')
      __CPC.slider('Anticipate from engine speed', 'throttleGearAnticipationRpm', 0.50, 0.99, '%.2f ratio')
      __CPC.slider('Minimum throttle for anticipation', 'throttleGearAnticipationThrottle', 0, 0.95, '%.2f')
      __CPC.slider('Anticipation camera movement', 'throttleGearAnticipationDistance', -0.10, 0.10, '%+.3f m')
      __CPC.slider('Anticipation view-width change', 'throttleGearAnticipationFov', -10, 10, '%+.1f deg')
      __CPC.slider('Anticipation response speed', 'throttleGearAnticipationSpeed', 0.1, 30, '%.1f')
      ui.text(string.format('Anticipation: %.0f%%', __CPC.renderedGearAnticipation * 100))

    elseif __CPC.settings.throttlePage == 6 then
      __CPC.drawLinearPage()

    elseif __CPC.settings.throttlePage == 7 then
      __CPC.section('CORNER ENTRY / EXIT',
        'Entry responds to braking while steering; exit responds to throttle while steering. Both are speed-gated and use the camera safety limits.')
      __CPC.toggle('Enable corner-entry response', 'throttleCornerEntryEnabled')
      __CPC.slider('Entry camera movement', 'throttleCornerEntryDistance', -0.10, 0.10, '%+.3f m')
      __CPC.slider('Entry view-width change', 'throttleCornerEntryFov', -10, 10, '%+.1f deg')
]====]
