return [====[
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
    return __CPC.accentColor(alpha)
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

  function __CPC.pushSliderStyle()
    local sliderColor = __CPC.accentColor()
    ui.pushStyleColor(ui.StyleColor.FrameBg,
      rgbm(sliderColor.r, sliderColor.g, sliderColor.b, 0.22))
    ui.pushStyleColor(ui.StyleColor.FrameBgHovered,
      rgbm(sliderColor.r, sliderColor.g, sliderColor.b, 0.36))
    ui.pushStyleColor(ui.StyleColor.FrameBgActive,
      rgbm(sliderColor.r, sliderColor.g, sliderColor.b, 0.48))
    ui.pushStyleColor(ui.StyleColor.SliderGrab,
      rgbm(sliderColor.r, sliderColor.g, sliderColor.b, 0.96))
    ui.pushStyleColor(ui.StyleColor.SliderGrabActive,
      rgbm(sliderColor.r, sliderColor.g, sliderColor.b, 1.00))
    ui.pushStyleVar(ui.StyleVar.FramePadding, vec2(0, 2))
    ui.pushStyleVar(ui.StyleVar.FrameRounding, 12)
    ui.pushStyleVar(ui.StyleVar.GrabRounding, 12)
    ui.pushStyleVar(ui.StyleVar.GrabMinSize, 14)
  end

  function __CPC.popSliderStyle()
    ui.popStyleVar(4)
    ui.popStyleColor(5)
  end

  function __CPC.beginCenteredSlider()
    local available = ui.availableSpaceX()
    local width = math.min(360, math.max(180, available * 0.78))
    local cursor = ui.getCursor()
    ui.setCursor(vec2(cursor.x + math.max(0, (available - width) * 0.5), cursor.y))
    ui.pushItemWidth(width)
  end

  function __CPC.endCenteredSlider()
    ui.popItemWidth()
  end

  function __CPC.drawCenteredSliderLabel(label, key)
    local marker, color = __CPC.settingIndicator(key)
    if marker == '[*]' then
      color = rgbm(color.r, color.g, color.b, __CPC.uiPulse(4.2, 0.55))
    end
    local available = ui.availableSpaceX()
    local width = math.min(360, math.max(180, available * 0.78))
    local cursor = ui.getCursor()
    local labelScale = __CPC.Math.clamp(__CPC.settings.uiSliderLabelScale or 1, 0.75, 1.50)
    local labelHeight = 18 * labelScale
    local sliderX = cursor.x + math.max(0, (available - width) * 0.5)
    ui.drawText(marker, vec2(sliderX, cursor.y + 2 + (labelHeight - 18) * 0.5), color)
    ui.pushDWriteFont('@System;Weight=Bold;Stretch=Condensed')
    ui.dwriteDrawTextClipped(label, 11 * labelScale, cursor,
      vec2(cursor.x + available, cursor.y + labelHeight),
      ui.Alignment.Center, ui.Alignment.Center, false, __CPC.Theme.COLOR_TEXT)
    ui.popDWriteFont()
    ui.dummy(vec2(available, labelHeight))
  end

  function __CPC.poseNudgeButton(label, id, key, offset, minimum, maximum, tooltip)
    local accent = __CPC.accentColor()
    ui.pushStyleColor(ui.StyleColor.Button, rgbm(accent.r, accent.g, accent.b, 0.16))
    ui.pushStyleColor(ui.StyleColor.ButtonHovered, rgbm(accent.r, accent.g, accent.b, 0.38))
    ui.pushStyleColor(ui.StyleColor.ButtonActive, rgbm(accent.r, accent.g, accent.b, 0.62))
    if ui.button(label .. '##poseNudge:' .. id, vec2(30, 30)) then
      __CPC.settings[key] = __CPC.Math.clamp((__CPC.settings[key] or 0) + offset, minimum, maximum)
    end
    if ui.itemHovered() then ui.setTooltip(tooltip) end
    ui.popStyleColor(3)
  end

  function __CPC.drawCameraPoseNudgePad()
    local size, gap = 30, 4
]====]
