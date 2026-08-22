-- CPC Drive Suite 3.9.2 — Safe Loader
-- Tiny wrapper: guarantees a visible window even if the full core fails.

local coreLoaded = false
local coreLoadError = nil
local coreUpdate = nil
local coreWindowMain = nil
local coreWindowMainSettings = nil
local coreWindowHUD = nil
local coreRecover = nil

local ok, err = pcall(require, 'cpc_drive_suite_core')
if ok then
  coreLoaded = true
  coreUpdate = script.update
  coreWindowMain = script.windowMain
  coreWindowMainSettings = script.windowMainSettings or script.windowMain
  coreWindowHUD = script.windowHUD
  coreRecover = script.recover
else
  coreLoadError = tostring(err)
end

function script.update(dt)
  if not coreLoaded or coreUpdate == nil then return end
  local runOk, runErr = pcall(coreUpdate, dt)
  if not runOk then
    if coreRecover ~= nil then pcall(coreRecover) end
    coreLoaded = false
    coreLoadError = 'UPDATE ERROR:\n' .. tostring(runErr)
  end
end

local function header()
  ui.text('CPC DRIVE SUITE 3.10.0')
  ui.separator()
end

local function errorView(title, message)
  header()
  ui.text(title)
  ui.separator()
  ui.textWrapped(tostring(message or 'Unknown error'))
  ui.separator()
  ui.textWrapped('Safe loader is active. The error above is what prevented the full CPC interface from loading.')
end

function script.windowMain(dt)
  if not coreLoaded then
    errorView('CORE LOAD ERROR', coreLoadError)
    return
  end

  if coreWindowMain == nil then
    errorView('CORE UI ERROR', 'Core loaded but did not create script.windowMain.')
    return
  end

  local drawOk, drawErr = pcall(coreWindowMain, dt)
  if not drawOk then
    errorView('FULL SETTINGS UI ERROR', drawErr)
  end
end

function script.windowMainSettings(dt)
  if not coreLoaded then
    errorView('CORE LOAD ERROR', coreLoadError)
    return
  end

  local fn = coreWindowMainSettings or coreWindowMain
  if fn == nil then
    errorView('CORE SETTINGS ERROR', 'Core loaded but did not create a settings callback.')
    return
  end

  local drawOk, drawErr = pcall(fn, dt)
  if not drawOk then
    errorView('SETTINGS UI ERROR', drawErr)
  end
end

function script.windowSettings(dt)
  script.windowMainSettings(dt)
end

function script.windowHUD(dt)
  if not coreLoaded then
    ui.text('CPC core load error')
    return
  end
  if coreWindowHUD == nil then
    ui.text('CPC HUD unavailable')
    return
  end
  local drawOk, drawErr = pcall(coreWindowHUD, dt)
  if not drawOk then
    ui.text('CPC HUD error')
    ui.textWrapped(tostring(drawErr))
  end
end
