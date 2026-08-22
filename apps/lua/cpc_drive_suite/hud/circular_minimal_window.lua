return [====[
    local r = radius * s

    ui.drawCircleFilled(center, r, rgbm(0.006, 0.008, 0.011, 0.88 * __CPC.settings.hudOpacity), 64)
    ui.drawCircle(center, r, __CPC.HUD.color(accent, 0.76), 64, math.max(1, 1.5 * s))
    ui.drawCircle(center, r - 3 * s, rgbm(0.72, 0.74, 0.78, 0.22), 64, math.max(1, 0.7 * s))

    __CPC.HUD.label(ctx, 'G-FORCE', x - radius + 5, y - radius + 8,
      x + radius - 5, y - radius + 24, __CPC.Theme.COLOR_MUTED, 9,
      ui.Alignment.Center, true)

    -- Ball graphic sits in the middle band, between the title and peak readout.
    local ballCenter = __CPC.HUD.point(ctx, x, y + radius * 0.06)
    local ballRadius = radius * 0.62 * s
    ui.drawCircle(ballCenter, ballRadius, rgbm(0.40, 0.42, 0.46, 0.30), 48, math.max(1, s))
    ui.drawCircle(ballCenter, ballRadius * 0.5, rgbm(0.40, 0.42, 0.46, 0.22), 48, math.max(1, s))
    ui.drawLine(ballCenter - vec2(ballRadius, 0), ballCenter + vec2(ballRadius, 0),
      rgbm(0.40, 0.42, 0.46, 0.22), math.max(1, s))
    ui.drawLine(ballCenter - vec2(0, ballRadius), ballCenter + vec2(0, ballRadius),
      rgbm(0.40, 0.42, 0.46, 0.22), math.max(1, s))

    local scaleG = 2.2
    local function toPoint(lat, long)
      local nx = __CPC.Math.clamp(lat / scaleG, -1, 1)
      local ny = __CPC.Math.clamp(-long / scaleG, -1, 1)
      return ballCenter + vec2(nx, ny) * (ballRadius - 4 * s)
    end

    if trace.peakMagnitude > 0.05 then
      ui.drawCircle(toPoint(trace.peakLat, trace.peakLong), 3.6 * s,
        __CPC.HUD.color(__CPC.Theme.COLOR_WARNING, 0.85), 16, math.max(1, s))
    end
    local livePoint = toPoint(trace.lat, trace.long)
    ui.drawCircleFilled(livePoint, 4.6 * s, accent, 16)
    ui.drawCircle(livePoint, 4.6 * s, rgbm(0.02, 0.02, 0.03, 1), 16, math.max(1, s))

    __CPC.HUD.label(ctx, string.format('%.2f G PEAK', trace.peakMagnitude),
      x - radius + 5, y + radius - 22, x + radius - 5, y + radius - 5,
      __CPC.Theme.COLOR_TEXT, 10, ui.Alignment.Center, true)
  end

  function __CPC.HUD.drawCircular(ctx, accent, inputsOnly)
    local stateText, stateColor = __CPC.HUD.state()
    local effectiveClutch = math.min(__CPC.telemetry.rawClutch, __CPC.clutchCommand)
    local speed, speedUnit = __CPC.HUD.displaySpeed()
    local gear = __CPC.telemetry.gear == 0 and 'N'
      or (__CPC.telemetry.gear == -1 and 'R' or tostring(__CPC.telemetry.gear))

    __CPC.HUD.drawCircularBackground(ctx, accent)
    __CPC.HUD.drawCircularRPM(ctx, accent)

    -- The large steering wheel is the HUD structure and all other modules layer over it.
    if __CPC.settings.hudShowWheel then
      __CPC.HUD.drawWheel(ctx, 360, 350, 238, accent)
      __CPC.HUD.label(ctx, '-900°\nLEFT', 37, 321, 118, 378, accent, 12,
        ui.Alignment.Center, true)
      __CPC.HUD.label(ctx, '+900°\nRIGHT', 602, 321, 683, 378, accent, 12,
        ui.Alignment.Center, true)
    end

    local headerP1, headerP2 = __CPC.HUD.point(ctx, 222, 26), __CPC.HUD.point(ctx, 498, 91)
    ui.drawRectFilled(headerP1, headerP2,
      rgbm(0.008, 0.010, 0.014, 0.88 * __CPC.settings.hudOpacity), 28 * ctx.scale)
    ui.drawRect(headerP1, headerP2, __CPC.HUD.color(accent, 0.88), 28 * ctx.scale,
      0, math.max(1, 1.8 * ctx.scale))
    ui.drawRect(__CPC.HUD.point(ctx, 228, 32), __CPC.HUD.point(ctx, 492, 85),
      rgbm(0.70, 0.72, 0.76, 0.25), 23 * ctx.scale, 0,
      math.max(1, 0.75 * ctx.scale))
    ui.drawLine(__CPC.HUD.point(ctx, 257, 68), __CPC.HUD.point(ctx, 463, 68),
      __CPC.HUD.color(accent, 0.38), math.max(1, ctx.scale))
    ui.drawCircleFilled(__CPC.HUD.point(ctx, 241, 58), 2.2 * ctx.scale, accent, 16)
    ui.drawCircleFilled(__CPC.HUD.point(ctx, 479, 58), 2.2 * ctx.scale, accent, 16)
    __CPC.HUD.label(ctx, 'CPC DRIVER INPUT', 235, 31, 485, 64, __CPC.Theme.COLOR_TEXT, 21,
      ui.Alignment.Center, true)
    __CPC.HUD.label(ctx, string.format('LIVE TELEMETRY   •   RPM %.0f', __CPC.telemetry.rpm),
      238, 61, 482, 84, accent, 10, ui.Alignment.Center, true)

    local stateP1, stateP2 = __CPC.HUD.point(ctx, 292, 95), __CPC.HUD.point(ctx, 428, 125)
    ui.drawRectFilled(stateP1, stateP2, __CPC.HUD.color(stateColor,
      0.16 * __CPC.settings.hudOpacity), 15 * ctx.scale)
    ui.drawRect(stateP1, stateP2, stateColor, 15 * ctx.scale, 0,
      math.max(1, ctx.scale))
    __CPC.HUD.label(ctx, '●  ' .. stateText, 292, 96, 428, 124, stateColor, 11,
      ui.Alignment.Center, true)

    __CPC.HUD.drawShiftLights(ctx, 246, 131, 474, 143, 14, accent)
    -- Wheel center (360,350) matches drawWheel's hub, so the G-meter sits inside it.
    __CPC.HUD.drawGMeter(ctx, 360, 350, 50, accent)

    if __CPC.HUD.trace.gearFlash > 0 then
      ui.drawCircle(__CPC.HUD.point(ctx, 160, 314), (48 + 6 * __CPC.HUD.trace.gearFlash) * ctx.scale,
        __CPC.HUD.color(accent, 0.55 * __CPC.HUD.trace.gearFlash), 64, math.max(1, 2 * ctx.scale))
    end
    __CPC.HUD.drawCircularValuePod(ctx, 160, 314, 48, accent, 'GEAR', gear, nil, __CPC.Theme.COLOR_TEXT)
    __CPC.HUD.drawCircularValuePod(ctx, 560, 314, 48, accent, 'SPEED',
      string.format('%.0f', speed), speedUnit, __CPC.Theme.COLOR_TEXT)

    if not inputsOnly and __CPC.settings.hudShowCamera then
      __CPC.HUD.drawCircularValuePod(ctx, 148, 420, 43, accent, 'CAMERA',
        string.format('%.1f°', __CPC.renderedFov), 'FOV', accent)
      __CPC.HUD.drawCircularValuePod(ctx, 572, 420, 43, accent, 'NECKFX',
        string.format('%.0f%%', __CPC.neckTelemetry.effectStrength * 100),
        __CPC.neckIsOnline() and 'ONLINE' or 'OFFLINE',
        __CPC.neckIsOnline() and __CPC.Theme.COLOR_ACTIVE or __CPC.Theme.COLOR_WARNING)
    end

    -- Pedals are the foreground layer over the lower wheel rim and spokes.
    if __CPC.settings.hudShowPedals then
      __CPC.HUD.drawPedal(ctx, 245, 'CLUTCH', 1 - effectiveClutch, accent,
        1 - __CPC.clutchTarget, 477, 1.70)
      __CPC.HUD.drawPedal(ctx, 360, 'BRAKE', __CPC.telemetry.brake, accent, nil, 477, 1.70)
      __CPC.HUD.drawPedal(ctx, 475, 'THROTTLE', __CPC.telemetry.gas, accent, nil, 477, 1.70)
    end

    if __CPC.settings.hudShowStatus then
      local statusColor = __CPC.clutchStateColor()
      local p1, p2 = __CPC.HUD.point(ctx, 187, 638), __CPC.HUD.point(ctx, 533, 690)
      ui.drawRectFilled(p1, p2, __CPC.HUD.color(statusColor,
        (0.12 + __CPC.actionFlash * 0.18 * __CPC.settings.hudAnimation) * __CPC.settings.hudOpacity),
        25 * ctx.scale)
      ui.drawRect(p1, p2, statusColor, 25 * ctx.scale, 0,
        math.max(1, 1.5 * ctx.scale))
      ui.drawRect(__CPC.HUD.point(ctx, 193, 644), __CPC.HUD.point(ctx, 527, 684),
        rgbm(0.72, 0.74, 0.78, 0.22), 20 * ctx.scale, 0,
        math.max(1, 0.7 * ctx.scale))
      __CPC.HUD.label(ctx, __CPC.clutchStatus, 204, 642, 516, 666, statusColor, 12,
        ui.Alignment.Center, true)
      __CPC.HUD.label(ctx, string.format('CLUTCH %.0f%% PRESSED',
        (1 - effectiveClutch) * 100), 204, 665, 516, 686, accent, 10,
        ui.Alignment.Center, true)
    end
  end

  function __CPC.HUD.drawMinimal(ctx, accent)
    local stateText, stateColor = __CPC.HUD.state()
    __CPC.HUD.drawBackground(ctx, accent)
    __CPC.HUD.drawHeader(ctx, accent, stateText, stateColor)
    __CPC.HUD.drawRPM(ctx, accent, 78, 98)
    __CPC.HUD.drawShiftLights(ctx, 16, 100, 704, 107, 24, accent)
    local gear = __CPC.telemetry.gear == 0 and 'N'
      or (__CPC.telemetry.gear == -1 and 'R' or tostring(__CPC.telemetry.gear))
    if __CPC.HUD.trace.gearFlash > 0 then
      ui.drawRect(__CPC.HUD.point(ctx, 16, 109), __CPC.HUD.point(ctx, 126, 175),
        __CPC.HUD.color(accent, 0.65 * __CPC.HUD.trace.gearFlash), 7 * ctx.scale, 0,
        math.max(2, 3 * ctx.scale))
    end
    __CPC.HUD.panel(ctx, 16, 109, 126, 175, accent, 0.90, 7)
    __CPC.HUD.label(ctx, gear, 16, 109, 126, 175, __CPC.Theme.COLOR_TEXT, 43,
      ui.Alignment.Center, true)
    local speed, unit = __CPC.HUD.displaySpeed()
    __CPC.HUD.panel(ctx, 136, 109, 320, 175, accent, 0.90, 7)
    __CPC.HUD.label(ctx, string.format('%.0f  %s', speed, unit), 136, 109, 320, 175,
      __CPC.Theme.COLOR_TEXT, 25, ui.Alignment.Center, true)
    local effectiveClutch = math.min(__CPC.telemetry.rawClutch, __CPC.clutchCommand)
    __CPC.HUD.progress(ctx, 330, 109, 704, 140, 1 - effectiveClutch, accent,
      string.format('CLUTCH %.0f%% PRESSED', (1 - effectiveClutch) * 100))
    __CPC.HUD.label(ctx, __CPC.clutchStatus, 339, 143, 695, 175, __CPC.clutchStateColor(), 12,
      ui.Alignment.Center, true)
    if __CPC.settings.hudShowStatus then
      local color = __CPC.clutchStateColor()
      local p1, p2 = __CPC.HUD.point(ctx, 16, 186), __CPC.HUD.point(ctx, 704, 224)
      ui.drawRectFilled(p1, p2, __CPC.HUD.color(color, 0.10 + __CPC.actionFlash * 0.17),
        7 * ctx.scale)
      ui.drawRect(p1, p2, color, 7 * ctx.scale, 0, math.max(1, ctx.scale))
      __CPC.HUD.label(ctx, string.format('GAS %.0f%%  BRK %.0f%%  WHL %+.0f%%  G %.1f',
        __CPC.telemetry.gas * 100, __CPC.telemetry.brake * 100, __CPC.telemetry.steer * 100,
        __CPC.HUD.trace.peakMagnitude),
        28, 187, 408, 223, __CPC.Theme.COLOR_TEXT, 12, ui.Alignment.Start, true)
      __CPC.HUD.label(ctx, string.format('FOV %.1f°   NECK %.0f%%',
        __CPC.renderedFov, __CPC.neckTelemetry.effectStrength * 100),
        420, 187, 692, 223, accent, 12, ui.Alignment.Center, true)
    end
  end

  function script.windowHUD(dt)
    ac.setWindowBackground('hud', rgbm(0, 0, 0, 0), true)
    __CPC.HUD.updateTrace(dt or 0)
    local accent = __CPC.accentColor()
    if __CPC.settings.hudMode == 3 then
      __CPC.HUD.drawMinimal(__CPC.HUD.context(238), accent)
    elseif __CPC.settings.hudMode == 2 then
      __CPC.HUD.drawCircular(__CPC.HUD.context(720), accent, true)
    else
      __CPC.HUD.drawCircular(__CPC.HUD.context(720), accent, false)
    end
  end
end
]====]
