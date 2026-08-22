-- CPC Drive Suite 3.9.2 — Telemetry HUD
-- Generated from the former monolithic core. Shared runtime values live in __CPC.

return function(__CPC)
  -- Custom telemetry HUD -------------------------------------------------------

  __CPC.HUD = {}

  -- Derived HUD-only state: live/peak G-force vector and gear-change flash.
  __CPC.HUD.trace = {
    lat = 0, long = 0,
    peakLat = 0, peakLong = 0, peakMagnitude = 0, peakHold = 0,
    gear = nil, gearFlash = 0
  }

  function __CPC.HUD.updateTrace(dt)
    dt = __CPC.Math.clamp(dt or 0, 0, 0.1)
    local trace = __CPC.HUD.trace
    trace.lat = __CPC.Math.finiteNumber(__CPC.telemetry.accelerationX, 0)
    trace.long = -__CPC.Math.finiteNumber(__CPC.telemetry.accelerationZ, 0)
    local magnitude = math.sqrt(trace.lat * trace.lat + trace.long * trace.long)
    if magnitude >= trace.peakMagnitude then
      trace.peakLat, trace.peakLong, trace.peakMagnitude, trace.peakHold = trace.lat, trace.long, magnitude, 1.5
    elseif trace.peakHold > 0 then
      trace.peakHold = math.max(0, trace.peakHold - dt)
    else
      trace.peakLat = __CPC.Math.expSmooth(trace.peakLat, trace.lat, 1.4, dt)
      trace.peakLong = __CPC.Math.expSmooth(trace.peakLong, trace.long, 1.4, dt)
      trace.peakMagnitude = math.sqrt(trace.peakLat * trace.peakLat + trace.peakLong * trace.peakLong)
    end

    if trace.gear == nil then trace.gear = __CPC.telemetry.gear end
    if __CPC.telemetry.gear ~= trace.gear then
      trace.gear = __CPC.telemetry.gear
      trace.gearFlash = 1
    end
    trace.gearFlash = math.max(0, trace.gearFlash - dt * 2.5)
  end

  function __CPC.HUD.context(baseHeight)
    local size = ui.windowSize()
    local scale = math.min(size.x / 720, size.y / baseHeight)
    local origin = vec2((size.x - 720 * scale) * 0.5,
      (size.y - baseHeight * scale) * 0.5)
    return { size = size, scale = scale, origin = origin, baseHeight = baseHeight }
  end

  function __CPC.HUD.point(ctx, x, y)
    return ctx.origin + vec2(x * ctx.scale, y * ctx.scale)
  end

  function __CPC.HUD.color(color, alpha)
    return rgbm(color.r, color.g, color.b, alpha)
  end

  function __CPC.HUD.label(ctx, text, x1, y1, x2, y2, color, size, align, bold)
    if bold then ui.pushDWriteFont('@System;Weight=Bold;Stretch=Condensed') end
    ui.dwriteDrawTextClipped(text, math.max(8, (size or 13) * ctx.scale),
      __CPC.HUD.point(ctx, x1, y1), __CPC.HUD.point(ctx, x2, y2),
      align or ui.Alignment.Center, ui.Alignment.Center, false, color or __CPC.Theme.COLOR_TEXT)
    if bold then ui.popDWriteFont() end
  end

  function __CPC.HUD.panel(ctx, x1, y1, x2, y2, accent, fillAlpha, rounding)
    local p1, p2 = __CPC.HUD.point(ctx, x1, y1), __CPC.HUD.point(ctx, x2, y2)
    ui.drawRectFilled(p1, p2, rgbm(0.035, 0.038, 0.045,
      (fillAlpha or 0.88) * __CPC.settings.hudOpacity), (rounding or 7) * ctx.scale)
    ui.drawRect(p1, p2, __CPC.HUD.color(accent, 0.48),
      (rounding or 7) * ctx.scale, 0, math.max(1, ctx.scale))
  end

  function __CPC.HUD.progress(ctx, x1, y1, x2, y2, value, color, label)
    value = __CPC.Math.saturate(value)
    local p1, p2 = __CPC.HUD.point(ctx, x1, y1), __CPC.HUD.point(ctx, x2, y2)
    ui.drawRectFilled(p1, p2, rgbm(0.005, 0.006, 0.008,
      0.90 * __CPC.settings.hudOpacity), 5 * ctx.scale)
    if value > 0.002 then
      local fillP2 = vec2(p1.x + (p2.x - p1.x) * value, p2.y)
      ui.drawRectFilledMultiColor(p1, fillP2,
        __CPC.HUD.color(color, 0.55), color, color, __CPC.HUD.color(color, 0.55))
    end
    ui.drawRect(p1, p2, __CPC.HUD.color(color, 0.58), 5 * ctx.scale,
      0, math.max(1, ctx.scale))
    if label then __CPC.HUD.label(ctx, label, x1 + 5, y1, x2 - 5, y2, __CPC.Theme.COLOR_TEXT, 12) end
  end

  function __CPC.HUD.drawWheel(ctx, x, y, radius, accent)
    local center = __CPC.HUD.point(ctx, x, y)
    local r = radius * ctx.scale
    local steer = __CPC.Math.clamp(__CPC.telemetry.steer, -1, 1)
    local steeringDegrees = steer * 900
    local angle = math.rad(steeringDegrees)
    local rim = math.abs(steer) > 0.02 and accent or __CPC.Theme.COLOR_MUTED
    local s = ctx.scale
    local detailScale = math.max(radius / 68, 1)
    local d = s * detailScale

    -- Instrument bezel and steering scale.
    ui.drawCircleFilled(center, r + 8 * d,
      rgbm(0.003, 0.004, 0.006, 0.12 * __CPC.settings.hudOpacity), 128)
    ui.drawCircle(center, r + 7 * d, __CPC.HUD.color(accent, 0.88), 128,
      math.max(1, 1.2 * d))
    ui.drawCircle(center, r + 5.5 * d, rgbm(0.72, 0.74, 0.78, 0.42), 128,
      math.max(1, 0.65 * d))
    ui.drawCircle(center, r + 3 * d, rgbm(0.030, 0.034, 0.041, 0.97), 128,
      math.max(1, 3 * d))
    for tick = 0, 47 do
      local a = tick / 48 * math.pi * 2 - math.pi / 2
      local longTick = tick % 4 == 0
      local inner = r + (longTick and 0 or 2) * d
      local outer = r + 5 * d
      local direction = vec2(math.cos(a), math.sin(a))
      ui.drawLine(center + direction * inner, center + direction * outer,
        longTick and __CPC.HUD.color(accent, 0.88) or rgbm(0.52, 0.54, 0.59, 0.72),
        math.max(1, (longTick and 1.5 or 0.8) * d))
    end

    -- Leather-look rim and three spokes rotate from the live wheel input.
    ui.drawCircle(center, r - 5 * d, rgbm(0.018, 0.021, 0.026, 1), 128,
      math.max(3, 12 * d))
    ui.drawCircle(center, r - 3.5 * d, rgbm(0.52, 0.55, 0.60, 0.34), 128,
      math.max(1, 0.8 * d))
    ui.drawCircle(center, r - 5 * d, rim, 128, math.max(1, 1.5 * d))
    ui.drawCircle(center, r - 11 * d, __CPC.HUD.color(accent, 0.30), 128,
      math.max(1, d))
    for _, offset in ipairs({ 0, math.pi * 2 / 3, -math.pi * 2 / 3 }) do
      local a = angle + math.pi / 2 + offset
      local direction = vec2(math.cos(a), math.sin(a))
      local edge = vec2(-direction.y, direction.x)
      ui.drawLine(center + direction * (10 * d),
        center + direction * (r - 11 * d), rgbm(0.52, 0.54, 0.58, 1),
        math.max(2, 9 * d))
      ui.drawLine(center + direction * (12 * d),
        center + direction * (r - 12 * d), rgbm(0.055, 0.060, 0.070, 1),
        math.max(1, 3 * d))
      ui.drawLine(center + direction * (14 * d) + edge * (3.2 * d),
        center + direction * (r - 14 * d) + edge * (3.2 * d),
        rgbm(0.82, 0.84, 0.88, 0.44), math.max(1, 0.7 * d))
    end
    local marker = center + vec2(math.cos(angle - math.pi / 2),
      math.sin(angle - math.pi / 2)) * (r - 5 * d)
    ui.drawCircleFilled(marker, math.max(2, 3.4 * d), accent, 16)
    ui.drawCircleFilled(center, 13 * d, rgbm(0.008, 0.009, 0.012, 0.98), 48)
    ui.drawCircle(center, 13 * d, rgbm(0.72, 0.74, 0.78, 1), 48,
      math.max(1, 2.2 * d))
    ui.drawCircle(center, 9.5 * d, rgbm(0.28, 0.30, 0.34, 1), 48,
      math.max(1, 0.8 * d))
    ui.drawCircle(center, 7 * d, rim, 32, math.max(1, 1.2 * d))
    for bolt = 0, 5 do
      local boltAngle = angle + bolt / 6 * math.pi * 2
      local boltPos = center + vec2(math.cos(boltAngle), math.sin(boltAngle)) * (10.7 * d)
      ui.drawCircleFilled(boltPos, 0.9 * d, rgbm(0.80, 0.82, 0.86, 1), 12)
      ui.drawCircle(boltPos, 0.9 * d, rgbm(0.04, 0.045, 0.055, 1), 12,
        math.max(1, 0.35 * d))
    end

    -- A compact digital readout sits inside the upper half of the wheel.
    local readoutX1, readoutX2 = x - radius * 0.48, x + radius * 0.48
    local readoutY1, readoutY2 = y - radius * 0.72, y - radius * 0.34
    local p1, p2 = __CPC.HUD.point(ctx, readoutX1, readoutY1),
      __CPC.HUD.point(ctx, readoutX2, readoutY2)
    ui.drawRectFilled(p1, p2, rgbm(0.004, 0.005, 0.007,
      0.92 * __CPC.settings.hudOpacity), 6 * d)
    ui.drawRect(p1, p2, __CPC.HUD.color(accent, 0.58), 6 * d, 0, math.max(1, d))
    __CPC.HUD.label(ctx, 'STEERING INPUT', readoutX1 + 3, readoutY1 + 1,
      readoutX2 - 3, readoutY1 + radius * 0.12, __CPC.Theme.COLOR_MUTED,
      math.min(18, 7 * detailScale),
      ui.Alignment.Center, true)
    __CPC.HUD.label(ctx, string.format('%+.0f°', steeringDegrees), readoutX1 + 3,
      readoutY1 + radius * 0.11, readoutX2 - 3, readoutY2 - 1, rim,
      math.min(36, 14 * detailScale),
      ui.Alignment.Center, true)
  end

  function __CPC.HUD.pedalPath(center, axisX, axisY, halfWidth, halfHeight, color, outline, thickness)
    ui.pathLineTo(center - axisX * halfWidth - axisY * halfHeight)
    ui.pathLineTo(center + axisX * halfWidth - axisY * halfHeight)
    ui.pathLineTo(center + axisX * (halfWidth + 2) + axisY * halfHeight)
    ui.pathLineTo(center - axisX * (halfWidth + 2) + axisY * halfHeight)
    if outline then ui.pathStroke(color, true, thickness or 1)
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
      ui.Alignment.Center, true)
    __CPC.HUD.label(ctx, string.format('%.0f', speed), speedX1, 132, speedX2, 213,
      __CPC.Theme.COLOR_TEXT, 42, ui.Alignment.Center, true)
    __CPC.HUD.label(ctx, speedUnit, speedX1, 210, speedX2, 237, __CPC.Theme.COLOR_MUTED, 12,
      ui.Alignment.Center, true)

    if not inputsOnly and __CPC.settings.hudShowCamera then
      __CPC.HUD.panel(ctx, 576, 106, 704, 249, accent, 0.90, 8)
      __CPC.HUD.label(ctx, 'CAMERA', 576, 111, 704, 132, __CPC.Theme.COLOR_MUTED, 10,
        ui.Alignment.Center, true)
      __CPC.HUD.label(ctx, string.format('FOV  %.1f°', __CPC.renderedFov), 584, 137, 696, 160,
        __CPC.Theme.COLOR_TEXT, 14, ui.Alignment.Start, true)
      __CPC.HUD.label(ctx, string.format('THR  %3.0f%%', __CPC.throttleEffectScale * 100),
        584, 163, 696, 184, accent, 12, ui.Alignment.Start)
      __CPC.HUD.label(ctx, string.format('NECK %3.0f%%', __CPC.neckTelemetry.effectStrength * 100),
        584, 187, 696, 208, __CPC.neckIsOnline() and __CPC.Theme.COLOR_ACTIVE or __CPC.Theme.COLOR_WARNING,
        12, ui.Alignment.Start)
      __CPC.HUD.label(ctx, __CPC.neckIsOnline() and '6DOF ONLINE' or '6DOF OFFLINE',
        584, 216, 696, 239, __CPC.neckIsOnline() and __CPC.Theme.COLOR_ACTIVE or __CPC.Theme.COLOR_WARNING,
        10, ui.Alignment.Center, true)
    end

    if __CPC.settings.hudShowCamera and not inputsOnly then
      __CPC.HUD.panel(ctx, 16, 263, 704, 340, accent, 0.76, 8)
      __CPC.HUD.label(ctx, 'THROTTLE CAMERA', 27, 271, 165, 289, accent, 10,
        ui.Alignment.Start, true)
      __CPC.HUD.label(ctx, string.format('XYZ  %+.1f / %+.1f / %+.1f mm',
        __CPC.outputLateral * 1000, __CPC.outputVertical * 1000, __CPC.outputForward * 1000),
        170, 269, 425, 291, __CPC.Theme.COLOR_TEXT, 11, ui.Alignment.Start)
      __CPC.HUD.label(ctx, string.format('P/Y  %+.2f / %+.2f°', __CPC.outputPitch, __CPC.outputYaw),
        430, 269, 690, 291, __CPC.Theme.COLOR_TEXT, 11, ui.Alignment.Start)
      __CPC.HUD.label(ctx, 'NECKFX 6DOF', 27, 307, 165, 327,
        __CPC.neckIsOnline() and __CPC.Theme.COLOR_ACTIVE or __CPC.Theme.COLOR_WARNING, 10,
        ui.Alignment.Start, true)
      __CPC.HUD.label(ctx, string.format('XYZ  %+.1f / %+.1f / %+.1f mm',
        __CPC.neckTelemetry.outputX * 1000, __CPC.neckTelemetry.outputY * 1000,
        __CPC.neckTelemetry.outputZ * 1000), 170, 305, 425, 329,
        __CPC.Theme.COLOR_TEXT, 11, ui.Alignment.Start)
      __CPC.HUD.label(ctx, string.format('Y/P/R  %+.2f / %+.2f / %+.2f°',
        __CPC.neckTelemetry.outputYaw, __CPC.neckTelemetry.outputPitch, __CPC.neckTelemetry.outputRoll),
        430, 305, 690, 329, __CPC.Theme.COLOR_TEXT, 11, ui.Alignment.Start)
    end

    if __CPC.settings.hudShowStatus then
      local statusY1 = inputsOnly and 270 or 351
      local statusY2 = inputsOnly and 326 or 389
      local color = __CPC.clutchStateColor()
      local alpha = 0.10 + __CPC.actionFlash * 0.17 * __CPC.settings.hudAnimation
      local p1, p2 = __CPC.HUD.point(ctx, 16, statusY1), __CPC.HUD.point(ctx, 704, statusY2)
      ui.drawRectFilled(p1, p2, __CPC.HUD.color(color, alpha), 7 * ctx.scale)
      ui.drawRect(p1, p2, color, 7 * ctx.scale, 0, math.max(1, ctx.scale))
      __CPC.HUD.label(ctx, __CPC.clutchStatus, 28, statusY1 + 2, 490, statusY2 - 2,
        color, 13, ui.Alignment.Start, true)
      local effectiveClutch = math.min(__CPC.telemetry.rawClutch, __CPC.clutchCommand)
      __CPC.HUD.label(ctx, string.format('CLUTCH  %.0f%% PRESSED', (1 - effectiveClutch) * 100),
        500, statusY1 + 2, 692, statusY2 - 2, accent, 11,
        ui.Alignment.Center, true)
    end
  end

  function __CPC.HUD.drawCircularBackground(ctx, accent)
    local center = __CPC.HUD.point(ctx, 360, 360)
    local s = ctx.scale
    local opacity = __CPC.settings.hudOpacity
    ui.setCursor(vec2(0, 0))
    ui.dummy(vec2(1, 1))

    -- Keep the centre and every pixel outside the bezel transparent.
    ui.drawCircleFilled(center, 350 * s,
      rgbm(0.003, 0.004, 0.006, 0.035 * opacity), 128)
    ui.drawCircle(center, 350 * s, __CPC.HUD.color(accent, 0.92), 96,
      math.max(1, 2 * s))
    ui.drawCircle(center, 347 * s, rgbm(0.60, 0.62, 0.66, 0.72), 128,
      math.max(1, 1.2 * s))
    ui.drawCircle(center, 343 * s, rgbm(0.035, 0.040, 0.048, 0.96), 128,
      math.max(2, 7 * s))
    ui.drawCircle(center, 338 * s, rgbm(0.55, 0.58, 0.63, 0.42), 128,
      math.max(1, s))
    ui.drawCircle(center, 332 * s, __CPC.HUD.color(accent, 0.34), 128,
      math.max(1, 1.5 * s))
    ui.drawCircle(center, 312 * s, rgbm(0.46, 0.48, 0.52, 0.28), 128,
      math.max(1, 0.8 * s))
  end

  function __CPC.HUD.drawCircularRPM(ctx, accent)
    if not __CPC.settings.hudShowRPM then return end
    local center = __CPC.HUD.point(ctx, 360, 360)
    local s = ctx.scale
    local fraction = __CPC.Math.saturate((__CPC.telemetry.rpm - __CPC.telemetry.idleRPM) /
      math.max(__CPC.telemetry.limiterRPM - __CPC.telemetry.idleRPM, 1))
    local rpmColor = fraction > 0.88 and __CPC.Theme.COLOR_WARNING
      or (fraction > 0.68 and __CPC.Theme.COLOR_ACTION or accent)
    local startAngle = math.rad(145)
    local sweep = math.rad(250)
    for tick = 0, 71 do
      local progress = tick / 71
      local angle = startAngle + sweep * progress
      local direction = vec2(math.cos(angle), math.sin(angle))
      local longTick = tick % 6 == 0
      local innerRadius = (longTick and 315 or 322) * s
      local outerRadius = 334 * s
      local active = progress <= fraction
      local color = active and rpmColor or rgbm(0.20, 0.22, 0.25, 0.62)
      if active then
        ui.drawLine(center + direction * (innerRadius - 2 * s),
          center + direction * (outerRadius + 2 * s), __CPC.HUD.color(rpmColor, 0.20),
          math.max(2, 6 * s))
      end
      ui.drawLine(center + direction * innerRadius,
        center + direction * outerRadius, color,
        math.max(1, (active and 2.2 or 1.0) * s))
    end
  end

  function __CPC.HUD.drawCircularValuePod(ctx, x, y, radius, accent, title,
      value, unit, valueColor)
    local center = __CPC.HUD.point(ctx, x, y)
    local s = ctx.scale
    ui.drawCircleFilled(center, radius * s,
      rgbm(0.006, 0.008, 0.011, 0.88 * __CPC.settings.hudOpacity), 64)
    ui.drawCircle(center, radius * s, __CPC.HUD.color(accent, 0.76), 64,
      math.max(1, 1.5 * s))
    ui.drawCircle(center, (radius - 3) * s, rgbm(0.72, 0.74, 0.78, 0.26), 64,
      math.max(1, 0.7 * s))
    ui.drawCircle(center, (radius - 7) * s, rgbm(0.18, 0.19, 0.22, 0.78), 64,
      math.max(1, s))
    ui.drawLine(__CPC.HUD.point(ctx, x - radius + 13, y - radius + 29),
      __CPC.HUD.point(ctx, x + radius - 13, y - radius + 29), __CPC.HUD.color(accent, 0.32),
      math.max(1, s))
    ui.drawCircleFilled(__CPC.HUD.point(ctx, x, y - radius + 5), 2.4 * s, accent, 16)
    __CPC.HUD.label(ctx, title, x - radius + 5, y - radius + 8,
      x + radius - 5, y - radius + 27, __CPC.Theme.COLOR_MUTED, 10,
      ui.Alignment.Center, true)
    __CPC.HUD.label(ctx, value, x - radius + 5, y - radius + 22,
      x + radius - 5, y + radius - 10, valueColor or __CPC.Theme.COLOR_TEXT, 28,
      ui.Alignment.Center, true)
    if unit then
      __CPC.HUD.label(ctx, unit, x - radius + 5, y + radius - 25,
        x + radius - 5, y + radius - 7, __CPC.Theme.COLOR_MUTED, 9,
        ui.Alignment.Center, true)
    end
  end

  function __CPC.HUD.drawShiftLights(ctx, x1, y1, x2, y2, segments, accent)
    if not __CPC.settings.hudShowShiftLights then return end
    segments = segments or 12
    local idle = __CPC.telemetry.idleRPM
    local launchHold = __CPC.launchControlArmed
    local ceiling = launchHold and math.max(__CPC.telemetry.launchRPM, idle + 200)
      or __CPC.telemetry.limiterRPM
    local fraction = __CPC.Math.saturate((__CPC.telemetry.rpm - idle) /
      math.max(ceiling - idle, 1))
    local lit = launchHold
      and __CPC.Math.saturate((fraction - 0.20) / 0.80)
      or __CPC.Math.saturate((fraction - 0.62) / 0.38)
    local activeCount = math.floor(lit * segments + 0.5)
    local atTarget = launchHold and (__CPC.launchControlReady or fraction >= 0.97)
      or fraction >= 0.985
    local flashOn = atTarget and (math.floor(__CPC.elapsedTime * 14) % 2 == 0)
    local gap = 2.4
    local segmentWidth = (x2 - x1 - gap * (segments - 1)) / segments
    for index = 0, segments - 1 do
      local segX1 = x1 + index * (segmentWidth + gap)
      local segX2 = segX1 + segmentWidth
      local segColor = index < segments * 0.5 and __CPC.Theme.COLOR_ACTIVE
        or (index < segments * 0.8 and __CPC.Theme.COLOR_ACTION or __CPC.Theme.COLOR_WARNING)
      local segmentLit = atTarget and flashOn or (not atTarget and index < activeCount)
      local p1, p2 = __CPC.HUD.point(ctx, segX1, y1), __CPC.HUD.point(ctx, segX2, y2)
      ui.drawRectFilled(p1, p2, segmentLit and __CPC.HUD.color(segColor, 0.92)
        or rgbm(0.045, 0.05, 0.06, 0.85 * __CPC.settings.hudOpacity), 2 * ctx.scale)
      ui.drawRect(p1, p2, segmentLit and segColor or rgbm(0.3, 0.32, 0.36, 0.5),
        2 * ctx.scale, 0, math.max(1, ctx.scale))
    end
  end

  function __CPC.HUD.drawGMeter(ctx, x, y, radius, accent)
    if not __CPC.settings.hudShowGMeter then return end
    local trace = __CPC.HUD.trace
    local center = __CPC.HUD.point(ctx, x, y)
    local s = ctx.scale
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
