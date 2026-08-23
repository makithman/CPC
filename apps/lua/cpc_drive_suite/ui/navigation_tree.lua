return [====[
    ui.drawCircle(center, 5 * wheelScale, wheelColor, 20, wheelScale)
    ui.setCursor(center - vec2(19, 19) * wheelScale)
    ui.pushStyleColor(ui.StyleColor.Button, rgbm(0, 0, 0, 0))
    ui.pushStyleColor(ui.StyleColor.ButtonHovered, rgbm(1, 1, 1, 0.12))
    ui.pushStyleColor(ui.StyleColor.ButtonActive, rgbm(1, 1, 1, 0.22))
    if ui.button('##wheelHome', vec2(38, 38) * wheelScale) then
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

    local nodeRadius = math.min(36, math.max(28, radius / wheelScale * 0.30)) * wheelScale
    for index, page in ipairs(pages) do
      local angle = (index - 1) / #pages * math.pi * 2 - math.pi / 2
      local direction = vec2(math.cos(angle), math.sin(angle))
      local node = center + direction * radius
      local selected = activePage == page[1]
      if selected then selectedNode = node end
      local nodeColor = selected and accent or __CPC.Theme.COLOR_MUTED
      local nodeAlpha = selected and (0.36 + __CPC.uiPulse(2.5, 0.45) * 0.28) or 0.16

      ui.drawLine(center + direction * (33 * wheelScale), node - direction * (18 * wheelScale),
        rgbm(nodeColor.r, nodeColor.g, nodeColor.b, selected and 0.78 or 0.28),
        (selected and 2 or 1) * wheelScale)
      ui.drawCircleFilled(node, nodeRadius, rgbm(nodeColor.r, nodeColor.g, nodeColor.b, nodeAlpha), 32)
      ui.drawCircle(node, nodeRadius, rgbm(nodeColor.r, nodeColor.g, nodeColor.b, selected and 0.95 or 0.55), 32,
        selected and 2 or 1)

      ui.setCursor(vec2(node.x - nodeRadius, node.y - 12 * wheelScale))
      ui.pushStyleColor(ui.StyleColor.Button, rgbm(0, 0, 0, 0))
      ui.pushStyleColor(ui.StyleColor.ButtonHovered, rgbm(1, 1, 1, 0.10))
      ui.pushStyleColor(ui.StyleColor.ButtonActive, rgbm(1, 1, 1, 0.20))
      if ui.button('##wheel:' .. page[1], vec2(nodeRadius * 2, 24 * wheelScale)) then
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
      ui.dwriteDrawTextClipped(page[2], 7 * wheelScale,
        vec2(node.x - nodeRadius, node.y - 12 * wheelScale),
        vec2(node.x + nodeRadius, node.y + 12 * wheelScale), ui.Alignment.Center, ui.Alignment.Center,
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

  function __CPC.drawSettingsTreeSubmenu(sidebarWidth, mainPage, mainNode, centerOverride)
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

    local center = centerOverride or vec2(sidebarWidth * 0.5, 460)
    local wheelScale = __CPC.Math.clamp(__CPC.settings.uiWheelScale or 1, 0.75, 1.25)
      * (__CPC.settings.uiLowResolution and 0.82 or 1)
    local radius = math.min(94, math.max(58, sidebarWidth * 0.16)) * wheelScale
    local accent = __CPC.accentColor()
    local selected = tree.key and __CPC.settings[tree.key]
      or (tree.title == 'HELP OPTIONS' and (__CPC.wheelHelpView or 1) or 1)
    local pulse = 0.22 + __CPC.uiPulse(2.8, 0.30) * 0.18

    ui.drawCircleFilled(center, radius + 19 * wheelScale, rgbm(0.006, 0.008, 0.012, 0.94), 64)
    ui.drawCircle(center, radius + 18 * wheelScale, rgbm(accent.r, accent.g, accent.b, pulse), 64, 1.5 * wheelScale)
    ui.drawCircleFilled(center, 22 * wheelScale, rgbm(0.012, 0.015, 0.021, 1), 32)
    ui.drawCircle(center, 22 * wheelScale, rgbm(accent.r, accent.g, accent.b, 0.68), 32, wheelScale)
    local wheelColor = __CPC.accentColor(0.96)
    ui.drawCircle(center, 13 * wheelScale, wheelColor, 28, 3.2 * wheelScale)
    ui.drawCircle(center, 10 * wheelScale, rgbm(wheelColor.r, wheelColor.g, wheelColor.b, 0.52), 28, wheelScale)
    for _, spokeAngle in ipairs({ -math.pi / 2, math.pi / 6, math.pi * 5 / 6 }) do
      local direction = vec2(math.cos(spokeAngle), math.sin(spokeAngle))
      ui.drawLine(center + direction * (3 * wheelScale), center + direction * (10 * wheelScale),
        wheelColor, 2 * wheelScale)
    end
    ui.drawCircleFilled(center, 4 * wheelScale, rgbm(0.055, 0.060, 0.070, 1), 16)
    ui.drawCircle(center, 4 * wheelScale, wheelColor, 16, wheelScale)
    for index, themeColor in ipairs(__CPC.Theme.THEME_ACCENTS) do
      local swatchAngle = (index - 1) / #__CPC.Theme.THEME_ACCENTS * math.pi * 2 - math.pi / 2
      local swatch = center + vec2(math.cos(swatchAngle), math.sin(swatchAngle)) * (17 * wheelScale)
      ui.drawCircleFilled(swatch, 3.2 * wheelScale, themeColor, 12)
      ui.drawCircle(swatch, 3.2 * wheelScale, rgbm(0.94, 0.96, 1.0, 0.82), 12, 0.7 * wheelScale)
      ui.setCursor(swatch - vec2(5, 5) * wheelScale)
      ui.pushStyleColor(ui.StyleColor.Button, rgbm(0, 0, 0, 0))
      ui.pushStyleColor(ui.StyleColor.ButtonHovered, rgbm(1, 1, 1, 0.16))
      ui.pushStyleColor(ui.StyleColor.ButtonActive, rgbm(1, 1, 1, 0.26))
      if ui.button('##subwheelTheme:' .. index, vec2(10, 10) * wheelScale) then
        __CPC.settings.colorTheme = index
      end
      if ui.itemHovered() then ui.setTooltip(__CPC.Theme.THEME_NAMES[index]) end
      ui.popStyleColor(3)
    end

    if mainNode then
      local delta = center - mainNode
      local distance = math.max(1, math.sqrt(delta.x * delta.x + delta.y * delta.y))
      local direction = delta * (1 / distance)
      local startPoint = mainNode + direction * (29 * wheelScale)
      local endPoint = center - direction * (radius + 19 * wheelScale)
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
]====]
