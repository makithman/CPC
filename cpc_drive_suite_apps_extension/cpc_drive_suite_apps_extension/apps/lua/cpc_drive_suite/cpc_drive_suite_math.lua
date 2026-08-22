-- CPC Drive Suite — shared numeric helpers
local M = {}

function M.finiteNumber(value, fallback)
  if type(value) ~= 'number'
      or value ~= value
      or value == math.huge
      or value == -math.huge then
    return fallback or 0
  end
  return value
end

function M.clamp(value, minimum, maximum)
  minimum = M.finiteNumber(minimum, 0)
  maximum = M.finiteNumber(maximum, minimum)
  if maximum < minimum then minimum, maximum = maximum, minimum end
  return math.max(minimum, math.min(M.finiteNumber(value, minimum), maximum))
end

function M.saturate(value)
  return M.clamp(value, 0, 1)
end

function M.moveTowards(current, target, maximumDelta)
  if current < target then return math.min(current + maximumDelta, target) end
  return math.max(current - maximumDelta, target)
end

function M.expSmooth(current, target, speed, dt)
  current = M.finiteNumber(current, 0)
  target = M.finiteNumber(target, current)
  speed = math.max(M.finiteNumber(speed, 0.01), 0.01)
  dt = math.max(M.finiteNumber(dt, 0), 0)
  local alpha = 1 - math.exp(-speed * dt)
  return current + (target - current) * alpha
end

function M.signWithDeadzone(value, deadzone)
  if value > deadzone then return 1 end
  if value < -deadzone then return -1 end
  return 0
end

return M
