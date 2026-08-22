-- Loads generated source fragments as one Lua chunk.
-- Fragmenting source keeps every Lua file below the 200-line project limit
-- without changing closures or behavior from the known-good CPC modules.

local M = {}

function M.load(moduleName, fragmentNames)
  local fragments = {}
  for index, fragmentName in ipairs(fragmentNames) do
    local fragment = require(fragmentName)
    if type(fragment) ~= 'string' then
      error(string.format('%s fragment %d did not return source text', moduleName, index))
    end
    fragments[index] = fragment
  end

  local compiler = loadstring or load
  if not compiler then
    error('This CSP Lua runtime cannot compile CPC source fragments')
  end

  local chunk, compileError = compiler(table.concat(fragments, '\n'), '@' .. moduleName .. '.lua')
  if not chunk then
    error('Failed to compile ' .. moduleName .. ': ' .. tostring(compileError))
  end

  return chunk()
end

return M
