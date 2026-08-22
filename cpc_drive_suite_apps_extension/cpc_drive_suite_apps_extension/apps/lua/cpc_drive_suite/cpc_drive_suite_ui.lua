-- CPC Drive Suite 3.9.2 — Dashboard/settings UI
-- Generated from the former monolithic core. Shared runtime values live in __CPC.

return function(__CPC)
  -- Dashboard UI ---------------------------------------------------------------

  __CPC.Theme = require('cpc_drive_suite_theme')
  __CPC.SectionPresets = require('cpc_drive_suite_presets')
  __CPC.resetEverythingArmed = false
  __CPC.presetStatus = ''
  __CPC.WHEEL_PAGES = {
    { 3, 'CAMERA', 'Change camera, FOV, gear anticipation, and corner response.' },
    { 2, 'CLUTCH', 'Set up launch help, anti-stall, shifting, and drift kicks.' },
    { 4, 'NECK FX', 'Change NeckFX head movement, turning, and following.' },
    { 6, 'GEAR', 'Set up the automatic gear-tracking pattern.' },
    { 8, 'HELP', 'Open setup guidance, display settings, and app help.' }
  }

  __CPC.SETTING_HELP = {
    throttleOverallSpeed = 'Changes how quickly all camera effects react. Higher values feel more immediate.',
    throttleDeadzone = 'Ignores the first small part of pedal travel to prevent unwanted camera movement.',
    throttleCurve = 'Changes when the camera movement builds as you press the throttle. Lower values start earlier; higher values wait for more throttle.',
    throttleEffectSpeedFloor = 'Camera effects begin to fade in at this road speed.',
    throttleEffectSpeedCap = 'Camera effects reach their full strength at this road speed.',
    throttleSpeedGateCurve = 'Controls whether speed effects build early or mostly at higher speeds.',
    throttleRestingFov = 'Your normal view angle when the throttle is released.',
    throttleMaximumFov = 'Your view angle at full throttle.',
    throttleForwardDistance = 'How far the camera moves forward as you press the throttle.',
    throttleBackDistance = 'How far the camera moves back as you release the throttle.',
    throttleTransitionSpeed = 'How quickly the main camera movement changes.',
    throttleFovTransitionSpeed = 'How quickly the view angle changes.',
    neckGForceAtFull = 'Sets how much car movement is needed before the head effect reaches full strength. Lower values make it more sensitive.',
    neckOverallSpeed = 'Changes how quickly all head movements react.',
    neckMoveZDistance = 'Sets the head movement forward and back under acceleration and braking.',
    neckMoveXDistance = 'Sets the head movement side to side while cornering.',
    neckMoveYDistance = 'Sets the head movement up and down over bumps and dips.',
    neckYawAngle = 'Sets how far the view turns while the car moves sideways.',
    neckDriftYawAngle = 'Sets how far the view turns when the car is sliding.',
    neckDriftYawSpeed = 'Sets how quickly the view turns when a slide begins.',
    neckSlidingLookMult = 'Sets how strongly the view looks in the direction of the slide.',
    neckSteeringMult = 'Adds steering-based view turning when slide data is weak.'
  }

  function __CPC.uiPulse(rate, minimum)
    local wave = (math.sin(os.preciseClock() * (rate or 2.2)) + 1) * 0.5
    return (minimum or 0.45) + wave * (1 - (minimum or 0.45))
  end

  function __CPC.accentColor(alpha)
    local index = __CPC.Math.clamp(math.floor(__CPC.settings.colorTheme + 0.5), 1, #__CPC.Theme.THEME_ACCENTS)
    local color = __CPC.Theme.THEME_ACCENTS[index]
    return rgbm(color.r, color.g, color.b, alpha or 1)
  end

  function __CPC.featureColor(alpha)
    local page = __CPC.Math.clamp(math.floor(__CPC.settings.uiPage + 0.5), 1,
      #__CPC.Theme.PAGE_COLORS)
    local color = __CPC.Theme.PAGE_COLORS[page]
    return rgbm(color.r, color.g, color.b, alpha or 1)
  end

  function __CPC.clutchStateColor()
    if __CPC.clutchStatusKind == 'action' then return __CPC.Theme.COLOR_ACTION end
    if __CPC.clutchStatusKind == 'warning' then return __CPC.Theme.COLOR_WARNING end
    if __CPC.clutchStatusKind == 'active' then return __CPC.Theme.COLOR_ACTIVE end
    return __CPC.Theme.COLOR_MUTED
  end

  function __CPC.neckIsOnline()
    return __CPC.neckLink.backendPresent and os.preciseClock() - __CPC.neckLastAckTime < 1.5
  end

  function __CPC.statusValueColor(value, activeValue)
    if value == activeValue then return __CPC.Theme.COLOR_ACTIVE end
    if not value then return __CPC.Theme.COLOR_MUTED end
    if string.find(value, 'Waiting', 1, true)
        or string.find(value, 'disabled', 1, true)
        or string.find(value, 'unavailable', 1, true)
        or string.find(value, 'offline', 1, true)
        or string.find(value, 'paused', 1, true) then
      return __CPC.Theme.COLOR_WARNING
    end
    return __CPC.Theme.COLOR_MUTED
  end

  function __CPC.settingIndicator(key, enabled)
    local current = __CPC.settings[key]
    local defaultValue = __CPC.DEFAULTS[key]
    if defaultValue ~= nil and current ~= defaultValue then
      return '[*]', __CPC.Theme.COLOR_ACTION
    end
    if enabled then return '[ON]', __CPC.Theme.COLOR_ACTIVE end
    return '[ ]', __CPC.Theme.COLOR_MUTED
  end

  function __CPC.drawSettingIndicator(key, enabled)
    local marker, color = __CPC.settingIndicator(key, enabled)
    if marker == '[*]' then
      color = rgbm(color.r, color.g, color.b, __CPC.uiPulse(4.2, 0.55))
    end
    ui.textColored(marker, color)
    ui.sameLine()
  end

  function __CPC.toggle(label, key, tooltip)
    __CPC.drawSettingIndicator(key, __CPC.settings[key] == true)
    if ui.checkbox('##chk:' .. key, __CPC.settings[key]) then
      __CPC.settings[key] = not __CPC.settings[key]
    end
    local hovered = ui.itemHovered()
    ui.sameLine()
    ui.textWrapped(label)
    if tooltip and (hovered or ui.itemHovered()) then ui.setTooltip(tooltip) end
  end

  function __CPC.reverseToggle(label, key)
    __CPC.toggle(label, key, 'Invert this movement channel without changing its amount or response speed.')
  end

  function __CPC.slider(label, key, minimum, maximum, format, tooltip)
    __CPC.drawSettingIndicator(key)
    ui.textWrapped(label)
    local value = ui.slider('##sld:' .. key, __CPC.settings[key],
      minimum, maximum, format)
    if ui.itemEdited() then __CPC.settings[key] = value end
    if ui.itemClicked(ui.MouseButton.Right) and __CPC.DEFAULTS[key] ~= nil then
      __CPC.settings[key] = __CPC.DEFAULTS[key]
    end
    if ui.itemHovered() then
      ui.setTooltip((tooltip or __CPC.SETTING_HELP[key] or 'Adjust this setting to change the selected effect.')
        .. '\n\nRight-click to restore the original value.')
    end
  end

  function __CPC.percentSlider(label, key, minimum, maximum, tooltip)
    __CPC.drawSettingIndicator(key)
    ui.textWrapped(label)
    local current = (__CPC.settings[key] or 0) * 100
    local value = ui.slider('##sld:' .. key,
      current, minimum * 100, maximum * 100, '%.0f%%')
    if type(value) == 'number' and (ui.itemEdited() or value ~= current) then
      __CPC.settings[key] = value / 100
    end
    if ui.itemClicked(ui.MouseButton.Right) and __CPC.DEFAULTS[key] ~= nil then
      __CPC.settings[key] = __CPC.DEFAULTS[key]
    end
    if ui.itemHovered() then
      ui.setTooltip((tooltip or __CPC.SETTING_HELP[key] or 'Adjust this setting to change the selected effect.')
        .. '\n\nRight-click to restore the original value.')
    end
  end

  function __CPC.section(title, description)
    ui.dummy(vec2(1, 2))
    ui.separator()
    ui.textColored('> ' .. title, __CPC.featureColor())
    if description then ui.textWrapped(description) end
  end

  function __CPC.presetButton(label, id, level, size)
    local color = level == 1 and __CPC.Theme.COLOR_MUTED
      or (level == 2 and __CPC.Theme.COLOR_ACTIVE or __CPC.Theme.COLOR_ACTION)
    ui.pushStyleColor(ui.StyleColor.Button, rgbm(color.r, color.g, color.b, 0.20))
    ui.pushStyleColor(ui.StyleColor.ButtonHovered, rgbm(color.r, color.g, color.b, 0.38))
    ui.pushStyleColor(ui.StyleColor.ButtonActive, rgbm(color.r, color.g, color.b, 0.58))
    local clicked = ui.button(label .. id, size)
    ui.popStyleColor(3)
    return clicked
  end

  function __CPC.drawSectionPresets(id)
    local presets = __CPC.SectionPresets[id]
    if not presets then return end

    local width = math.max(82, (ui.availableSpaceX() - (#presets - 1) * 5) / #presets)
    for index, preset in ipairs(presets) do
      if __CPC.presetButton(preset.label, '##preset:' .. id .. ':' .. index, index, vec2(width, 24)) then
        for key, value in pairs(preset.values) do
          __CPC.settings[key] = value
        end
        __CPC.presetStatus = preset.label .. ' preset applied'
      end
      if index < #presets then ui.sameLine(0, 5) end
    end
    if __CPC.presetStatus ~= '' then
      ui.textColored(__CPC.presetStatus, __CPC.Theme.COLOR_ACTION)
    end
  end

  function __CPC.scaledPresetValue(value, multiplier)
    if value == nil then return nil end
    return value * multiplier
  end

  function __CPC.applyLinearChannelPreset(channel, level)
    local keys = channel.keys
    local strength = level == 1 and 0.55 or (level == 2 and 1.00 or 1.70)
    local speedScale = level == 1 and 0.75 or (level == 2 and 1.00 or 1.35)
    local triggerScale = level == 1 and 1.30 or (level == 2 and 1.00 or 0.70)
    local fovScale = level == 1 and 0.45 or (level == 2 and 1.00 or 1.60)

    __CPC.settings[keys.enabled] = true
    __CPC.settings[keys.distance] = __CPC.Math.clamp(
      __CPC.scaledPresetValue(__CPC.DEFAULTS[keys.distance] or 0, strength),
      -channel.distRange, channel.distRange)
    __CPC.settings[keys.reverse] = __CPC.DEFAULTS[keys.reverse] or false
    __CPC.settings[keys.atFull] = __CPC.Math.clamp(
      __CPC.scaledPresetValue(__CPC.DEFAULTS[keys.atFull] or 1, triggerScale),
      channel.atFullMin, channel.atFullMax)
    __CPC.settings[keys.curve] = level == 1 and 1.25 or (level == 2 and
      (__CPC.DEFAULTS[keys.curve] or 1) or 0.75)
    __CPC.settings[keys.speed] = __CPC.Math.clamp(
      __CPC.scaledPresetValue(__CPC.DEFAULTS[keys.speed] or 8, speedScale), 0.1, 60)
    __CPC.settings[keys.releaseSpeed] = level == 1
      and math.max(2, __CPC.settings[keys.speed] * 0.70)
      or (level == 2 and (__CPC.DEFAULTS[keys.releaseSpeed] or 0)
        or math.max(4, __CPC.settings[keys.speed] * 0.70))

    if keys.frequency and __CPC.settings[keys.frequency] ~= nil then
      __CPC.settings[keys.frequency] = __CPC.DEFAULTS[keys.frequency] or __CPC.settings[keys.frequency]
    end

    local defaultLimit = __CPC.DEFAULTS[keys.limit] or 0
    if level == 1 then
      __CPC.settings[keys.limit] = defaultLimit > 0 and defaultLimit * 0.65
        or math.abs(__CPC.settings[keys.distance]) * 1.25
    elseif level == 2 then
      __CPC.settings[keys.limit] = defaultLimit
    else
      __CPC.settings[keys.limit] = math.min(channel.distRange * 2,
        math.max(defaultLimit * 1.5, math.abs(__CPC.settings[keys.distance]) * 1.50))
    end

    __CPC.settings[keys.gateStart] = level == 1
      and math.max(__CPC.DEFAULTS[keys.gateStart] or 0, 8)
      or (level == 2 and (__CPC.DEFAULTS[keys.gateStart] or 0) or 0)
    __CPC.settings[keys.gateFull] = level == 1
      and math.max(__CPC.settings[keys.gateStart] + 10, (__CPC.DEFAULTS[keys.gateFull] or 40) * 1.20)
      or (level == 2 and (__CPC.DEFAULTS[keys.gateFull] or 40)
        or math.max(1, (__CPC.DEFAULTS[keys.gateFull] or 40) * 0.70))
    __CPC.settings[keys.gateCurve] = level == 1 and 1.30
      or (level == 2 and (__CPC.DEFAULTS[keys.gateCurve] or 1) or 0.75)

    if __CPC.settings[keys.fovMix] ~= nil then
      __CPC.settings[keys.fovMix] = __CPC.scaledPresetValue(__CPC.DEFAULTS[keys.fovMix] or 0, fovScale)
      __CPC.settings[keys.fovLimit] = level == 1
        and math.max(0.5, (__CPC.DEFAULTS[keys.fovLimit] or 1) * 0.50)
        or (level == 2 and (__CPC.DEFAULTS[keys.fovLimit] or 1)
          or math.min(20, math.max(2, (__CPC.DEFAULTS[keys.fovLimit] or 1) * 1.75)))
    end
  end

  function __CPC.drawLinearChannelPresets(channel)
    local labels = { 'LIGHT', 'BALANCED', 'STRONG' }
    local width = math.max(82, (ui.availableSpaceX() - 10) / #labels)
    for level, label in ipairs(labels) do
      if __CPC.presetButton(label, '##linearPreset:' .. channel.base .. ':' .. level, level, vec2(width, 24)) then
        __CPC.applyLinearChannelPreset(channel, level)
        __CPC.presetStatus = channel.label .. ' ' .. string.lower(label) .. ' preset applied'
      end
      if level < #labels then ui.sameLine(0, 5) end
    end
    if __CPC.presetStatus ~= '' then
      ui.textColored(__CPC.presetStatus, __CPC.Theme.COLOR_ACTION)
    end
  end

  function __CPC.tabButton(current, page, label, width, group)
    local selected = current == page
    local text = (selected and '> ' or '  ') .. label
    local id = string.format('##tab:%s:%d', group or label, page)
    local height = group == 'primary' and 30 or 26
    local buttonWidth = math.max(74, width or 90)
    if ui.button(text .. id, vec2(buttonWidth, height)) then return page end
    return current
  end

  function __CPC.drawSettingsWheel()
    if not __CPC.HUD or not __CPC.HUD.drawWheel then return end

    local width = math.min(270, math.max(190, ui.availableSpaceX()))
    local height = 235
    local topLeft = ui.getCursor()
    ui.dummy(vec2(width, height))

    local scale = math.min(width / 190, height / 190)
    local center = vec2(topLeft.x + width * 0.5, topLeft.y + height * 0.54)
    local accent = __CPC.accentColor()
    local activeColor = __CPC.settings.suiteEnabled and accent or __CPC.Theme.COLOR_WARNING
    local time = os.preciseClock()
    local outerRadius = 91 * scale
    local throttle = __CPC.Math.saturate(__CPC.telemetry.gas or 0)
    local brake = __CPC.Math.saturate(__CPC.telemetry.brake or 0)

    ui.drawCircleFilled(center, outerRadius + 8 * scale,
      rgbm(0.004, 0.005, 0.008, 0.72), 96)
    ui.drawCircle(center, outerRadius + 6 * scale, rgbm(activeColor.r, activeColor.g, activeColor.b,
      0.32 + __CPC.uiPulse(2.2, 0.30) * 0.35), 96, math.max(1, 1.5 * scale))
    ui.drawCircle(center, outerRadius + 2 * scale, rgbm(0.68, 0.70, 0.75, 0.34), 96,
      math.max(1, 0.7 * scale))

    for tick = 0, 31 do
      local angle = tick / 32 * math.pi * 2 - math.pi / 2
      local direction = vec2(math.cos(angle), math.sin(angle))
      local longTick = tick % 4 == 0
      local inner = outerRadius - (longTick and 8 or 4) * scale
      local color = tick / 32 <= throttle and accent or rgbm(0.26, 0.28, 0.32, 0.72)
      ui.drawLine(center + direction * inner, center + direction * outerRadius,
        color, math.max(1, (longTick and 1.8 or 0.9) * scale))
    end

    local sweepAngle = time * 1.8 - math.pi / 2
    local sweepDirection = vec2(math.cos(sweepAngle), math.sin(sweepAngle))
    local sweepPoint = center + sweepDirection * (outerRadius + 3 * scale)
    ui.drawCircleFilled(sweepPoint, math.max(2, 3.2 * scale), activeColor, 16)

    local ctx = {
      scale = scale,
      origin = center - vec2(180 * scale, 173 * scale)
    }
    __CPC.HUD.drawWheel(ctx, 180, 173, 68, accent)

    local pedalY = topLeft.y + height - 25
    local pedalWidth = (width - 38) * 0.5
    local brakeColor = __CPC.Theme.COLOR_WARNING
    ui.drawRectFilled(vec2(topLeft.x + 14, pedalY), vec2(topLeft.x + 14 + pedalWidth, pedalY + 7),
      rgbm(0.04, 0.045, 0.055, 0.96), 3)
    ui.drawRectFilled(vec2(topLeft.x + 14, pedalY), vec2(topLeft.x + 14 + pedalWidth * brake, pedalY + 7),
      brakeColor, 3)
    ui.drawRectFilled(vec2(topLeft.x + 24 + pedalWidth, pedalY),
      vec2(topLeft.x + 24 + pedalWidth * 2, pedalY + 7), rgbm(0.04, 0.045, 0.055, 0.96), 3)
    ui.drawRectFilled(vec2(topLeft.x + 24 + pedalWidth, pedalY),
      vec2(topLeft.x + 24 + pedalWidth + pedalWidth * throttle, pedalY + 7), accent, 3)
    ui.drawText('BRAKE', vec2(topLeft.x + 14, pedalY + 10), __CPC.Theme.COLOR_MUTED)
    ui.drawText('THROTTLE', vec2(topLeft.x + 24 + pedalWidth, pedalY + 10), __CPC.Theme.COLOR_MUTED)
  end

  function __CPC.drawStatusTile(p1, p2, label, value, color)
    ui.drawRectFilled(p1, p2, __CPC.Theme.COLOR_PANEL, 8)
    ui.drawRect(p1, p2, rgbm(color.r, color.g, color.b, 0.58), 8, 0, 1)
    ui.drawText(label, vec2(p1.x + 18, p1.y + 6), __CPC.Theme.COLOR_MUTED)
    ui.drawTextClipped(tostring(value or '-'),
      vec2(p1.x + 18, p1.y + 20), vec2(p2.x - 8, p2.y - 6), color,
      vec2(0, 0), false)
  end

  function __CPC.drawMainChrome()
    local size = ui.windowSize()
    local accent = __CPC.accentColor()
    local stateColor = __CPC.settings.suiteEnabled and __CPC.Theme.COLOR_ACTIVE or __CPC.Theme.COLOR_WARNING
    local stateText = __CPC.settings.suiteEnabled and 'RUNNING' or 'PAUSED'
    local throttleColor = __CPC.statusValueColor(__CPC.throttleStatus, 'Active in cockpit')
    local neckOnline = __CPC.neckIsOnline()
    local neckColor = neckOnline and __CPC.Theme.COLOR_ACTIVE or __CPC.Theme.COLOR_WARNING
    local themeIndex = __CPC.Math.clamp(math.floor(__CPC.settings.colorTheme + 0.5), 1, #__CPC.Theme.THEME_NAMES)

    ui.setCursor(vec2(0, 0))
    ui.dummy(vec2(1, 1))
    if themeIndex == 1 then
      ui.drawRectFilled(vec2(0, 0), size, __CPC.Theme.COLOR_DAMASCUS_DARK)
      local contourStep = 24
      for baseY = -contourStep, size.y + contourStep, contourStep do
        local previous = nil
        local previousHighlight = nil
        for x = -10, size.x + 10, 10 do
          local terrain = math.sin(x * 0.026 + baseY * 0.071) * 9
            + math.sin(x * 0.061 - baseY * 0.037) * 5
            + math.sin(x * 0.013 + baseY * 0.119) * 8
            + math.sin(x * 0.117 + baseY * 0.023) * 2.5
          local point = vec2(x, baseY + terrain)
          local highlightPoint = vec2(x, baseY + terrain - 3)
          if previous then
            ui.drawLine(previous, point, __CPC.Theme.COLOR_DAMASCUS_RED, 8)
            ui.drawLine(previousHighlight, highlightPoint,
              rgbm(0.45, 0.018, 0.025, 0.10), 2)
          end
          previous = point
          previousHighlight = highlightPoint
        end
      end
    else
      ui.drawRectFilledMultiColor(vec2(0, 0), size,
        rgbm(0.055, 0.061, 0.074, 0.99), rgbm(0.020, 0.024, 0.032, 0.99),
        rgbm(0.010, 0.012, 0.016, 0.99), rgbm(0.010, 0.012, 0.016, 0.99))
    end
    ui.drawRectFilled(vec2(0, 0), vec2(size.x, 5), accent)

    local heroP1, heroP2 = vec2(12, 16), vec2(size.x - 12, 96)
    ui.drawRectFilled(heroP1, heroP2, rgbm(0.014, 0.017, 0.024, 0.96), 10)
    ui.drawRect(heroP1, heroP2, rgbm(accent.r, accent.g, accent.b, 0.44), 10, 0, 1)

    ui.pushDWriteFont('@System;Weight=Black;Stretch=Condensed')
    ui.dwriteDrawTextClipped('CPC DRIVE SUITE', 24 * __CPC.settings.uiScale,
      vec2(24, 24), vec2(size.x - 190, 56), ui.Alignment.Start,
      ui.Alignment.Center, false, __CPC.Theme.COLOR_TEXT)
    ui.popDWriteFont()

    ui.drawText('ADAPTIVE CLUTCH  |  THROTTLE CAMERA  |  DYNAMIC 6DOF',
      vec2(24, 57), __CPC.Theme.COLOR_MUTED)
    ui.drawText(string.format('Theme: %s   UI Scale: %.2fx',
        __CPC.Theme.THEME_NAMES[themeIndex], __CPC.settings.uiScale),
      vec2(24, 75), __CPC.Theme.COLOR_MUTED)

    local stateP1, stateP2 = vec2(size.x - 165, 31), vec2(size.x - 24, 81)
    ui.drawRectFilled(stateP1, stateP2,
      rgbm(stateColor.r, stateColor.g, stateColor.b,
        0.10 + __CPC.uiPulse(2.4, 0.25) * 0.10), 12)
    ui.drawRect(stateP1, stateP2, stateColor, 12, 0, 1)
    ui.drawTextClipped(stateText, stateP1, stateP2, stateColor,
      vec2(0.5, 0.5), false)

    local gap = 8
    local tileTop, tileBottom = 103, 146
    local tileWidth = (size.x - 24 - gap * 2) / 3
    local x = 12
    __CPC.drawStatusTile(vec2(x, tileTop), vec2(x + tileWidth, tileBottom),
      'Clutch', __CPC.clutchStatus, __CPC.clutchStateColor())
    x = x + tileWidth + gap
    __CPC.drawStatusTile(vec2(x, tileTop), vec2(x + tileWidth, tileBottom),
      'Camera', __CPC.throttleStatus, throttleColor)
    x = x + tileWidth + gap
    __CPC.drawStatusTile(vec2(x, tileTop), vec2(x + tileWidth, tileBottom),
      'NeckFX', neckOnline and 'Backend online' or 'Backend offline', neckColor)

    ui.setCursor(vec2(18, 154))
  end

  function __CPC.drawSettingsNavigationWheel(pages, sidebarWidth)
    local center = vec2(sidebarWidth * 0.5, 156)
    local radius = math.min(122, math.max(76, sidebarWidth * 0.22))
    local time = os.preciseClock()
    local accent = __CPC.accentColor()
    local activePage = __CPC.settings.uiPage
    local glow = 0.20 + __CPC.uiPulse(2.1, 0.35) * 0.20
    local selectedNode = nil

    ui.drawCircleFilled(center, radius + 38, rgbm(0.006, 0.008, 0.012, 0.94), 96)
    ui.drawCircle(center, radius + 36, rgbm(accent.r, accent.g, accent.b, glow), 96, 2)
    ui.drawCircle(center, radius + 31, rgbm(0.70, 0.72, 0.77, 0.28), 96, 1)
    ui.drawCircle(center, radius - 10, rgbm(0.035, 0.040, 0.050, 0.92), 96, 3)
    ui.drawCircle(center, radius - 15, rgbm(accent.r, accent.g, accent.b, 0.20), 96, 1)

    for tick = 0, 23 do
      local angle = tick / 24 * math.pi * 2 - math.pi / 2
      local direction = vec2(math.cos(angle), math.sin(angle))
      local active = tick / 24 <= ((__CPC.telemetry.gas or 0) * 0.6 + 0.20)
      ui.drawLine(center + direction * (radius + 21), center + direction * (radius + 28),
        active and accent or rgbm(0.28, 0.30, 0.34, 0.62), active and 1.6 or 0.8)
    end

    ui.drawCircleFilled(center, 30, rgbm(0.008, 0.010, 0.014, 0.98), 48)
    ui.drawCircle(center, 30, rgbm(accent.r, accent.g, accent.b, 0.70), 48, 1.5)
    local wheelColor = __CPC.accentColor(0.96)
    ui.drawCircleFilled(center, 19, rgbm(0.015, 0.018, 0.024, 1), 32)
    ui.drawCircle(center, 17, wheelColor, 32, 4)
    ui.drawCircle(center, 13, rgbm(accent.r, accent.g, accent.b, 0.58), 32, 1)
    for _, spokeAngle in ipairs({ -math.pi / 2, math.pi / 6, math.pi * 5 / 6 }) do
      local direction = vec2(math.cos(spokeAngle), math.sin(spokeAngle))
      ui.drawLine(center + direction * 4, center + direction * 14, wheelColor, 2.5)
    end
    ui.drawCircleFilled(center, 5, rgbm(0.055, 0.060, 0.070, 1), 20)
    ui.drawCircle(center, 5, wheelColor, 20, 1)
    ui.setCursor(vec2(center.x - 19, center.y - 19))
    ui.pushStyleColor(ui.StyleColor.Button, rgbm(0, 0, 0, 0))
    ui.pushStyleColor(ui.StyleColor.ButtonHovered, rgbm(1, 1, 1, 0.12))
    ui.pushStyleColor(ui.StyleColor.ButtonActive, rgbm(1, 1, 1, 0.22))
    if ui.button('##wheelHome', vec2(38, 38)) then
      __CPC.settings.uiPage = 1
      if __CPC.wheelSmoothScrollEnabled ~= false then
        __CPC.wheelScrollToSettings = true
        __CPC.wheelScrollLastPosition = nil
      end
      activePage = 1
      selectedNode = nil
    end
    if ui.itemHovered() then ui.setTooltip('Open the main Home settings page.') end
    ui.popStyleColor(3)

    local nodeRadius = math.min(36, math.max(28, radius * 0.30))
    for index, page in ipairs(pages) do
      local angle = (index - 1) / #pages * math.pi * 2 - math.pi / 2
      local direction = vec2(math.cos(angle), math.sin(angle))
      local node = center + direction * radius
      local selected = activePage == page[1]
      if selected then selectedNode = node end
      local nodeColor = selected and accent or __CPC.Theme.COLOR_MUTED
      local nodeAlpha = selected and (0.36 + __CPC.uiPulse(2.5, 0.45) * 0.28) or 0.16

      ui.drawLine(center + direction * 33, node - direction * 18,
        rgbm(nodeColor.r, nodeColor.g, nodeColor.b, selected and 0.78 or 0.28), selected and 2 or 1)
      ui.drawCircleFilled(node, nodeRadius, rgbm(nodeColor.r, nodeColor.g, nodeColor.b, nodeAlpha), 32)
      ui.drawCircle(node, nodeRadius, rgbm(nodeColor.r, nodeColor.g, nodeColor.b, selected and 0.95 or 0.55), 32,
        selected and 2 or 1)

      ui.setCursor(vec2(node.x - nodeRadius, node.y - 12))
      ui.pushStyleColor(ui.StyleColor.Button, rgbm(0, 0, 0, 0))
      ui.pushStyleColor(ui.StyleColor.ButtonHovered, rgbm(1, 1, 1, 0.10))
      ui.pushStyleColor(ui.StyleColor.ButtonActive, rgbm(1, 1, 1, 0.20))
      if ui.button('##wheel:' .. page[1], vec2(nodeRadius * 2, 24)) then
        __CPC.settings.uiPage = page[1]
        if __CPC.wheelSmoothScrollEnabled ~= false then
          __CPC.wheelScrollToSettings = true
          __CPC.wheelScrollLastPosition = nil
        end
        activePage = page[1]
        selectedNode = node
      end
      if ui.itemHovered() then
        ui.setTooltip(page[3])
      end
      ui.popStyleColor(3)
      ui.pushDWriteFont('@System;Weight=Bold;Stretch=Condensed')
      ui.dwriteDrawTextClipped(page[2], 7, vec2(node.x - nodeRadius, node.y - 12),
        vec2(node.x + nodeRadius, node.y + 12), ui.Alignment.Center, ui.Alignment.Center,
        false, rgbm(0.98, 0.99, 1.0, 1))
      ui.popDWriteFont()
    end
    local travelSpeed = 0.10
    local markerAngle = time * travelSpeed * math.pi * 2 - math.pi / 2
    local markerRadius = radius + nodeRadius * 0.72
    local marker = center + vec2(math.cos(markerAngle), math.sin(markerAngle)) * markerRadius
    local markerColor = __CPC.Theme.COLOR_ACTION

    local previewLocked = (__CPC.wheelPreviewLockUntil or 0) > time
    if not ui.windowHovered() and not previewLocked then
      ui.drawCircleFilled(marker, math.max(4, nodeRadius * 0.20), markerColor, 20)
      ui.drawCircle(marker, math.max(6, nodeRadius * 0.34),
        rgbm(markerColor.r, markerColor.g, markerColor.b, 0.62), 20, 1.2)
      local markerStop = math.floor((time * travelSpeed) % 1 * #pages) + 1
      local previewPage = pages[markerStop][1]
      local previewAngle = (markerStop - 1) / #pages * math.pi * 2 - math.pi / 2
      local previewNode = center + vec2(math.cos(previewAngle), math.sin(previewAngle)) * radius
      return previewPage, previewNode
    end
    if previewLocked and __CPC.wheelPreviewLockPage then
      for index, page in ipairs(pages) do
        if page[1] == __CPC.wheelPreviewLockPage then
          local lockAngle = (index - 1) / #pages * math.pi * 2 - math.pi / 2
          local lockNode = center + vec2(math.cos(lockAngle), math.sin(lockAngle)) * radius
          return page[1], lockNode
        end
      end
    end
    return activePage, selectedNode
  end

  function __CPC.drawSettingsTreeSubmenu(sidebarWidth, mainPage, mainNode)
    local trees = {
      [2] = { key = 'clutchPage', title = 'CLUTCH OPTIONS', items = {
        { 1, 'ASSIST', 'Everyday clutch help, anti-stall, and handbrake options.' },
        { 2, 'LAUNCH', 'Standing launch and hold-to-release launch control.' },
        { 3, 'SHIFT', 'Shift timing and drift clutch-kick settings.' }
      }},
      [3] = { key = 'throttlePage', title = 'CAMERA OPTIONS', items = {
        { 1, 'BASIC', 'Main camera response and road-speed settings.' },
        { 2, 'MOVE', 'Camera position and movement direction.' },
        { 3, 'TURN', 'View tilt and side-turn settings.' },
        { 4, 'WIDTH', 'View-width settings and extra view effects.' },
        { 5, 'SHIFT', 'Keep the camera steady and anticipate an upshift.' },
        { 6, 'EXTRA', 'Additional camera movement effects.' },
        { 7, 'DRIVE', 'Tune corner-entry braking and corner-exit acceleration response.' },
        { 8, 'ADV', 'Detailed camera limits and response settings.' }
      }},
      [4] = { key = 'neckPage', title = 'HEAD OPTIONS', items = {
        { 1, 'BASIC', 'Main head-movement strength and speed.' },
        { 2, 'MOVE', 'Head movement in each direction.' },
        { 3, 'TURN', 'Head turning, leaning, road, and slide effects.' },
        { 4, 'SPEED', 'High-speed and bump-response effects.' },
        { 5, 'FOLLOW', 'Follow the slide or track direction.' }
      }},
      [5] = { key = 'lookPage', title = 'DISPLAY OPTIONS', items = {
        { 1, 'EASY', 'Simple camera and head-movement setup.' },
        { 2, 'HUD', 'HUD layout, colours, and display controls.' }
      }},
      [6] = { title = 'GEAR OPTIONS', items = {
        { 1, 'TRACK', 'Open the gear-tracker timing and pattern settings.' }
      }},
      [8] = { title = 'HELP OPTIONS', items = {
        { 1, 'GUIDE', 'Open the app guide and display-mode help.' },
        { 2, 'START', 'Open the main controls, live steering display, and settings file tools.' },
        { 3, 'EASY', 'Open the simple camera and head-movement setup.' },
        { 4, 'DISPLAY', 'Open HUD layout and colour settings.' }
      }}
    }
    local tree = trees[mainPage]
    if not tree then return false end

    local center = vec2(sidebarWidth * 0.5, 460)
    local radius = math.min(94, math.max(58, sidebarWidth * 0.16))
    local accent = __CPC.accentColor()
    local selected = tree.key and __CPC.settings[tree.key]
      or (tree.title == 'HELP OPTIONS' and (__CPC.wheelHelpView or 1) or 1)
    local pulse = 0.22 + __CPC.uiPulse(2.8, 0.30) * 0.18

    ui.drawCircleFilled(center, radius + 19, rgbm(0.006, 0.008, 0.012, 0.94), 64)
    ui.drawCircle(center, radius + 18, rgbm(accent.r, accent.g, accent.b, pulse), 64, 1.5)
    ui.drawCircleFilled(center, 22, rgbm(0.012, 0.015, 0.021, 1), 32)
    ui.drawCircle(center, 22, rgbm(accent.r, accent.g, accent.b, 0.68), 32, 1)
    local wheelColor = __CPC.accentColor(0.96)
    ui.drawCircle(center, 13, wheelColor, 28, 3.2)
    ui.drawCircle(center, 10, rgbm(wheelColor.r, wheelColor.g, wheelColor.b, 0.52), 28, 1)
    for _, spokeAngle in ipairs({ -math.pi / 2, math.pi / 6, math.pi * 5 / 6 }) do
      local direction = vec2(math.cos(spokeAngle), math.sin(spokeAngle))
      ui.drawLine(center + direction * 3, center + direction * 10, wheelColor, 2)
    end
    ui.drawCircleFilled(center, 4, rgbm(0.055, 0.060, 0.070, 1), 16)
    ui.drawCircle(center, 4, wheelColor, 16, 1)
    for index, themeColor in ipairs(__CPC.Theme.THEME_ACCENTS) do
      local swatchAngle = (index - 1) / #__CPC.Theme.THEME_ACCENTS * math.pi * 2 - math.pi / 2
      local swatch = center + vec2(math.cos(swatchAngle), math.sin(swatchAngle)) * 17
      ui.drawCircleFilled(swatch, 3.2, themeColor, 12)
      ui.drawCircle(swatch, 3.2, rgbm(0.94, 0.96, 1.0, 0.82), 12, 0.7)
      ui.setCursor(swatch - vec2(5, 5))
      ui.pushStyleColor(ui.StyleColor.Button, rgbm(0, 0, 0, 0))
      ui.pushStyleColor(ui.StyleColor.ButtonHovered, rgbm(1, 1, 1, 0.16))
      ui.pushStyleColor(ui.StyleColor.ButtonActive, rgbm(1, 1, 1, 0.26))
      if ui.button('##subwheelTheme:' .. index, vec2(10, 10)) then
        __CPC.settings.colorTheme = index
      end
      if ui.itemHovered() then ui.setTooltip(__CPC.Theme.THEME_NAMES[index]) end
      ui.popStyleColor(3)
    end

    if mainNode then
      local delta = center - mainNode
      local distance = math.max(1, math.sqrt(delta.x * delta.x + delta.y * delta.y))
      local direction = delta * (1 / distance)
      local startPoint = mainNode + direction * 29
      local endPoint = center - direction * (radius + 19)
      ui.drawLine(startPoint, endPoint, rgbm(accent.r, accent.g, accent.b, 0.30), 2)
      local travel = (os.preciseClock() * 0.10) % 1
      for segment = 0, 2 do
        local position = (travel + segment / 3) % 1
        local point = startPoint + (endPoint - startPoint) * position
        ui.drawCircleFilled(point, 2.5, accent, 12)
      end
    end

    for index, item in ipairs(tree.items) do
      local angle = (index - 1) / #tree.items * math.pi * 2 - math.pi / 2
      local direction = vec2(math.cos(angle), math.sin(angle))
      local node = center + direction * radius
      local active = selected == item[1]
      local color = active and accent or __CPC.Theme.COLOR_MUTED
      ui.drawLine(center + direction * 24, node - direction * 15,
        rgbm(color.r, color.g, color.b, active and 0.80 or 0.28), active and 1.7 or 0.8)
      ui.drawCircleFilled(node, 18, rgbm(color.r, color.g, color.b,
        active and (0.34 + __CPC.uiPulse(2.2, 0.45) * 0.25) or 0.15), 24)
      ui.drawCircle(node, 18, rgbm(color.r, color.g, color.b, active and 0.92 or 0.50), 24,
        active and 1.7 or 1)

      ui.setCursor(vec2(node.x - 22, node.y - 16))
      ui.pushStyleColor(ui.StyleColor.Button, rgbm(0, 0, 0, 0))
      ui.pushStyleColor(ui.StyleColor.ButtonHovered, rgbm(1, 1, 1, 0.10))
      ui.pushStyleColor(ui.StyleColor.ButtonActive, rgbm(1, 1, 1, 0.20))
      if ui.button('##tree:' .. (tree.key or 'help') .. ':' .. item[1], vec2(44, 32)) then
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
      ui.dwriteDrawTextClipped(item[2], 7, vec2(node.x - 18, node.y - 10),
        vec2(node.x + 18, node.y + 10), ui.Alignment.Center, ui.Alignment.Center,
        false, rgbm(0.98, 0.99, 1.0, 1))
      ui.popDWriteFont()
    end

    return true
  end

  function __CPC.drawSidebar()
    local pages = __CPC.WHEEL_PAGES
    local sidebarWidth = math.min(270, math.max(210, ui.availableSpaceX() * 0.30))
    local sidebarHeight = ui.availableSpaceY()
    ui.childWindow('mainSidebar', vec2(sidebarWidth, sidebarHeight), function()
      ui.drawRectFilled(vec2(0, 0), vec2(sidebarWidth, sidebarHeight),
        rgbm(0.012, 0.014, 0.020, 0.96), 8)
      ui.pushDWriteFont('@System;Weight=Bold;Stretch=Condensed')
      ui.dwriteDrawTextClipped('DRIVE SUITE', 17 * __CPC.settings.uiScale,
        vec2(14, 12), vec2(sidebarWidth - 10, 38), ui.Alignment.Start,
        ui.Alignment.Center, false, __CPC.Theme.COLOR_TEXT)
      ui.popDWriteFont()
      ui.drawText('PICK A SECTION', vec2(15, 42), __CPC.Theme.COLOR_MUTED)
      local previewPage, mainNode = __CPC.drawSettingsNavigationWheel(pages, sidebarWidth)
      local hasSubmenu = __CPC.drawSettingsTreeSubmenu(sidebarWidth, previewPage, mainNode)
      if not hasSubmenu then
        ui.setCursor(vec2(12, 270))
        ui.textWrapped('Choose a labelled stop on the wheel. Hover a stop to see what it controls.')
      end
    end)
    ui.sameLine(0, 10)
  end

  function __CPC.drawHomePage()
    __CPC.section('MASTER CONTROL', 'Pause every output instantly while keeping all tuning saved.')
    __CPC.toggle('Enable CPC Drive Suite', 'suiteEnabled')
    if __CPC.wheelSmoothScrollEnabled == nil then __CPC.wheelSmoothScrollEnabled = true end
    if ui.button(__CPC.wheelSmoothScrollEnabled and 'DISABLE WHEEL SCROLL' or 'ENABLE WHEEL SCROLL') then
      __CPC.wheelSmoothScrollEnabled = not __CPC.wheelSmoothScrollEnabled
      __CPC.wheelScrollToSettings = false
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
    ui.textWrapped('Use the pages on the left to change one part of the driving experience at a time. Start with LOOK > SIMPLE SUITE for the easiest controls.')
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
      [8] = 'Help: choose Big Panel for all settings or Compact for the essential controls while driving.'
    }
    ui.textWrapped(guide[__CPC.settings.uiPage] or '')
    ui.separator()
  end

  function __CPC.drawClutchPage()
    __CPC.section('ADAPTIVE CLUTCH')
    __CPC.toggle('Enable clutch assist', 'clutchEnabled')
    ui.sameLine()
    ui.textColored(__CPC.clutchStatus, __CPC.clutchStateColor())
    ui.progressBar(1 - math.min(__CPC.telemetry.rawClutch, __CPC.clutchCommand),
      vec2(ui.availableSpaceX(), 18),
      string.format('Effective clutch pressed %.0f%%',
        (1 - math.min(__CPC.telemetry.rawClutch, __CPC.clutchCommand)) * 100))

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
      'These settings control your view angle and the forward/back camera movement together. They use your current cockpit position as the starting point.')
    __CPC.drawSectionPresets('syncedBase')

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
    __CPC.section('THROTTLE CAMERA')
    __CPC.toggle('Enable throttle seat and FOV camera', 'throttleEnabled')
    ui.sameLine()
    ui.textColored(__CPC.throttleStatus,
      __CPC.throttleStatus == 'Active in cockpit' and __CPC.Theme.COLOR_ACTIVE or __CPC.Theme.COLOR_MUTED)

    __CPC.drawThrottleSyncControls()

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
      ui.text(string.format('Position X/Y/Z: %+.1f / %+.1f / %+.1f mm',
        __CPC.outputLateral * 1000, __CPC.outputVertical * 1000, __CPC.outputForward * 1000))
      ui.text(string.format('Pitch / yaw: %+.2f / %+.2f deg   FOV mix: %+.2f deg',
        __CPC.outputPitch, __CPC.outputYaw, __CPC.renderedFovMix * __CPC.throttleEffectScale))

    elseif __CPC.settings.throttlePage == 2 then
      __CPC.section('STARTING HEAD POSE',
        'Offsets are relative to the car saved seat and remain active at zero throttle.')
      __CPC.drawSectionPresets('startPose')
      __CPC.slider('Start X - left / right', 'throttleStartX', -0.30, 0.30, '%+.3f m')
      __CPC.slider('Start Y - down / up', 'throttleStartY', -0.30, 0.30, '%+.3f m')
      __CPC.slider('Start Z - back / forward', 'throttleStartZ', -1.00, 1.00, '%+.3f m')
      __CPC.slider('Start pitch - down / up', 'throttleStartPitch', -30, 30, '%+.1f deg')
      if ui.button('ZERO STARTING POSE') then __CPC.zeroThrottleStartPose() end

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
    __CPC.section('DYNAMIC 6DOF NECKFX')
    __CPC.toggle('Enable NeckFX output', 'neckEnabled')
    ui.sameLine()
    ui.textColored(__CPC.neckIsOnline() and 'BACKEND ONLINE' or 'BACKEND OFFLINE',
      __CPC.neckIsOnline() and __CPC.Theme.COLOR_ACTIVE or __CPC.Theme.COLOR_WARNING)

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
        'colorTheme', 'uiScale', 'hudMode', 'hudOpacity', 'hudAnimation',
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
    ui.textColored('PURPLE  /  PAGE NAVIGATION', __CPC.Theme.COLOR_SIDEBAR_PURPLE)
    ui.textWrapped('Purple buttons open the app pages. Each page contains direct settings with no preset layer.')
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
    return string.format('settingsScroll##%d:%d:%d:%d:%d:%d:%d:%d',
      __CPC.settings.uiPage, __CPC.settings.clutchPage, __CPC.settings.throttlePage,
      __CPC.settings.throttleFovPage, __CPC.settings.throttleLinearPage, __CPC.settings.neckPage,
      __CPC.settings.lookPage, __CPC.settings.throttleDynamicsPage)
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
    local gainNew = ui.slider('G-force sensitivity##smallGain', gainNow, 0.2, 3.0, '%.2fx')
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

  function __CPC.drawMainWindowContents(dt)
    if __CPC.settings.uiMode == 2 then
      local compactSize = vec2(math.max(220, ui.availableSpaceX()),
        math.max(120, ui.availableSpaceY() - 4))
      ui.childWindow('smallUiScroll', compactSize, function()
        __CPC.drawSmallUi()
      end)
      return
    end
    __CPC.drawMainChrome()
    local contentHeight = math.max(120, ui.availableSpaceY() - 5)
    local contentSize = vec2(math.max(240, ui.availableSpaceX()), contentHeight)
    ui.childWindow(__CPC.activeSettingsScrollId(), contentSize, function()
      local panelWidth = ui.availableSpaceX()
      local panelHeight = ui.availableSpaceY()
      local accent = __CPC.accentColor()
      ui.drawRectFilled(vec2(0, 0), vec2(panelWidth, panelHeight),
        rgbm(0.010, 0.013, 0.019, 0.96), 8)
      ui.drawRect(vec2(0, 0), vec2(panelWidth, panelHeight),
        rgbm(accent.r, accent.g, accent.b, 0.42), 8, 0, 1)

      local previewPage, mainNode = __CPC.drawSettingsNavigationWheel(__CPC.WHEEL_PAGES, panelWidth)
      ui.pushDWriteFont('@System;Weight=Bold;Stretch=Condensed')
      ui.dwriteDrawTextClipped('CLICK CIRCLES AND SCROLL DOWN FOR MORE SETTINGS', 11,
        vec2(18, 318), vec2(panelWidth - 18, 340), ui.Alignment.Center,
        ui.Alignment.Center, false, rgbm(0.22, 1.0, 0.48, 1))
      ui.popDWriteFont()
      __CPC.drawSettingsTreeSubmenu(panelWidth, previewPage, mainNode)
      local scrollColor = __CPC.accentColor(0.92)
      ui.drawRectFilled(vec2(16, 582), vec2(panelWidth - 16, 606),
        rgbm(scrollColor.r, scrollColor.g, scrollColor.b, 0.28), 4)
      ui.drawRect(vec2(16, 582), vec2(panelWidth - 16, 606), scrollColor, 4, 0, 1.4)
      local arrowCenter = panelWidth * 0.5
      ui.drawLine(vec2(arrowCenter - 10, 592), vec2(arrowCenter, 586), scrollColor, 1.5)
      ui.drawLine(vec2(arrowCenter, 586), vec2(arrowCenter + 10, 592), scrollColor, 1.5)
      ui.drawLine(vec2(arrowCenter - 10, 596), vec2(arrowCenter, 602), scrollColor, 1.5)
      ui.drawLine(vec2(arrowCenter, 602), vec2(arrowCenter + 10, 596), scrollColor, 1.5)
      ui.pushDWriteFont('@System;Weight=Bold;Stretch=Condensed')
      ui.dwriteDrawTextClipped('SCROLL DOWN FOR MORE SETTINGS', 10,
        vec2(18, 609), vec2(panelWidth - 18, 626), ui.Alignment.Center,
        ui.Alignment.Center, false, rgbm(1, 0.94, 0.94, 1))
      ui.popDWriteFont()
      ui.setCursor(vec2(18, 636))
      ui.pushDWriteFont('@System;Weight=Regular;Stretch=Condensed')
      __CPC.drawBigUiGuide()
      __CPC.drawActiveSettingsPage()
      ui.popDWriteFont()
      if __CPC.wheelScrollToSettings then
        local currentScroll = ui.getScrollY()
        local targetScroll = 636
        local lastScroll = __CPC.wheelScrollLastPosition
        if lastScroll ~= nil and currentScroll <= lastScroll then
          __CPC.wheelScrollToSettings = false
          __CPC.wheelScrollLastPosition = nil
        elseif currentScroll < targetScroll then
          ui.setScrollY(math.min(targetScroll, currentScroll + math.max(dt or 0, 0) * 220))
          __CPC.wheelScrollLastPosition = currentScroll
        else
          __CPC.wheelScrollToSettings = false
          __CPC.wheelScrollLastPosition = nil
        end
      end
      ui.dummy(vec2(1, 18))
    end)
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
