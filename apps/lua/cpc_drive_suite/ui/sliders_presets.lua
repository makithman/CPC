return [====[
    ui.textDisabled('QUICK X / Y POSITION')
    ui.dummy(vec2(size + gap, size))
    ui.sameLine(0, gap)
    __CPC.poseNudgeButton('^', 'up', 'throttleStartY', 0.01, -0.30, 0.30, 'Move camera up 10 mm.')

    __CPC.poseNudgeButton('<', 'left', 'throttleStartX', -0.01, -0.30, 0.30, 'Move camera left 10 mm.')
    ui.sameLine(0, gap)
    ui.dummy(vec2(size, size))
    ui.sameLine(0, gap)
    __CPC.poseNudgeButton('>', 'right', 'throttleStartX', 0.01, -0.30, 0.30, 'Move camera right 10 mm.')

    ui.dummy(vec2(size + gap, size))
    ui.sameLine(0, gap)
    __CPC.poseNudgeButton('v', 'down', 'throttleStartY', -0.01, -0.30, 0.30, 'Move camera down 10 mm.')
  end

  function __CPC.slider(label, key, minimum, maximum, format, tooltip)
    __CPC.drawCenteredSliderLabel(label, key)
    __CPC.pushSliderStyle()
    __CPC.beginCenteredSlider()
    local value = ui.slider('##sld:' .. key, __CPC.settings[key],
      minimum, maximum, format)
    __CPC.endCenteredSlider()
    __CPC.popSliderStyle()
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
    __CPC.drawCenteredSliderLabel(label, key)
    local current = (__CPC.settings[key] or 0) * 100
    __CPC.pushSliderStyle()
    __CPC.beginCenteredSlider()
    local value = ui.slider('##sld:' .. key,
      current, minimum * 100, maximum * 100, '%.0f%%')
    __CPC.endCenteredSlider()
    __CPC.popSliderStyle()
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

]====]
