-- CPC Drive Suite 3.9.2 — Modular Core
-- The former ~3,800-line core is split by responsibility.
-- One shared table avoids Lua chunk-local limits while each module owns its logic.

local __CPC = {}

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

-- Expose state only for diagnostics. Runtime modules communicate through this table.
script.cpcRuntime = __CPC
