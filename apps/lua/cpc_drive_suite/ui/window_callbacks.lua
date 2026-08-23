return [====[
    __CPC.toggle('Camera', 'throttleEnabled')
    ui.sameLine()
    __CPC.toggle('NeckFX', 'neckEnabled')

    __CPC.drawThrottleSyncControls()

    __CPC.section('NECK G-FORCE MOVEMENT')
    __CPC.slider('Longitudinal Z (accel / brake G)', 'neckMoveZDistance', -0.12, 0.12, '%+.3f m')
    __CPC.slider('Lateral X (cornering G)', 'neckMoveXDistance', -0.12, 0.12, '%+.3f m')
    __CPC.slider('Vertical Y (bump G)', 'neckMoveYDistance', -0.08, 0.08, '%+.3f m')
    __CPC.slider('Yaw twist (slide G)', 'neckYawAngle', -30, 30, '%+.1f deg')
    -- One slider scales all four neck G-force axes at once.
    local gainNow = __CPC.Math.clamp(1.5 / math.max(__CPC.settings.neckGForceAtFull, 0.05), 0.2, 3.0)
    __CPC.drawCenteredSliderLabel('G-force sensitivity', 'neckGForceAtFull')
    __CPC.pushSliderStyle()
    __CPC.beginCenteredSlider()
    local gainNew = ui.slider('##smallGain', gainNow, 0.2, 3.0, '%.2fx')
    __CPC.endCenteredSlider()
    __CPC.popSliderStyle()
    if gainNew ~= gainNow then
      __CPC.settings.neckGForceAtFull = __CPC.Math.clamp(1.5 / math.max(gainNew, 0.05), 0.2, 6.0)
    end

    __CPC.section('DRIFT YAW LOOK',
      'Slip angle turns the head into the slide, with an optional slide-direction look on top.')
    __CPC.slider('Drift yaw angle', 'neckDriftYawAngle', 0, 45, '%.1f deg')
    __CPC.reverseToggle('Reverse drift yaw', 'neckDriftYawReverse')
    __CPC.slider('Drift yaw response', 'neckDriftYawSpeed', 0.5, 30, '%.1f')
    __CPC.toggle('Look into the slide', 'neckSlideFollowing')
    if __CPC.settings.neckSlideFollowing and __CPC.settings.neckFollowScale <= 0 then
      __CPC.settings.neckFollowScale = 1.0
    end
    __CPC.slider('Look into slide amount', 'neckSlidingLookMult', 0, 1.5, '%.2f')
    __CPC.slider('Steering fallback amount', 'neckSteeringMult', 0, 2.0, '%.2f')
    __CPC.slider('Drift look master scale', 'neckFollowScale', 0, 3.0, '%.2fx')
    ui.text(string.format('Slip %+.1f deg   neck yaw %+.2f deg', __CPC.dynamicSlipAngle,
      __CPC.neckTelemetry.outputYaw))

    ui.dummy(vec2(1, 4))
    __CPC.section('LIVE OUTPUT')
    ui.text(string.format('FOV %.1f deg   forward %+.1f mm', __CPC.renderedFov,
      __CPC.outputForward * 1000))
    ui.text(string.format('Neck XYZ %+.1f / %+.1f / %+.1f mm   yaw %+.2f deg',
      __CPC.neckTelemetry.outputX * 1000, __CPC.neckTelemetry.outputY * 1000,
      __CPC.neckTelemetry.outputZ * 1000, __CPC.neckTelemetry.outputYaw))
    ui.text(string.format('G long %+.2f   lat %+.2f   vert %+.2f',
      __CPC.telemetry.accelerationZ, __CPC.telemetry.accelerationX, __CPC.telemetry.accelerationY))
    if ui.button('APPLY SIMPLE SUITE', vec2(ui.availableSpaceX(), 26)) then
      __CPC.applySimpleSuitePreset()
    end
  end

  __CPC.lastMainUiError = nil

  function __CPC.activeSubpageState()
    local page = __CPC.settings.uiPage
    if page == 2 then return 'clutchPage', __CPC.settings.clutchPage end
    if page == 3 then return 'throttlePage', __CPC.settings.throttlePage end
    if page == 4 then return 'neckPage', __CPC.settings.neckPage end
    if page == 5 then return 'lookPage', __CPC.settings.lookPage end
    if page == 8 then return 'wheelHelpView', __CPC.wheelHelpView or 1 end
    return nil, 1
  end

  function __CPC.drawActiveSettingsPageOverride(key, value)
    if not key then
      __CPC.drawActiveSettingsPage()
      return
    end
    if key == 'wheelHelpView' then
      local previous = __CPC.wheelHelpView
      __CPC.wheelHelpView = value
      __CPC.drawActiveSettingsPage()
      __CPC.wheelHelpView = previous
      return
    end
    local previous = __CPC.settings[key]
    __CPC.settings[key] = value
    __CPC.drawActiveSettingsPage()
    __CPC.settings[key] = previous
  end

  function __CPC.drawSettingsPanel(id, size, heading, overrideKey, overrideValue)
    ui.childWindow(id, size, function()
      local panelWidth, panelHeight = ui.availableSpaceX(), ui.availableSpaceY()
      local accent = __CPC.accentColor()
      local borderColor = rgbm(accent.r, accent.g, accent.b, 0.72)
      ui.drawRectFilled(vec2(0, 0), vec2(panelWidth, panelHeight),
        rgbm(0.010, 0.013, 0.019, 0.96), 8)
      ui.drawRect(vec2(0, 0), vec2(panelWidth, panelHeight), borderColor, 8, 0, 1)
      ui.setCursor(vec2(14, 12))
      ui.textColored(heading, accent)
      ui.pushDWriteFont('@System;Weight=Regular;Stretch=Condensed')
      if heading == 'MAIN SETTINGS' then
        __CPC.drawBigUiGuide()
      else
        ui.textWrapped('Extra controls selected with the subwheel.')
        ui.separator()
      end
      local previousSubwheelDrawing = __CPC.drawingSubwheelSettings
      __CPC.drawingSubwheelSettings = heading == 'SUBWHEEL SETTINGS'
      __CPC.drawActiveSettingsPageOverride(overrideKey, overrideValue)
      __CPC.drawingSubwheelSettings = previousSubwheelDrawing
      ui.popDWriteFont()
      ui.dummy(vec2(1, 18))
      local contentBottom = math.max(panelHeight - 1, ui.getCursor().y + 4)
      ui.drawLine(vec2(1, 8), vec2(1, contentBottom - 8), borderColor, 1.5)
      ui.drawLine(vec2(panelWidth - 1, 8),
        vec2(panelWidth - 1, contentBottom - 8), borderColor, 1.5)
      ui.drawLine(vec2(8, contentBottom - 1),
        vec2(panelWidth - 8, contentBottom - 1), borderColor, 1.5)
    end)
  end

  function __CPC.drawLowResolutionChrome()
    local size, accent = ui.windowSize(), __CPC.accentColor()
    local state = __CPC.settings.suiteEnabled and 'RUNNING' or 'PAUSED'
    local themeIndex = __CPC.Math.clamp(math.floor(__CPC.settings.colorTheme + 0.5),
      1, #__CPC.Theme.THEME_NAMES)
    ui.drawRectFilled(vec2(0, 0), size, rgbm(0.010, 0.013, 0.019, 0.98))
    ui.drawRectFilled(vec2(0, 0), vec2(size.x, 4), accent)
    ui.pushDWriteFont('@System;Weight=Black;Stretch=Condensed')
    ui.dwriteDrawTextClipped('CPC DRIVE SUITE', 18 * __CPC.settings.uiScale,
      vec2(12, 7), vec2(size.x - 12, 31), ui.Alignment.Center,
      ui.Alignment.Center, false, accent)
    ui.popDWriteFont()
    ui.dwriteDrawTextClipped(state .. '  |  ' .. __CPC.Theme.THEME_NAMES[themeIndex]
        .. '  |  1280 x 720 FULL UI', 9, vec2(12, 33), vec2(size.x - 12, 51),
      ui.Alignment.Center, ui.Alignment.Center, false, __CPC.Theme.COLOR_MUTED)
    ui.setCursor(vec2(8, 58))
  end

  function __CPC.drawMainWindowContents(dt)
    if __CPC.settings.uiMode == 2 then
      local compactSize = vec2(math.max(220, ui.availableSpaceX()),
        math.max(120, ui.availableSpaceY() - 4))
      ui.childWindow('smallUiScroll', compactSize, function()
        __CPC.drawSmallUi()
      end)
      return
    end
    if __CPC.settings.uiLowResolution then __CPC.drawLowResolutionChrome()
    else __CPC.drawMainChrome() end
    local contentHeight = math.max(120, ui.availableSpaceY() - 5)
    __CPC.drawSidebar()
    local subpageKey, selectedSubpage = __CPC.activeSubpageState()
    local settingsWidth = ui.availableSpaceX()
    if subpageKey and selectedSubpage > 1 then
      local gap = 10
      local columnWidth = math.max(260, (settingsWidth - gap) * 0.5)
      __CPC.drawSettingsPanel('mainSettingsScroll##' .. __CPC.settings.uiPage,
        vec2(columnWidth, contentHeight), 'MAIN SETTINGS', subpageKey, 1)
      ui.sameLine(0, gap)
      __CPC.drawSettingsPanel(__CPC.activeSettingsScrollId(),
        vec2(columnWidth, contentHeight), 'SUBWHEEL SETTINGS', nil, nil)
    else
      __CPC.drawSettingsPanel(__CPC.activeSettingsScrollId(),
        vec2(math.max(260, settingsWidth), contentHeight), 'MAIN SETTINGS', nil, nil)
    end
  end

  function script.windowMain(dt)
    local ok, err = pcall(__CPC.drawMainWindowContents, dt)
    if ok then
      __CPC.lastMainUiError = nil
      return
    end

    __CPC.lastMainUiError = tostring(err)
    ui.textColored('CPC DRIVE SUITE UI ERROR', __CPC.Theme.COLOR_WARNING)
    ui.separator()
    ui.textWrapped(__CPC.lastMainUiError)
    ui.separator()
    ui.textWrapped('The driving logic is still loaded. This message is shown so CSP UI errors are visible instead of a blank grey window.')
  end

  -- Manifest settings-button callback. Keep the full tuning UI available from
  -- both the normal app window and CSP's settings/gear button.
  function script.windowMainSettings(dt)
    script.windowMain(dt)
  end

  -- Compatibility alias for manifests/tools that expect windowSettings.
  function script.windowSettings(dt)
    script.windowMain(dt)
  end

end
]====]
