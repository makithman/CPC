-- CPC Drive Suite 3.10.0 -- size-bounded modular core.
-- Runtime behavior is sourced from the known-good CPC installation.

local __CPC = {}

local source = debug.getinfo(1, 'S').source or ''
local thisDir = source:match('^@(.+[\\/])')
if thisDir then
  package.path = thisDir .. '?.lua;' .. thisDir .. '?/init.lua;' .. package.path
end

local MODULES = {
  'cpc_drive_suite_neck',
  'cpc_drive_suite_settings_file',
  'cpc_drive_suite_clutch',
  'cpc_drive_suite_throttle',
  'cpc_drive_suite_autogear',
  'cpc_drive_suite_actions',
  'cpc_drive_suite_lifecycle',
  'cpc_drive_suite_ui',
  'cpc_drive_suite_hud'
}

for _, moduleName in ipairs(MODULES) do
  local initializer = require(moduleName)
  if type(initializer) ~= 'function' then
    error('CPC module "' .. moduleName .. '" did not return an initializer function')
  end
  initializer(__CPC)
end

script.cpcRuntime = __CPC
