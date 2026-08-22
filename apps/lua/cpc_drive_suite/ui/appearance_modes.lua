return [====[
      __CPC.applySimpleSuitePreset()
    end
    __CPC.toggle('Throttle seat and FOV camera', 'throttleEnabled')
    ui.sameLine()
    __CPC.toggle('NeckFX layer', 'neckEnabled')

    __CPC.drawThrottleSyncControls()

    __CPC.section('HEAD MOVEMENT',
      'The car moving forward, sideways, and over bumps moves your view. Sliding turns your view.')
    __CPC.drawSectionPresets('simpleFourAxis')
    __CPC.slider('Head movement sensitivity', 'neckGForceAtFull', 0.2, 6.0, '%.2f G')
    __CPC.slider('Head movement speed', 'neckOverallSpeed', 0.1, 3.0, '%.1fx')
    __CPC.slider('Forward/back head movement', 'neckMoveZDistance', -0.12, 0.12, '%+.3f m')
    __CPC.slider('Side-to-side head movement', 'neckMoveXDistance', -0.12, 0.12, '%+.3f m')
    __CPC.slider('Up/down head movement', 'neckMoveYDistance', -0.08, 0.08, '%+.3f m')
    __CPC.slider('Head turn while sliding', 'neckYawAngle', -30, 30, '%+.1f deg')
    ui.text(string.format('Neck live XYZ %+.1f / %+.1f / %+.1f mm   yaw %+.2f deg',
      __CPC.neckTelemetry.outputX * 1000, __CPC.neckTelemetry.outputY * 1000,
      __CPC.neckTelemetry.outputZ * 1000, __CPC.neckTelemetry.outputYaw))
    ui.text(string.format('Camera FOV %.1f deg   forward %+.1f mm', __CPC.renderedFov,
      __CPC.outputForward * 1000))

    __CPC.section('DRIFT YAW LOOK',
      'Slip angle turns the head into the slide, with an optional slide-direction look on top.')
    __CPC.drawSectionPresets('driftLook')
    __CPC.slider('Drift yaw angle', 'neckDriftYawAngle', 0, 45, '%.1f deg')
    __CPC.reverseToggle('Reverse drift yaw', 'neckDriftYawReverse')
    __CPC.slider('Drift yaw response', 'neckDriftYawSpeed', 0.5, 30, '%.1f')
    __CPC.slider('Drift yaw rearward travel', 'neckDriftYawBackDistance', 0, 0.15, '%.3f m')
    __CPC.toggle('Reverse drift rearward travel', 'neckDriftYawBackReverse')
    __CPC.toggle('Look into the slide', 'neckSlideFollowing')
    if __CPC.settings.neckSlideFollowing and __CPC.settings.neckFollowScale <= 0 then
      __CPC.settings.neckFollowScale = 1.0
    end
    __CPC.slider('Look into slide amount', 'neckSlidingLookMult', 0, 1.5, '%.2f')
    __CPC.slider('Steering fallback amount', 'neckSteeringMult', 0, 2.0, '%.2f')
    __CPC.slider('Drift look master scale', 'neckFollowScale', 0, 3.0, '%.2fx')
    ui.text(string.format('Slip %+.1f deg   neck yaw %+.2f deg', __CPC.dynamicSlipAngle,
      __CPC.neckTelemetry.outputYaw))
    ui.textWrapped('These sliders edit the same values as the THROTTLE and NECKFX tabs, so a simple tune stays visible everywhere.')
  end

  function __CPC.drawAppearancePage()
    if __CPC.settings.lookPage == 1 then
      __CPC.drawSimpleSuitePanel()
      return
    end

    __CPC.section('COLOR THEME', 'The selected accent applies to both dashboard and HUD.')
    local themeWidth = math.max(105, (ui.availableSpaceX() - 5) / 2)
    for index, name in ipairs(__CPC.Theme.THEME_NAMES) do
      local selected = __CPC.settings.colorTheme == index
      if ui.button((selected and '[ ' or '') .. name .. (selected and ' ]' or ''),
          vec2(themeWidth, 28)) then
        __CPC.settings.colorTheme = index
      end
      if index % 2 == 1 then ui.sameLine(0, 5) end
    end
    __CPC.slider('Dashboard title scale', 'uiScale', 0.80, 1.30, '%.2fx')

    __CPC.section('HUD LAYOUT')
    __CPC.drawSectionPresets('hudLayout')
    local layoutWidth = math.max(105, (ui.availableSpaceX() - 10) / 3)
    __CPC.settings.hudMode = __CPC.tabButton(__CPC.settings.hudMode, 1, 'FULL', layoutWidth, 'hud')
    ui.sameLine(0, 5)
    __CPC.settings.hudMode = __CPC.tabButton(__CPC.settings.hudMode, 2, 'INPUTS', layoutWidth, 'hud')
    ui.sameLine(0, 5)
    __CPC.settings.hudMode = __CPC.tabButton(__CPC.settings.hudMode, 3, 'MINIMAL', layoutWidth, 'hud')
    __CPC.slider('HUD glass and panel opacity', 'hudOpacity', 0.25, 1.0, '%.2f')
    __CPC.slider('HUD animation strength', 'hudAnimation', 0, 1.5, '%.2fx')
    __CPC.toggle('Display road speed in mph', 'hudSpeedMph')

    __CPC.section('HUD SECTIONS')
    __CPC.drawSectionPresets('hudSections')
    __CPC.toggle('Show RPM strip', 'hudShowRPM')
    __CPC.toggle('Show steering wheel', 'hudShowWheel')
    __CPC.toggle('Show pedal graphics', 'hudShowPedals')
    __CPC.toggle('Show camera output panel', 'hudShowCamera')
    __CPC.toggle('Show status ribbon', 'hudShowStatus')
    __CPC.toggle('Show G-force meter', 'hudShowGMeter')
    __CPC.toggle('Show shift-light bar', 'hudShowShiftLights')
    ui.textWrapped('The HUD is fully resizable. Full and Inputs use the steering wheel as a large circular instrument with pedals layered over it. Minimal keeps a compact RPM, gear, speed and status strip.')

    __CPC.section('RESET AND SAFETY')
    if ui.button('RESET HUD APPEARANCE') then
      local keys = {
        'colorTheme', 'uiScale', 'uiWheelScale', 'uiSliderLabelScale',
        'hudMode', 'hudOpacity', 'hudAnimation',
        'hudSpeedMph', 'hudShowWheel', 'hudShowPedals', 'hudShowCamera',
        'hudShowRPM', 'hudShowStatus', 'hudShowGMeter', 'hudShowShiftLights'
      }
      for _, key in ipairs(keys) do __CPC.settings[key] = __CPC.DEFAULTS[key] end
    end
    ui.sameLine()
    if not __CPC.resetEverythingArmed then
      if ui.button('RESET EVERYTHING') then __CPC.resetEverythingArmed = true end
    else
      if ui.button('CONFIRM FULL RESET') then
        for key, value in pairs(__CPC.DEFAULTS) do __CPC.settings[key] = value end
        __CPC.settings.settingsVersion = __CPC.DEFAULTS.settingsVersion
        __CPC.resetClutchRuntime(ac.getCar(__CPC.PLAYER))
        __CPC.resetThrottleMotion()
        __CPC.resetAutoGearRuntime(ac.getCar(__CPC.PLAYER))
        __CPC.resetEverythingArmed = false
      end
      ui.sameLine()
      if ui.button('CANCEL') then __CPC.resetEverythingArmed = false end
    end
    if __CPC.resetEverythingArmed then
      ui.textColored('Confirming will replace every saved suite value.', __CPC.Theme.COLOR_WARNING)
    else
      ui.textDisabled('Full reset needs a second confirmation and only changes this suite settings.')
    end

    __CPC.section('ABOUT')
    ui.text('CPC Drive Suite 3.10.0 - Unified Cockpit Motion')
    ui.textWrapped('One app replaces Adaptive Wheel Clutch, CPC Throttle Camera and CPC Dynamic 6DOF. The cockpit-camera file is a required NeckFX backend, not a separate shelf app.')
  end

  function __CPC.drawAppVersionPage()
    if __CPC.wheelHelpView == 2 then
      __CPC.drawHomePage()
      return
    elseif __CPC.wheelHelpView == 3 or __CPC.wheelHelpView == 4 then
      __CPC.drawAppearancePage()
      return
    end
    __CPC.section('APP VERSION')
    ui.textColored('CPC DRIVE SUITE 3.10.0', __CPC.featureColor())
    ui.textWrapped('A compact control surface for clutch assistance, throttle camera motion, NeckFX, gear tracking, telemetry, and editable JSON settings.')
    __CPC.section('DISPLAY MODE')
    __CPC.drawUiModeSwitch()
    ui.textWrapped('BIG PANEL shows the full sidebar and detailed pages. COMPACT keeps the essential controls visible while driving.')
    __CPC.section('COLOR GUIDE')
    ui.textColored('SELECTED ACCENT  /  FULL MENU', __CPC.accentColor())
    ui.textWrapped('The selected appearance color is used across navigation, headings, and panel borders.')
    __CPC.section('PROJECT FILES')
    ui.textWrapped('The shelf app and the matching CSP cockpit-camera backend must remain in their respective Assetto Corsa folders. Use the Home JSON tools to save, edit, view, and reload settings.')
  end

  function __CPC.drawActiveSettingsPage()
    if __CPC.settings.uiPage == 1 then __CPC.drawHomePage()
    elseif __CPC.settings.uiPage == 2 then __CPC.drawClutchPage()
    elseif __CPC.settings.uiPage == 3 then __CPC.drawThrottlePage()
    elseif __CPC.settings.uiPage == 4 then __CPC.drawNeckPage()
    elseif __CPC.settings.uiPage == 6 then __CPC.drawAutoGearPage()
    elseif __CPC.settings.uiPage == 8 then __CPC.drawAppVersionPage()
    else __CPC.drawAppearancePage() end
  end

  function __CPC.activeSettingsScrollId()
    return string.format('settingsScroll##%d:%d:%d:%d:%d:%d:%d:%d:%d',
      __CPC.settings.uiPage, __CPC.settings.clutchPage, __CPC.settings.throttlePage,
      __CPC.settings.throttleFovPage, __CPC.settings.throttleLinearPage, __CPC.settings.neckPage,
      __CPC.settings.lookPage, __CPC.settings.throttleDynamicsPage, __CPC.wheelHelpView or 1)
  end

  function __CPC.drawUiModeSwitch()
    ui.textColored('Display mode', __CPC.Theme.COLOR_MUTED)
    local width = math.max(96, (ui.availableSpaceX() - 5) / 2)
    __CPC.settings.uiMode = __CPC.tabButton(__CPC.settings.uiMode, 1, 'BIG PANEL', width, 'uimode')
    ui.sameLine(0, 5)
    __CPC.settings.uiMode = __CPC.tabButton(__CPC.settings.uiMode, 2, 'COMPACT', width, 'uimode')
  end

  function __CPC.drawSmallUi()
    __CPC.section('COMPACT CONTROL SURFACE',
      'Fast access to synced camera and core NeckFX movement while driving.')
    ui.textColored('CPC DRIVE SUITE', __CPC.accentColor())
    ui.sameLine()
    ui.textColored(__CPC.settings.suiteEnabled and 'RUNNING' or 'PAUSED',
      __CPC.settings.suiteEnabled and __CPC.Theme.COLOR_ACTIVE or __CPC.Theme.COLOR_WARNING)
    __CPC.drawUiModeSwitch()
    ui.progressBar(__CPC.settings.suiteEnabled and 1 or 0, vec2(ui.availableSpaceX(), 18),
      __CPC.settings.suiteEnabled and 'Suite active' or 'Suite paused')
    ui.progressBar(__CPC.neckIsOnline() and 1 or 0, vec2(ui.availableSpaceX(), 14),
      __CPC.neckIsOnline() and 'NeckFX backend online' or 'NeckFX backend offline')

    __CPC.toggle('Suite', 'suiteEnabled')
    ui.sameLine()
]====]
