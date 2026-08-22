return [====[
      [8] = 'Help: choose Big Panel for all settings or Compact for the essential controls while driving.'
    }
    ui.textWrapped(guide[__CPC.settings.uiPage] or '')
    ui.separator()
  end

  function __CPC.drawClutchPage()
    if not __CPC.drawingSubwheelSettings then
      __CPC.section('ADAPTIVE CLUTCH')
      __CPC.toggle('Enable clutch assist', 'clutchEnabled')
      ui.sameLine()
      ui.textColored(__CPC.clutchStatus, __CPC.clutchStateColor())
      ui.progressBar(1 - math.min(__CPC.telemetry.rawClutch, __CPC.clutchCommand),
        vec2(ui.availableSpaceX(), 18), string.format('Effective clutch pressed %.0f%%',
          (1 - math.min(__CPC.telemetry.rawClutch, __CPC.clutchCommand)) * 100))
    end

    if __CPC.settings.clutchPage == 1 then
      __CPC.section('CORE ASSISTS')
      __CPC.drawSectionPresets('clutchAssists')
      __CPC.toggle('Adaptive standing launch', 'clutchLaunchEnabled')
      __CPC.toggle('Predictive anti-stall', 'clutchAntiStallEnabled')
      __CPC.toggle('Automatic clutch on shifts', 'clutchShiftEnabled')
      __CPC.toggle('Use wheel angle for low-speed engine load', 'clutchTurnAware')
      __CPC.toggle('Activate clutch with handbrake', 'clutchHandbrakeEnabled',
        'Disengages the clutch while the handbrake is pressed.')
      __CPC.toggle('Turn-transition / drift clutch kick', 'clutchKickEnabled')

      __CPC.section('LIVE DIAGNOSIS')
      local rpmDirection = __CPC.rpmTrend > 120 and 'RISING'
        or (__CPC.rpmTrend < -120 and 'FALLING' or 'STEADY')
      ui.text(string.format('RPM %.0f   %s %+.0f RPM/s', __CPC.telemetry.rpm, rpmDirection, __CPC.rpmTrend))
      ui.text(string.format('Launch target %.0f RPM   Kick ceiling %.0f RPM',
        __CPC.telemetry.launchRPM, __CPC.telemetry.kickRPM))
      ui.text(string.format('Command %.3f   Target %.3f   Physical pedal %.3f',
        __CPC.clutchCommand, __CPC.clutchTarget, __CPC.telemetry.rawClutch))
      ui.textWrapped('Clutch polarity is coupled at 100% and pressed at 0%. CSP combines this command with the physical pedal using the lower value, so the driver retains priority.')

    elseif __CPC.settings.clutchPage == 2 then
      __CPC.section('STANDING LAUNCH',
        'Road speed and RPM jointly control how quickly the clutch couples.')
      __CPC.drawSectionPresets('clutchLaunch')
      __CPC.slider('Engine speed for launch', 'clutchLaunchRPMPercent', 10, 50, '%.0f%%',
        'Choose how high the engine revs before the launch clutch starts to release.')
      __CPC.slider('Finish launch by speed', 'clutchLaunchEndSpeed', 5, 35, '%.1f km/h',
        'The clutch is fully released once the car reaches this speed.')
      __CPC.slider('Pedal needed for launch', 'clutchLaunchThrottle', 0.02, 0.50, '%.2f',
        'Sets how far you must press the throttle before launch assistance begins.')

      __CPC.section('LAUNCH CONTROL',
        'Hold the dump button at a stop to lock first gear, hold the clutch at bite and apply throttle. Release the button to dump. Shift lights fill toward launch RPM and flash when ready. CSP can only raise the throttle, not cut a floored pedal.')
      __CPC.toggle('Enable hold-to-dump launch control', 'clutchLaunchControlEnabled',
        'Takes priority over adaptive standing launch while the dump button is held and speed is low.')
      ui.textColored(__CPC.launchControlArmed
        and (__CPC.launchControlReady and 'LAUNCH READY' or 'LAUNCH HOLD')
        or 'Launch idle',
        __CPC.launchControlArmed and __CPC.Theme.COLOR_ACTION or __CPC.Theme.COLOR_MUTED)
      if __CPC.launchDumpButton and __CPC.launchDumpButton.control then
        ui.text('Dump button')
        __CPC.launchDumpButton:control(vec2(ui.availableSpaceX(), 28), nil, 'Click to bind')
      else
        ui.textColored('Dump button binding is unavailable in this CSP build.', __CPC.Theme.COLOR_WARNING)
      end
      __CPC.slider('Clutch bite while held', 'clutchLaunchControlBite', 0.08, 0.60, '%.2f',
        '0 is fully pressed, 1 is fully coupled. Lower values hold more slip while you build RPM.')
      __CPC.slider('Throttle applied while held', 'clutchLaunchControlThrottle', 0.20, 1.00, '%.2f',
        'Applied as a throttle floor while launch is held. Your pedal can still add more.')

      __CPC.section('PREDICTIVE ANTI-STALL',
        'Falling RPM is projected forward; wheel angle and brake load can add safety margin.')
      __CPC.drawSectionPresets('clutchAntiStall')
      __CPC.slider('RPM margin above idle', 'clutchAntiStallMargin', 150, 1000, '%.0f RPM')
      __CPC.slider('Maximum anti-stall speed', 'clutchAntiStallSpeed', 10, 80, '%.0f km/h')
      __CPC.slider('RPM prediction time', 'clutchRPMLookahead', 0.02, 0.35, '%.2f s')
      __CPC.slider('Brake hold threshold', 'clutchBrakeThreshold', 0.02, 0.70, '%.2f')
      __CPC.slider('Wheel load starts at', 'clutchTurnLoadStart', 0.05, 0.80, '%.2f')
      __CPC.slider('Extra turning RPM margin', 'clutchTurnExtraMargin', 0, 900, '%.0f RPM')

    else
      __CPC.section('CLUTCH TIMING')
      __CPC.drawSectionPresets('clutchTiming')
      __CPC.slider('Press speed', 'clutchPressRate', 4, 40, '%.1f /s')
      __CPC.slider('Release speed', 'clutchReleaseRate', 1, 16, '%.1f /s')
      __CPC.slider('Shift clutch hold', 'clutchShiftHold', 0.03, 0.25, '%.3f s')
      __CPC.slider('Shift release time', 'clutchShiftRelease', 0.04, 0.45, '%.3f s')

      __CPC.section('TURN / DRIFT KICK',
        'A short clutch pulse can fire on falling RPM or a left/right wheel transition.')
      __CPC.drawSectionPresets('clutchKick')
      __CPC.toggle('Enable drift clutch kick', 'clutchKickEnabled')
      __CPC.slider('Kick below RPM (% usable range)', 'clutchKickRPMPercent', 20, 85, '%.0f%%')
      __CPC.slider('Minimum throttle', 'clutchKickThrottle', 0.20, 1.00, '%.2f')
      __CPC.slider('Minimum wheel input', 'clutchKickSteer', 0.08, 0.95, '%.2f')
      __CPC.slider('Minimum road speed', 'clutchKickMinSpeed', 5, 100, '%.0f km/h')
      __CPC.slider('Kick duration', 'clutchKickDuration', 0.03, 0.22, '%.3f s')
      __CPC.slider('Kick cooldown', 'clutchKickCooldown', 0.20, 2.00, '%.2f s')
      __CPC.slider('Engine-speed drop to trigger', 'clutchKickRPMDrop', 100, 2500, '%.0f RPM/s',
        'Sets how quickly engine speed must fall before a clutch kick can happen.')
    end

    if ui.button('RESET CLUTCH') then
      __CPC.copyDefaultsWithPrefix('clutch')
      __CPC.resetClutchRuntime(ac.getCar(__CPC.PLAYER))
    end
  end

  function __CPC.drawAutoGearPage()
    __CPC.section('GEAR TRACKER', 'When a gear change is detected, the tracker runs a back/up shift pattern for a configurable 6-step cycle. Requires CSP control override.')
    __CPC.toggle('Enable gear tracker assist', 'autoGearEnabled')
    ui.sameLine()
    ui.textColored(__CPC.autoGearStatus, __CPC.autoGearStateColor())

    __CPC.section('CYCLE CONTROL')
    __CPC.slider('Cycle steps', 'autoGearTrackerSteps', 2, 12, '%.0f')
    __CPC.slider('Delay between cycle steps', 'autoGearTrackerStepInterval', 0.02, 0.40, '%.2f s')
    __CPC.slider('Shift confirmation timeout', 'autoGearTrackerConfirmTimeout', 0.05, 0.80, '%.2f s')
    __CPC.slider('Minimum time between shifts', 'autoGearMinShiftInterval', 0.05, 1.50, '%.2f s')

    __CPC.section('BEHAVIOUR NOTES')
    ui.textWrapped('Step 1 starts with a back shift. Step 2 shifts up. This alternates until the selected cycle step count is complete. If a step cannot shift in the preferred direction, the tracker tries the opposite direction.')

    __CPC.section('LIVE DIAGNOSIS')
    ui.text(string.format('Gear %d   Speed %.0f km/h   Cycle active %s',
      __CPC.telemetry.gear, __CPC.telemetry.speed,
      __CPC.autoGearTrackerActive and 'YES' or 'NO'))
    ui.text(string.format('Cycle step %d / %.0f   Waiting shift %s',
      (__CPC.autoGearTrackerStepIndex or 0) + 1,
      __CPC.settings.autoGearTrackerSteps,
      __CPC.autoGearTrackerAwaitingShift and 'YES' or 'NO'))

    __CPC.section('RESET')
    if ui.button('RESET GEAR TRACKER') then
      __CPC.copyDefaultsWithPrefix('autoGear')
      __CPC.resetAutoGearRuntime(ac.getCar(__CPC.PLAYER))
    end
  end

  function __CPC.drawLinearChannel(channel)
    local keys = channel.keys
    local state = __CPC.linearState[channel.base]
    __CPC.section(channel.label .. ' - ' .. string.upper(channel.axis) .. ' AXIS',
      channel.hint)
    __CPC.drawLinearChannelPresets(channel)
    __CPC.toggle('Enable', keys.enabled)
    ui.sameLine()
    ui.textColored(string.format('%+0.2f mm live', state.value * 1000),
      math.abs(state.value) > 0.00005 and __CPC.Theme.COLOR_ACTIVE or __CPC.Theme.COLOR_MUTED)
    __CPC.slider('Movement amount', keys.distance, -channel.distRange, channel.distRange, '%+.4f m',
      'Sets how far this effect can move the camera.')
    __CPC.reverseToggle('Reverse direction', keys.reverse)
    local atFullFormat = (channel.atFullMax > 20 and '%.0f ' or '%.3f ') .. channel.unit
    __CPC.slider('Reaches full at', keys.atFull, channel.atFullMin, channel.atFullMax,
      atFullFormat)
    __CPC.slider('How the effect builds', keys.curve, 0.20, 4.0, '%.2f',
      'Lower values start the movement sooner. Higher values hold it back until the input is stronger.')
    __CPC.slider('Move-in speed', keys.speed, 0.1, 60, '%.1f',
      'Sets how quickly this effect begins.')
    __CPC.slider('Return speed', keys.releaseSpeed, 0, 60, '%.1f',
      'Sets how quickly this effect returns to rest. Zero uses the move-in speed.')
    if channel.oscillator then
      if channel.frequency then
        __CPC.slider('Frequency per 1000 rpm', keys.frequency, 0.1, 20, '%.2f Hz')
      else
        __CPC.slider('Vibration frequency', keys.frequency, 0.5, 60, '%.1f Hz')
      end
    end
    __CPC.slider('Maximum movement (zero is unlimited)', keys.limit, 0, channel.distRange * 2, '%.4f m',
      'Limits the movement from this effect. Zero leaves it unlimited.')
    __CPC.slider('Start effect at speed', keys.gateStart, 0, 300, '%.0f km/h',
      'This effect begins to fade in at this road speed.')
    __CPC.slider('Full effect at speed', keys.gateFull, 1, 400, '%.0f km/h',
      'This effect reaches full strength at this road speed.')
    __CPC.slider('Speed build-up', keys.gateCurve, 0.20, 4.0, '%.2f',
      'Lower values build the effect sooner; higher values delay it to faster speeds.')
    if __CPC.settings[keys.fovMix] ~= nil then
      __CPC.slider('Into FOV', keys.fovMix, -20, 20, '%+.2f deg')
      __CPC.slider('FOV source limit', keys.fovLimit, 0, 20, '%.1f deg')
    end
    ui.text(string.format('Shaped input %+.0f%%   target %+0.2f mm',
      state.norm * 100, state.target * 1000))
  end
]====]
