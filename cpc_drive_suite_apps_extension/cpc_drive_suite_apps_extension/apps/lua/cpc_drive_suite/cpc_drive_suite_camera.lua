-- CPC Drive Suite 3.9.2 — Camera compatibility shim
-- Throttle/camera logic now lives in cpc_drive_suite_throttle.lua.

return function(__CPC)
  local initializer = require('cpc_drive_suite_throttle')
  if type(initializer) ~= 'function' then
    error('cpc_drive_suite_throttle did not return an initializer function')
  end
  return initializer(__CPC)
end
