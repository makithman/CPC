-- CPC Drive Suite settings JSON import/export.

return function(__CPC)
  local folderPath = ac.getFolder(ac.FolderID.Root) .. '/apps/lua/cpc_drive_suite'
  local filePath = folderPath .. '/CPC_DRIVE_SUITE_SETTINGS.JSON'
  local defaultsFilePath = folderPath .. '/CPC_DRIVE_SUITE_DEFAULTS.JSON'
  __CPC.settingsFolderPath = folderPath
  __CPC.settingsFilePath = 'cpc_drive_suite/CPC_DRIVE_SUITE_SETTINGS.JSON'
  __CPC.defaultsFilePath = 'cpc_drive_suite/CPC_DRIVE_SUITE_DEFAULTS.JSON'
  __CPC.settingsFileStatus = ''
  __CPC.settingsFilePreview = nil

  local function fileUrl(path)
    return 'file:///' .. path:gsub('\\', '/')
  end

  local function escape(value)
    return value:gsub('\\', '\\\\'):gsub('"', '\\"'):gsub('\n', '\\n')
  end

  local function encode(settings)
    local keys = {}
    for key, defaultValue in pairs(__CPC.DEFAULTS) do
      if type(defaultValue) == 'number' or type(defaultValue) == 'boolean'
          or type(defaultValue) == 'string' then
        keys[#keys + 1] = key
      end
    end
    table.sort(keys)
    local output = { '{\n' }
    for index, key in ipairs(keys) do
      local value = settings[key]
      local encoded
      if type(value) == 'string' then
        encoded = '"' .. escape(value) .. '"'
      elseif type(value) == 'boolean' then
        encoded = value and 'true' or 'false'
      else
        encoded = string.format('%.17g', tonumber(value) or 0)
      end
      output[#output + 1] = string.format('  "%s": %s%s\n', key, encoded,
        index == #keys and '' or ',')
    end
    output[#output + 1] = '}'
    return table.concat(output)
  end

  local function decodeValue(raw)
    raw = raw:match('^%s*(.-)%s*$')
    if raw == 'true' then return true end
    if raw == 'false' then return false end
    if raw:sub(1, 1) == '"' and raw:sub(-1) == '"' then
      return raw:sub(2, -2):gsub('\\n', '\n'):gsub('\\"', '"'):gsub('\\\\', '\\')
    end
    return tonumber(raw)
  end

  local function decode(text)
    if not text:match('^%s*{%s*.-%s*}%s*$') then return nil end
    local values = {}
    for key, raw in text:gmatch('"([%w_]+)"%s*:%s*([^,}]+)') do
      values[key] = decodeValue(raw)
    end
    return values
  end

  local function compatible(value, defaultValue)
    return type(value) == type(defaultValue) and (type(value) ~= 'number' or value == value)
  end

  local function openForWrite()
    local file, err = io.open(filePath, 'w')
    if file then return file, filePath, nil end
    return nil, nil, 'Cannot write project settings file: ' .. tostring(err)
  end

  local function openForRead(path)
    local readPath = path or filePath
    local file, err = io.open(readPath, 'r')
    if file then return file, readPath, nil end
    return nil, nil, 'Cannot read project settings file: ' .. tostring(err)
  end

  local function readSettingsValues(path)
    local file, activePath, err = openForRead(path)
    if not file then return nil, nil, err end
    local text = file:read('*a')
    file:close()
    local values = decode(text)
    if not values then return nil, activePath, 'invalid JSON object.' end
    return values, activePath, nil
  end

  local function applyValuesAsDefaults(values)
    local imported = 0
    for key, value in pairs(values) do
      if __CPC.DEFAULTS[key] ~= nil and compatible(value, __CPC.DEFAULTS[key]) then
        __CPC.DEFAULTS[key] = value
        __CPC.settings[key] = value
        imported = imported + 1
      end
    end
    return imported
  end

  function __CPC.exportSettingsJson()
    local file, activePath, err = openForWrite()
    if not file then
      __CPC.settingsFileStatus = 'Export failed: ' .. tostring(err)
      return false
    end
    file:write(encode(__CPC.settings))
    file:close()
    __CPC.settingsFileStatus = 'Exported settings JSON: ' .. activePath
    return true
  end

  function __CPC.importSettingsJson()
    local values, activePath, err = readSettingsValues()
    if not values then
      __CPC.settingsFileStatus = 'Import failed: ' .. tostring(err)
      return false
    end
    local imported = 0
    for key, value in pairs(values) do
      if __CPC.DEFAULTS[key] ~= nil and compatible(value, __CPC.DEFAULTS[key]) then
        __CPC.settings[key] = value
        imported = imported + 1
      end
    end
    __CPC.settingsFileStatus = string.format('Imported %d settings from %s.', imported, activePath)
    return true
  end

  function __CPC.loadJsonAsDefaults()
    local values, activePath, err = readSettingsValues(defaultsFilePath)
    if not values then
      __CPC.settingsFileStatus = 'Default load failed: ' .. tostring(err)
      return false
    end
    local imported = applyValuesAsDefaults(values)
    __CPC.settingsFileStatus = string.format(
      'Loaded %d JSON values as defaults from %s.', imported, activePath)
    return true
  end

  function __CPC.openSettingsFolder()
    ac.openURL(fileUrl(folderPath))
    __CPC.settingsFileStatus = 'Opened the settings folder.'
  end

  function __CPC.toggleSettingsPreview()
    if __CPC.settingsFilePreview ~= nil then
      __CPC.settingsFilePreview = nil
      return
    end
    local file, activePath, err = openForRead()
    if not file then
      __CPC.settingsFileStatus = 'View failed: ' .. tostring(err)
      return
    end
    __CPC.settingsFilePreview = file:read('*a')
    file:close()
  end

  -- Apply shipped defaults first, then restore the separate user save state.
  local startupDefaults = readSettingsValues(defaultsFilePath)
  if startupDefaults then applyValuesAsDefaults(startupDefaults) end
  local savedValues = readSettingsValues(filePath)
  if savedValues then
    for key, value in pairs(savedValues) do
      if __CPC.DEFAULTS[key] ~= nil and compatible(value, __CPC.DEFAULTS[key]) then
        __CPC.settings[key] = value
      end
    end
  end
end
