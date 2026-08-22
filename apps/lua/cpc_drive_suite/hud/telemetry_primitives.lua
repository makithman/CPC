return [====[
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
]====]
