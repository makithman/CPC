return [====[
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
      vec2(24, 22), vec2(size.x - 24, 54), ui.Alignment.Center,
      ui.Alignment.Center, false, accent)
    ui.popDWriteFont()

    ui.pushDWriteFont('@System;Weight=Bold;Stretch=Condensed')
    ui.dwriteDrawTextClipped('ADAPTIVE CLUTCH  |  THROTTLE CAMERA  |  DYNAMIC 6DOF', 10,
      vec2(24, 54), vec2(size.x - 24, 70), ui.Alignment.Center,
      ui.Alignment.Center, false, __CPC.Theme.COLOR_MUTED)
    ui.dwriteDrawTextClipped(string.format('%s  |  %s  |  UI SCALE %.2fx', stateText,
        __CPC.Theme.THEME_NAMES[themeIndex], __CPC.settings.uiScale), 9,
      vec2(24, 72), vec2(size.x - 24, 88), ui.Alignment.Center,
      ui.Alignment.Center, false, stateColor)
    ui.popDWriteFont()

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
    local wheelScale = __CPC.Math.clamp(__CPC.settings.uiWheelScale or 1, 0.75, 1.25)
    local radius = math.min(122, math.max(76, sidebarWidth * 0.22)) * wheelScale
    local time = os.preciseClock()
    local accent = __CPC.accentColor()
    local activePage = __CPC.settings.uiPage
    local glow = 0.20 + __CPC.uiPulse(2.1, 0.35) * 0.20
    local selectedNode = nil

    ui.drawCircleFilled(center, radius + 38 * wheelScale, rgbm(0.006, 0.008, 0.012, 0.94), 96)
    ui.drawCircle(center, radius + 36 * wheelScale, rgbm(accent.r, accent.g, accent.b, glow), 96, 2 * wheelScale)
    ui.drawCircle(center, radius + 31 * wheelScale, rgbm(0.70, 0.72, 0.77, 0.28), 96, wheelScale)
    ui.drawCircle(center, radius - 10 * wheelScale, rgbm(0.035, 0.040, 0.050, 0.92), 96, 3 * wheelScale)
    ui.drawCircle(center, radius - 15 * wheelScale, rgbm(accent.r, accent.g, accent.b, 0.20), 96, wheelScale)

    for tick = 0, 23 do
      local angle = tick / 24 * math.pi * 2 - math.pi / 2
      local direction = vec2(math.cos(angle), math.sin(angle))
      local active = tick / 24 <= ((__CPC.telemetry.gas or 0) * 0.6 + 0.20)
      ui.drawLine(center + direction * (radius + 21 * wheelScale),
        center + direction * (radius + 28 * wheelScale),
        active and accent or rgbm(0.28, 0.30, 0.34, 0.62), (active and 1.6 or 0.8) * wheelScale)
    end

    ui.drawCircleFilled(center, 30 * wheelScale, rgbm(0.008, 0.010, 0.014, 0.98), 48)
    ui.drawCircle(center, 30 * wheelScale, rgbm(accent.r, accent.g, accent.b, 0.70), 48, 1.5 * wheelScale)
    local wheelColor = __CPC.accentColor(0.96)
    ui.drawCircleFilled(center, 19 * wheelScale, rgbm(0.015, 0.018, 0.024, 1), 32)
    ui.drawCircle(center, 17 * wheelScale, wheelColor, 32, 4 * wheelScale)
    ui.drawCircle(center, 13 * wheelScale, rgbm(accent.r, accent.g, accent.b, 0.58), 32, wheelScale)
    for _, spokeAngle in ipairs({ -math.pi / 2, math.pi / 6, math.pi * 5 / 6 }) do
      local direction = vec2(math.cos(spokeAngle), math.sin(spokeAngle))
      ui.drawLine(center + direction * (4 * wheelScale), center + direction * (14 * wheelScale),
        wheelColor, 2.5 * wheelScale)
    end
    ui.drawCircleFilled(center, 5 * wheelScale, rgbm(0.055, 0.060, 0.070, 1), 20)
]====]
