return [====[
    else ui.pathFillConvex(color) end
  end

  function __CPC.HUD.drawPedal(ctx, x, label, value, color, targetValue,
      baseY, visualScale)
    value = __CPC.Math.saturate(value)
    local s = ctx.scale
    baseY = baseY or 182
    visualScale = visualScale or 1
    local ps = s * visualScale
    local center = __CPC.HUD.point(ctx, x + value * 2.5 * visualScale,
      baseY - 24 * visualScale + value * 6 * visualScale)
    local angle = -0.06 + value * 0.14
    local axisX = vec2(math.cos(angle), math.sin(angle))
    local axisY = vec2(-math.sin(angle), math.cos(angle))
    local halfWidth, halfHeight = 17 * ps, 22 * ps

    -- Pedal base and live digital gauge are drawn over the steering wheel.
    local baseP1 = __CPC.HUD.point(ctx, x - 28 * visualScale, baseY)
    local baseP2 = __CPC.HUD.point(ctx, x + 28 * visualScale,
      baseY + 66 * visualScale)
    ui.drawRectFilled(baseP1, baseP2,
      rgbm(0.008, 0.010, 0.014, 0.90 * __CPC.settings.hudOpacity), 5 * ps)
    ui.drawRect(baseP1, baseP2, __CPC.HUD.color(__CPC.accentColor(), 0.72), 5 * ps, 0,
      math.max(1, ps))
    ui.drawRect(__CPC.HUD.point(ctx, x - 24 * visualScale, baseY + 5 * visualScale),
      __CPC.HUD.point(ctx, x + 24 * visualScale, baseY + 62 * visualScale),
      rgbm(0.62, 0.64, 0.68, 0.28), 3 * ps, 0, math.max(1, 0.65 * ps))
    for _, bolt in ipairs({ { -23, 7 }, { 23, 7 }, { -23, 59 }, { 23, 59 } }) do
      local boltPos = __CPC.HUD.point(ctx, x + bolt[1] * visualScale,
        baseY + bolt[2] * visualScale)
      ui.drawCircleFilled(boltPos, 1.5 * ps, rgbm(0.68, 0.70, 0.74, 0.90), 12)
      ui.drawCircle(boltPos, 1.5 * ps, rgbm(0.04, 0.05, 0.06, 1), 12,
        math.max(1, 0.4 * ps))
    end
    ui.drawRectFilled(__CPC.HUD.point(ctx, x - 24 * visualScale,
        baseY + 3 * visualScale), __CPC.HUD.point(ctx, x + 24 * visualScale,
        baseY + 6 * visualScale), __CPC.HUD.color(color, 0.18 + value * 0.62), 2 * ps)

    if targetValue ~= nil then
      local target = __CPC.Math.saturate(targetValue)
      local targetCenter = __CPC.HUD.point(ctx, x + target * 2.5 * visualScale,
        baseY - 24 * visualScale + target * 6 * visualScale)
      local targetAngle = -0.06 + target * 0.14
      local tx = vec2(math.cos(targetAngle), math.sin(targetAngle))
      local ty = vec2(-math.sin(targetAngle), math.cos(targetAngle))
      __CPC.HUD.pedalPath(targetCenter, tx, ty, halfWidth + 2 * ps, halfHeight + 2 * ps,
        __CPC.HUD.color(__CPC.accentColor(), 0.48), true, math.max(1, ps))
    end

    local armStart = __CPC.HUD.point(ctx, x, baseY + 12 * visualScale)
    local armEnd = center + axisY * (halfHeight - 2 * ps)
    ui.drawLine(armStart, armEnd, rgbm(0.58, 0.60, 0.64, 1),
      math.max(2, 7 * ps))
    ui.drawLine(armStart, armEnd, rgbm(0.045, 0.050, 0.060, 1),
      math.max(1, 3 * ps))

    -- Layered metal face with five recessed grip holes.
    __CPC.HUD.pedalPath(center, axisX, axisY, halfWidth, halfHeight,
      rgbm(0.55, 0.57, 0.61, 1), false)
    __CPC.HUD.pedalPath(center + axisY * ps, axisX, axisY, halfWidth - 2 * ps,
      halfHeight - 2 * ps, rgbm(0.31, 0.33, 0.37, 1), false)
    __CPC.HUD.pedalPath(center, axisX, axisY, halfWidth, halfHeight,
      value > 0.01 and color or __CPC.Theme.COLOR_MUTED, true, math.max(1, 1.4 * ps))
    for brushedLine = -16, 16, 4 do
      local lineCenter = center + axisY * (brushedLine * ps)
      ui.drawLine(lineCenter - axisX * (13 * ps),
        lineCenter + axisX * (13 * ps), rgbm(0.86, 0.88, 0.92, 0.13),
        math.max(1, 0.38 * ps))
    end
    for _, hole in ipairs({ { -8, -12 }, { 8, -12 }, { 0, 0 },
        { -8, 12 }, { 8, 12 } }) do
      local holeCenter = center + axisX * (hole[1] * ps) + axisY * (hole[2] * ps)
      ui.drawCircleFilled(holeCenter, 3.2 * ps, rgbm(0.006, 0.007, 0.009, 1), 16)
      ui.drawCircle(holeCenter, 3.2 * ps, rgbm(0.72, 0.74, 0.78, 0.82), 16,
        math.max(1, 0.7 * ps))
    end

    __CPC.HUD.label(ctx, label, x - 24 * visualScale, baseY + 8 * visualScale,
      x + 24 * visualScale, baseY + 23 * visualScale,
      value > 0.01 and color or __CPC.Theme.COLOR_MUTED, 9 * visualScale,
      ui.Alignment.Center, true)
    local activeSegments = math.floor(value * 5 + 0.5)
    for segment = 1, 5 do
      local y1 = baseY + (52 - segment * 5) * visualScale
      ui.drawRectFilled(__CPC.HUD.point(ctx, x - 21 * visualScale, y1),
        __CPC.HUD.point(ctx, x - 15 * visualScale, y1 + 3 * visualScale),
        segment <= activeSegments and color or rgbm(0.12, 0.13, 0.15, 0.85), ps)
    end
    __CPC.HUD.label(ctx, string.format('%.0f%%', value * 100),
      x - 11 * visualScale, baseY + 25 * visualScale,
      x + 24 * visualScale, baseY + 58 * visualScale,
      value > 0.01 and color or __CPC.Theme.COLOR_MUTED, 15 * visualScale,
      ui.Alignment.Center, true)
  end

  function __CPC.HUD.drawBackground(ctx, accent)
    ui.setCursor(vec2(0, 0))
    ui.dummy(vec2(1, 1))
    ui.drawRectFilled(__CPC.HUD.point(ctx, 12, 2), __CPC.HUD.point(ctx, 708, 4),
      __CPC.HUD.color(accent, 0.88), 2 * ctx.scale)
  end

  function __CPC.HUD.drawHeader(ctx, accent, stateText, stateColor)
    __CPC.HUD.panel(ctx, 12, 27, 708, 70, accent, 0.70, 8)
    ui.pushDWriteFont('@System;Weight=Black;Stretch=Condensed')
    ui.dwriteDrawTextClipped('CPC DRIVE SUITE', 22 * ctx.scale,
      __CPC.HUD.point(ctx, 23, 29), __CPC.HUD.point(ctx, 520, 53),
      ui.Alignment.Start, ui.Alignment.Center, false, __CPC.Theme.COLOR_TEXT)
    ui.popDWriteFont()
    __CPC.HUD.label(ctx, 'DRIVER INPUT  /  CAMERA MOTION  /  NECKFX', 24, 52, 520, 68,
      __CPC.Theme.COLOR_MUTED, 10, ui.Alignment.Start)
    local pulseStrength = __CPC.Math.clamp(__CPC.settings.hudAnimation, 0, 1.5)
    local pulse = 1
    if __CPC.clutchStatusKind == 'action' and pulseStrength > 0 then
      pulse = 0.82 + 0.18 * math.sin(__CPC.elapsedTime * (8 + 6 * pulseStrength)) *
        math.min(pulseStrength, 1)
    end
    local p1, p2 = __CPC.HUD.point(ctx, 566, 37), __CPC.HUD.point(ctx, 696, 62)
    ui.drawRectFilled(p1, p2,
      __CPC.HUD.color(stateColor, (0.13 + 0.05 * pulse) * __CPC.settings.hudOpacity), 11 * ctx.scale)
    ui.drawRect(p1, p2, stateColor, 11 * ctx.scale, 0, math.max(1, ctx.scale))
    __CPC.HUD.label(ctx, stateText, 566, 37, 696, 62, stateColor, 11,
      ui.Alignment.Center, true)
  end

  function __CPC.HUD.drawRPM(ctx, accent, y1, y2)
    if not __CPC.settings.hudShowRPM then return end
    local fraction = __CPC.Math.saturate((__CPC.telemetry.rpm - __CPC.telemetry.idleRPM) /
      math.max(__CPC.telemetry.limiterRPM - __CPC.telemetry.idleRPM, 1))
    local color = fraction > 0.88 and __CPC.Theme.COLOR_WARNING
      or (fraction > 0.68 and __CPC.Theme.COLOR_ACTION or accent)
    __CPC.HUD.progress(ctx, 16, y1, 704, y2, fraction, color,
      string.format('RPM %.0f / %.0f     %+.0f per sec',
        __CPC.telemetry.rpm, __CPC.telemetry.limiterRPM, __CPC.rpmTrend))
  end

  function __CPC.HUD.state()
    if not __CPC.settings.suiteEnabled then return 'PAUSED', __CPC.Theme.COLOR_WARNING end
    if __CPC.clutchStatusKind == 'warning' then return 'CHECK', __CPC.Theme.COLOR_WARNING end
    if __CPC.clutchStatusKind == 'action' then return 'ACTING', __CPC.Theme.COLOR_ACTION end
    return 'ACTIVE', __CPC.Theme.COLOR_ACTIVE
  end

  function __CPC.HUD.displaySpeed()
    if __CPC.settings.hudSpeedMph then return __CPC.telemetry.speed * 0.621371, 'mph' end
    return __CPC.telemetry.speed, 'km/h'
  end

  function __CPC.HUD.drawFull(ctx, accent, inputsOnly)
    local stateText, stateColor = __CPC.HUD.state()
    __CPC.HUD.drawBackground(ctx, accent)
    __CPC.HUD.drawHeader(ctx, accent, stateText, stateColor)
    __CPC.HUD.drawRPM(ctx, accent, 78, 96)

    -- The steering wheel is deliberately drawn first so the pedals sit in front.
    if __CPC.settings.hudShowWheel then __CPC.HUD.drawWheel(ctx, 180, 173, 68, accent) end
    if __CPC.settings.hudShowPedals then
      local effectiveClutch = math.min(__CPC.telemetry.rawClutch, __CPC.clutchCommand)
      __CPC.HUD.drawPedal(ctx, 113, 'CLUTCH', 1 - effectiveClutch, accent,
        1 - __CPC.clutchTarget)
      __CPC.HUD.drawPedal(ctx, 180, 'BRAKE', __CPC.telemetry.brake, accent)
      __CPC.HUD.drawPedal(ctx, 247, 'THROTTLE', __CPC.telemetry.gas, accent)
    end

    local gearX1 = inputsOnly and 375 or 356
    local gearX2 = inputsOnly and 485 or 442
    __CPC.HUD.panel(ctx, gearX1, 106, gearX2, 249, accent, 0.90, 8)
    __CPC.HUD.label(ctx, 'GEAR', gearX1, 111, gearX2, 132, __CPC.Theme.COLOR_MUTED, 11,
      ui.Alignment.Center, true)
    local gear = __CPC.telemetry.gear == 0 and 'N'
      or (__CPC.telemetry.gear == -1 and 'R' or tostring(__CPC.telemetry.gear))
    __CPC.HUD.label(ctx, gear, gearX1, 128, gearX2, 231, __CPC.Theme.COLOR_TEXT, 61,
      ui.Alignment.Center, true)

    local speed, speedUnit = __CPC.HUD.displaySpeed()
    local speedX1 = gearX2 + 10
    local speedX2 = inputsOnly and 704 or 566
    __CPC.HUD.panel(ctx, speedX1, 106, speedX2, 249, accent, 0.90, 8)
    __CPC.HUD.label(ctx, 'ROAD SPEED', speedX1, 111, speedX2, 132, __CPC.Theme.COLOR_MUTED, 10,
]====]
