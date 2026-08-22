return [====[

  function __CPC.drawLinearPage()
    __CPC.section('CAMERA MOVEMENT EFFECTS',
      'Each effect can move the camera in a different direction. Use the presets first, then change only the amount and speed if you need a different feel.')
    __CPC.drawSectionPresets('linearMaster')
    __CPC.toggle('Enable all linear translation effects', 'throttleDynamicsEnabled')
    __CPC.toggle('Enable extended linear channels', 'throttleLinearMasterEnabled',
      'Turns the eleven newer channels on or off without touching the five original ones.')
    __CPC.slider('Linear master scale', 'throttleLinearMasterScale', 0, 3.0, '%.2fx')

    local groupWidth = math.max(96, (ui.availableSpaceX() - 15) / 4)
    for index = 1, #__CPC.LINEAR_GROUPS do
      __CPC.settings.throttleLinearPage = __CPC.tabButton(__CPC.settings.throttleLinearPage,
        index, __CPC.LINEAR_GROUPS[index], groupWidth, 'linear')
      if index % 4 ~= 0 and index < #__CPC.LINEAR_GROUPS then ui.sameLine(0, 5) end
    end

    local shown = 0
    for index = 1, #__CPC.LINEAR_CHANNELS do
      local channel = __CPC.LINEAR_CHANNELS[index]
      if channel.group == __CPC.settings.throttleLinearPage then
        __CPC.drawLinearChannel(channel)
        shown = shown + 1
      end
    end
    if shown == 0 then ui.textWrapped('No channels in this group.') end

    __CPC.section('LINEAR AXIS SUMMARY')
    ui.text(string.format('Channel sum X/Y/Z: %+.1f / %+.1f / %+.1f mm',
      __CPC.linearAxis.x * 1000, __CPC.linearAxis.y * 1000, __CPC.linearAxis.z * 1000))
    ui.text(string.format('Applied X/Y/Z: %+.1f / %+.1f / %+.1f mm   FOV from linear %+.2f deg',
      __CPC.outputLateral * 1000, __CPC.outputVertical * 1000, __CPC.outputForward * 1000, __CPC.linearRuntime.fovMix))
    ui.text(string.format('Long / lat / vert G: %+.2f / %+.2f / %+.2f   Slip %+.1f deg',
      __CPC.linearFrame.longG, __CPC.linearFrame.latG, __CPC.linearFrame.vertG, __CPC.linearFrame.slipAngle))
    ui.text(string.format('Yaw rate %+.2f rad/s   Wheel rate %+.2f turn/s   Rumble %+.2f G',
      __CPC.linearFrame.yawRate, __CPC.linearFrame.steerRate, __CPC.linearFrame.rumbleG))
    ui.text(string.format('Revs %.0f (%.0f%%)   Boost %.2f bar   Slip excess %.2f   Shift pulse %+.2f',
      __CPC.linearFrame.rpm, __CPC.linearFrame.rpmRatio * 100, __CPC.linearFrame.boost,
      __CPC.linearFrame.tyreSlip, __CPC.linearFrame.shiftPulse))
  end

  function __CPC.drawThrottleAdvancedPage()
    __CPC.section('SMOOTHING MODEL',
      'Exponential is the classic first-order follow. Critical damp adds velocity so channels settle without overshoot on sharp inputs.')
    local modeWidth = math.max(150, (ui.availableSpaceX() - 5) / 2)
    for index = 1, #__CPC.SMOOTHING_NAMES do
      __CPC.settings.throttleSmoothingMode = __CPC.tabButton(__CPC.settings.throttleSmoothingMode,
        index, __CPC.SMOOTHING_NAMES[index], modeWidth, 'smoothing')
      if index < #__CPC.SMOOTHING_NAMES then ui.sameLine(0, 5) end
    end

    __CPC.section('MASTER OUTPUT SCALING')
    __CPC.drawSectionPresets('outputScaling')
    __CPC.slider('Translation master scale', 'throttleMasterTranslationScale', 0, 3.0, '%.2fx')
    __CPC.slider('Angle master scale', 'throttleMasterAngleScale', 0, 3.0, '%.2fx')
    __CPC.slider('Linear channel master scale', 'throttleLinearMasterScale', 0, 3.0, '%.2fx')

    __CPC.section('FINAL MOVEMENT LIMITS',
      'These limits keep the camera from moving farther than you choose, even when several effects are active together.')
    __CPC.drawSectionPresets('finalClamps')
    __CPC.slider('Maximum side-to-side movement', 'throttleOutputLimitX', 0, 0.60, '%.4f m')
    __CPC.slider('Maximum up/down movement', 'throttleOutputLimitY', 0, 0.60, '%.4f m')
    __CPC.slider('Maximum forward/back movement', 'throttleOutputLimitZ', 0, 0.80, '%.4f m')

    __CPC.section('MIXED FOV SHAPING')
    __CPC.drawSectionPresets('mixedFovShape')
    __CPC.slider('Mixed FOV return speed (0 = match)', 'throttleFovMixReturnSpeed', 0, 60, '%.1f')
    __CPC.slider('Mixed FOV deadzone', 'throttleFovMixDeadzone', 0, 5.0, '%.2f deg')

    __CPC.section('BULK ACTIONS')
    if ui.button('MATCH EVERY CHANNEL SPEED TO Z', vec2(ui.availableSpaceX(), 0)) then
      __CPC.matchThrottleSpeeds()
    end
    if ui.button('CLEAR EVERY RELEASE OVERRIDE', vec2(ui.availableSpaceX(), 0)) then
      __CPC.clearThrottleReleaseOverrides()
    end
    if ui.button('CLEAR EVERY CHANNEL CLAMP', vec2(ui.availableSpaceX(), 0)) then
      __CPC.clearThrottleChannelClamps()
    end
    if ui.button('OPEN EVERY SPEED GATE', vec2(ui.availableSpaceX(), 0)) then
      __CPC.openThrottleSpeedGates()
    end
    ui.textWrapped('Release overrides fall back to each attack speed, cleared clamps remove per-channel ceilings, and open gates make every channel active from a standstill.')
  end

  function __CPC.drawThrottleSyncControls()
    __CPC.section('MAIN CAMERA MOVEMENT',
      'Set your base cockpit pose, view angle, and forward/back camera movement together.')
    __CPC.drawSectionPresets('syncedBase')

    __CPC.slider('Overall motion update rate', 'motionUpdateFps', 30, 280, '%.0f FPS',
      'Caps camera and NeckFX motion calculations. Higher values use more CPU and cannot exceed the game update rate.')

    local fovMin, fovMax = __CPC.fovHardBounds()
    __CPC.slider('View angle with throttle released', 'throttleRestingFov', fovMin, math.min(150, fovMax), '%.0f deg')
    if __CPC.settings.throttleMaximumFov < __CPC.settings.throttleRestingFov then
      __CPC.settings.throttleMaximumFov = __CPC.settings.throttleRestingFov
    end
    __CPC.slider('View angle at full throttle', 'throttleMaximumFov',
      __CPC.settings.throttleRestingFov, fovMax, '%.0f deg')
    __CPC.slider('Move camera forward', 'throttleForwardDistance', 0, 1.00, '%.3f m')
    __CPC.slider('Move camera back', 'throttleBackDistance', 0, 1.00, '%.3f m')
    __CPC.slider('Camera movement speed', 'throttleTransitionSpeed', 0.20, 30.0, '%.1f')
    __CPC.slider('View-angle change speed', 'throttleFovTransitionSpeed', 0.20, 30.0, '%.1f',
      'Sets how quickly the view angle changes, separately from the camera movement above.')

    ui.separator()
    ui.textColored('STARTING CAMERA POSE', __CPC.accentColor())
    ui.textDisabled('Offsets are relative to the car saved seat and remain active at zero throttle.')
    __CPC.drawSectionPresets('startPose')
    __CPC.drawCameraPoseNudgePad()
    __CPC.slider('Start X - left / right', 'throttleStartX', -0.30, 0.30, '%+.3f m')
    __CPC.slider('Start Y - down / up', 'throttleStartY', -0.30, 0.30, '%+.3f m')
    __CPC.slider('Start Z - back / forward', 'throttleStartZ', -1.00, 1.00, '%+.3f m')
    __CPC.slider('Start pitch - down / up', 'throttleStartPitch', -30, 30, '%+.1f deg')
    if ui.button('ZERO STARTING POSE') then __CPC.zeroThrottleStartPose() end

    ui.separator()
    ui.textColored('OPTIONAL UP/DOWN MOVEMENT', __CPC.accentColor())
    __CPC.toggle('Move view up and down with camera', 'throttleSyncedYEnabled')
    __CPC.slider('Move view down at full throttle', 'throttleSyncedYDownDistance', 0, 1.00, '%.3f m')
    __CPC.slider('Move view up with throttle released', 'throttleSyncedYUpDistance', 0, 1.00, '%.3f m')
    ui.textDisabled('Moving forward lowers the view; moving back raises it. This also follows the optional speed-based camera movement below.')

    ui.separator()
    ui.textColored('OPTIONAL SPEED-BASED MOVEMENT', __CPC.accentColor())
    __CPC.toggle('Add movement as the car speeds up', 'throttleSpeedForwardEnabled')
    ui.textDisabled('While the throttle is pressed, road speed can slowly move the camera forward and widen the view. Releasing the throttle removes this extra movement.')
    __CPC.slider('Extra camera movement at top speed', 'throttleSpeedForwardDistance', 0, 1.00, '%.3f m')
    __CPC.slider('Extra view width at top speed', 'throttleSpeedFovWiden', 0, 80, '%.1f deg')
    __CPC.slider('Start extra movement at speed', 'throttleSpeedForwardStartKmh', 0, 300, '%.0f km/h')
    if __CPC.settings.throttleSpeedForwardFullKmh <= __CPC.settings.throttleSpeedForwardStartKmh then
      __CPC.settings.throttleSpeedForwardFullKmh = __CPC.settings.throttleSpeedForwardStartKmh + 1
    end
    __CPC.slider('Full extra movement at speed', 'throttleSpeedForwardFullKmh',
      __CPC.settings.throttleSpeedForwardStartKmh + 1, 500, '%.0f km/h')
    __CPC.slider('When speed movement builds', 'throttleSpeedForwardCurve', 0.20, 4.0, '%.2f')
    __CPC.slider('Speed-movement response', 'throttleSpeedLayerSpeed', 0.10, 15.0, '%.2f')
    ui.textWrapped('The same road-speed setting controls both the extra camera movement and the wider view. Lower values make it build sooner; higher values wait for more speed.')

    -- These old fields remain for preset/storage compatibility only. The synchronized
    -- base runtime above uses throttleTransitionSpeed directly.
    __CPC.settings.throttleForwardFovLink = false
    __CPC.settings.throttleForwardSpeed = __CPC.settings.throttleTransitionSpeed
    __CPC.settings.throttleFovWidenSpeed = __CPC.settings.throttleTransitionSpeed
    __CPC.settings.throttleFovReturnSpeed = __CPC.settings.throttleTransitionSpeed
  end

  function __CPC.drawThrottlePage()
    if not __CPC.drawingSubwheelSettings then
      __CPC.section('THROTTLE CAMERA')
      __CPC.toggle('Enable throttle seat and FOV camera', 'throttleEnabled')
      ui.sameLine()
      ui.textColored(__CPC.throttleStatus, __CPC.throttleStatus == 'Active in cockpit'
        and __CPC.Theme.COLOR_ACTIVE or __CPC.Theme.COLOR_MUTED)
      __CPC.drawThrottleSyncControls()
    end

    if __CPC.settings.throttlePage == 1 then
      __CPC.section('MASTER RESPONSE')
      __CPC.drawSectionPresets('throttleMaster')
      __CPC.slider('Overall effects speed', 'throttleOverallSpeed', 0.1, 3.0, '%.1fx')
      __CPC.slider('Throttle deadzone', 'throttleDeadzone', 0, 0.20, '%.3f')
      __CPC.slider('When camera movement starts', 'throttleCurve', 0.25, 3.0, '%.2f',
        'Lower values start camera movement earlier. Higher values wait for more throttle.')
      __CPC.slider('Pedal press response', 'throttleInputAttackSpeed', 0, 60, '%.1f')
      __CPC.slider('Pedal release response', 'throttleInputReleaseSpeed', 0, 60, '%.1f')
      __CPC.toggle('Use mph for effects cap', 'throttleEffectSpeedCapMph')
      local unit = __CPC.settings.throttleEffectSpeedCapMph and 'mph' or 'km/h'
      __CPC.slider('Effects start at', 'throttleEffectSpeedFloor', 0,
        __CPC.settings.throttleEffectSpeedCapMph and 120 or 200, '%.0f ' .. unit)
      __CPC.slider('Effects reach full at', 'throttleEffectSpeedCap', 1,
        __CPC.settings.throttleEffectSpeedCapMph and 200 or 320, '%.0f ' .. unit)
      __CPC.slider('When speed effects build', 'throttleSpeedGateCurve', 0.20, 4.0, '%.2f')
      ui.textWrapped('Camera movement and view changes build between the start and full speeds. Your chosen starting position stays fixed.')

      __CPC.section('LIVE OUTPUT')
      ui.text(string.format('Throttle / steering: %.0f%% / %+.0f%%',
        __CPC.throttleInput * 100, __CPC.steeringInput * 100))
      ui.text(string.format('Speed strength: %.0f%%   Current FOV: %.1f deg',
        __CPC.throttleEffectScale * 100, __CPC.renderedFov))
]====]
