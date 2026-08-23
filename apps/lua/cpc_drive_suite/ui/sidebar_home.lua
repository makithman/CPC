return [====[
      local node = center + direction * radius
      local active = selected == item[1]
      local color = active and accent or __CPC.Theme.COLOR_MUTED
      local nodeRadius = 18 * wheelScale
      ui.drawLine(center + direction * (24 * wheelScale), node - direction * (15 * wheelScale),
        rgbm(color.r, color.g, color.b, active and 0.80 or 0.28),
        (active and 1.7 or 0.8) * wheelScale)
      ui.drawCircleFilled(node, nodeRadius, rgbm(color.r, color.g, color.b,
        active and (0.34 + __CPC.uiPulse(2.2, 0.45) * 0.25) or 0.15), 24)
      ui.drawCircle(node, nodeRadius, rgbm(color.r, color.g, color.b,
        active and 0.92 or 0.50), 24, (active and 1.7 or 1) * wheelScale)

      ui.setCursor(node - vec2(22, 16) * wheelScale)
      ui.pushStyleColor(ui.StyleColor.Button, rgbm(0, 0, 0, 0))
      ui.pushStyleColor(ui.StyleColor.ButtonHovered, rgbm(1, 1, 1, 0.10))
      ui.pushStyleColor(ui.StyleColor.ButtonActive, rgbm(1, 1, 1, 0.20))
      if ui.button('##tree:' .. (tree.key or 'help') .. ':' .. item[1],
          vec2(44, 32) * wheelScale) then
        __CPC.settings.uiPage = mainPage
        if __CPC.wheelSmoothScrollEnabled ~= false then
          __CPC.wheelScrollToSettings = true
          __CPC.wheelScrollLastPosition = nil
        end
        if tree.key then
          __CPC.settings[tree.key] = item[1]
        elseif mainPage == 8 then
          __CPC.wheelHelpView = item[1]
          if item[1] == 3 then __CPC.settings.lookPage = 1 end
          if item[1] == 4 then __CPC.settings.lookPage = 2 end
        end
      end
      if ui.itemHovered() then
        __CPC.wheelPreviewLockPage = mainPage
        __CPC.wheelPreviewLockUntil = os.preciseClock() + 0.8
        ui.setTooltip(item[3])
      end
      ui.popStyleColor(3)
      ui.pushDWriteFont('@System;Weight=Bold;Stretch=Condensed')
      ui.dwriteDrawTextClipped(item[2], 7 * wheelScale,
        vec2(node.x - nodeRadius, node.y - 10 * wheelScale),
        vec2(node.x + nodeRadius, node.y + 10 * wheelScale), ui.Alignment.Center, ui.Alignment.Center,
        false, rgbm(0.98, 0.99, 1.0, 1))
      ui.popDWriteFont()
    end

    return true
  end

  function __CPC.drawSidebar()
    local availableWidth, lowResolution = ui.availableSpaceX(), __CPC.settings.uiLowResolution == true
    local sidebarWidth = lowResolution and math.min(270, math.max(250, availableWidth * 0.24))
      or math.min(320, math.max(290, availableWidth * 0.30))
    local sidebarHeight = ui.availableSpaceY()
    ui.childWindow('mainSidebar', vec2(sidebarWidth, sidebarHeight), function()
      ui.drawRectFilled(vec2(0, 0), vec2(sidebarWidth, sidebarHeight),
        rgbm(0.012, 0.014, 0.020, 0.96), 8)
      ui.pushDWriteFont('@System;Weight=Bold;Stretch=Condensed')
      ui.dwriteDrawTextClipped('DRIVE SUITE', 17 * __CPC.settings.uiScale,
        vec2(14, 12), vec2(sidebarWidth - 10, 38), ui.Alignment.Start,
        ui.Alignment.Center, false, __CPC.Theme.COLOR_TEXT)
      ui.popDWriteFont()
      ui.drawText('MAIN WHEEL', vec2(15, 42), __CPC.Theme.COLOR_MUTED)
      local previewPage, mainNode = __CPC.drawSettingsNavigationWheel(__CPC.WHEEL_PAGES, sidebarWidth)
      local subwheelY = lowResolution and 360 or math.min(470, math.max(360, sidebarHeight - 260))
      ui.drawText('SUBWHEEL', vec2(15, subwheelY - 104), __CPC.Theme.COLOR_MUTED)
      ui.drawLine(vec2(16, subwheelY - 116), vec2(sidebarWidth - 16, subwheelY - 116),
        rgbm(0.52, 0.56, 0.62, 0.24), 1)
      local subwheelCenter = vec2(sidebarWidth * 0.5, subwheelY)
      local hasSubmenu = __CPC.drawSettingsTreeSubmenu(sidebarWidth, previewPage,
        mainNode, subwheelCenter)
      if not hasSubmenu then
        ui.setCursor(vec2(12, subwheelY - 72))
        ui.textWrapped('Choose a main-wheel section to show its subwheel controls below.')
      end
      local wheelScale = __CPC.Math.clamp(__CPC.settings.uiWheelScale or 1, 0.75, 1.25)
      ui.setCursor(vec2(12, subwheelY + 105 + math.max(0, wheelScale - 1) * 60))
      __CPC.slider('Wheel and subwheel size', 'uiWheelScale', 0.75, 1.25, '%.2fx')
      __CPC.slider('Slider title font size', 'uiSliderLabelScale', 0.75, 1.50, '%.2fx')
      local resolutionLabel = lowResolution and 'RESTORE LARGE FULL UI' or 'FIT FULL UI TO 1280 x 720'
      if ui.button(resolutionLabel, vec2(ui.availableSpaceX(), 28)) then
        __CPC.settings.uiLowResolution = not lowResolution
      end
    end)
    ui.sameLine(0, 10)
  end

  function __CPC.drawHomePage()
    __CPC.section('MASTER CONTROL', 'Pause every output instantly while keeping all tuning saved.')
    __CPC.toggle('Enable CPC Drive Suite', 'suiteEnabled')
    if ui.button('OPEN UI APPEARANCE', vec2(ui.availableSpaceX(), 28)) then
      __CPC.settings.uiPage = 5
      __CPC.settings.lookPage = 2
    end

    __CPC.section('SYSTEMS')
    __CPC.toggle('Adaptive clutch assist', 'clutchEnabled',
      'Controls clutch coupling only. A physical pedal can always press farther.')
    ui.sameLine()
    ui.textColored(__CPC.clutchStatus, __CPC.clutchStateColor())
    __CPC.toggle('Throttle seat and FOV camera', 'throttleEnabled',
      'Directly edits cockpit seat position and first-person FOV.')
    ui.sameLine()
    ui.textColored(__CPC.throttleStatus,
      __CPC.throttleStatus == 'Active in cockpit' and __CPC.Theme.COLOR_ACTIVE or __CPC.Theme.COLOR_MUTED)
    __CPC.toggle('Gear tracker assist', 'autoGearEnabled',
      'Tracks live gear changes and runs a back/up shift cycle when a change is detected.')
    ui.sameLine()
    ui.textColored(__CPC.autoGearStatus, __CPC.autoGearStateColor())
    if ui.button('REBASE CAMERA / FOV##cameraRebase', vec2(ui.availableSpaceX(), 26)) then
      __CPC.resetThrottleCameraSession()
      __CPC.throttleStatus = 'Camera baseline reset'
    end
    if ui.itemHovered() then
      ui.setTooltip('Restore the current camera, then capture its seat position and FOV again on the next cockpit frame.')
    end
    __CPC.toggle('Dynamic 6DOF NeckFX layer', 'neckEnabled',
      'Requires the CPC Drive Suite cockpit-camera backend to be selected in NeckFX.')
    ui.sameLine()
    ui.textColored(__CPC.neckIsOnline() and 'BACKEND ONLINE' or 'BACKEND OFFLINE',
      __CPC.neckIsOnline() and __CPC.Theme.COLOR_ACTIVE or __CPC.Theme.COLOR_WARNING)

    __CPC.section('LIVE STEERING',
      'This wheel matches the HUD display and turns with your current steering input.')
    __CPC.drawSettingsWheel()

    __CPC.section('SETTINGS FILE')
    local settingsButtonWidth = (ui.availableSpaceX() - 6) / 2
    if ui.button('SAVE JSON##homeSaveSettings', vec2(settingsButtonWidth, 28)) then
      __CPC.exportSettingsJson()
    end
    ui.sameLine(0, 6)
    if ui.button('LOAD JSON##homeLoadSettings', vec2(settingsButtonWidth, 28)) then
      __CPC.importSettingsJson()
    end
    if ui.button('LOAD DEFAULTS FROM JSON##homeLoadJsonDefaults', vec2(ui.availableSpaceX(), 28)) then
      __CPC.loadJsonAsDefaults()
    end
    if ui.button('OPEN JSON FOLDER##homeOpenSettingsFolder', vec2(ui.availableSpaceX(), 28)) then
      __CPC.openSettingsFolder()
    end
    if ui.button((__CPC.settingsFilePreview and 'HIDE JSON' or 'VIEW JSON')
        .. '##homeViewSettings', vec2(ui.availableSpaceX(), 26)) then
      __CPC.toggleSettingsPreview()
    end
    ui.textWrapped('Editable file: apps/lua/' .. __CPC.settingsFilePath)
    if __CPC.settingsFileStatus ~= '' then ui.text(__CPC.settingsFileStatus) end
    if __CPC.settingsFilePreview then
      ui.childWindow('settingsJsonPreview', vec2(ui.availableSpaceX(), 220), true, function()
        ui.textWrapped(__CPC.settingsFilePreview)
      end)
    end

    __CPC.section('START HERE')
    ui.textWrapped('Use the main and sub wheels on the left to choose a section. Its settings stay visible in the panel on the right. Use UI APPEARANCE above for display controls.')
    ui.textWrapped('Hover over any setting to see what it changes. Amber [*] means you changed it from the original value. Right-click a slider to restore that original value.')

    __CPC.section('LIVE DRIVE')
    ui.progressBar(__CPC.Math.saturate((__CPC.telemetry.rpm - __CPC.telemetry.idleRPM) /
      math.max(__CPC.telemetry.limiterRPM - __CPC.telemetry.idleRPM, 1)),
      vec2(ui.availableSpaceX(), 18),
      string.format('RPM %.0f / %.0f  |  %+.0f RPM/s',
        __CPC.telemetry.rpm, __CPC.telemetry.limiterRPM, __CPC.rpmTrend))
    ui.progressBar(__CPC.clutchCommand, vec2(ui.availableSpaceX(), 18),
      string.format('Clutch coupled %.0f%%  |  Target %.0f%%  |  Physical %.0f%%',
        __CPC.clutchCommand * 100, __CPC.clutchTarget * 100, __CPC.telemetry.rawClutch * 100))
    ui.text(string.format('Gas %.0f%%   Brake %.0f%%   Wheel %+.0f%%   Speed %.1f km/h   Gear %d',
      __CPC.telemetry.gas * 100, __CPC.telemetry.brake * 100, __CPC.telemetry.steer * 100,
      __CPC.telemetry.speed, __CPC.telemetry.gear))
    ui.text(string.format('Throttle camera: FOV %.1f deg   XYZ %+.1f / %+.1f / %+.1f mm',
      __CPC.renderedFov, __CPC.outputLateral * 1000, __CPC.outputVertical * 1000, __CPC.outputForward * 1000))
    ui.text(string.format('NeckFX: %.0f%% strength   XYZ %+.1f / %+.1f / %+.1f mm',
      __CPC.neckTelemetry.effectStrength * 100, __CPC.neckTelemetry.outputX * 1000,
      __CPC.neckTelemetry.outputY * 1000, __CPC.neckTelemetry.outputZ * 1000))

    __CPC.section('SETUP CHECK')
    if __CPC.telemetry.builtInAutoClutch then
      ui.textColored('Turn off AC built-in auto-clutch to avoid overlapping clutch assists.',
        __CPC.Theme.COLOR_WARNING)
    else
      ui.textColored('AC built-in auto-clutch is not reporting a conflict.', __CPC.Theme.COLOR_ACTIVE)
    end
    if not __CPC.neckIsOnline() then
      ui.textColored('Select CPC Drive Suite - NeckFX Backend, enable scripted NeckFX, then reload.',
        __CPC.Theme.COLOR_WARNING)
    else
      ui.textColored('The separate NeckFX runtime is connected to this dashboard.', __CPC.Theme.COLOR_ACTIVE)
    end
    ui.textWrapped('If another app directly edits cockpit seat position or FOV, disable it. NeckFX remains compatible because CSP applies it as a separate camera layer.')
  end

  function __CPC.drawBigUiGuide()
    local guide = {
      [1] = 'Start here: turn features on or off, then use Simple Setup for an easy first tune.',
      [2] = 'Clutch: choose a preset first, then adjust only the section you want to change.',
      [3] = 'Camera: the controls at the top are the main ones. The tabs below hold every detailed setting.',
      [4] = 'Head movement: start with Basics or Head Movement. The other tabs provide all detailed tuning.',
      [5] = 'Simple Setup: use this page for clear camera and head-movement controls. Detailed controls remain available elsewhere.',
      [6] = 'Gear Assist: change the pattern length and timing, then watch the live status below.',
]====]
