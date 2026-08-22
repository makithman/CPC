return [====[
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
]====]
