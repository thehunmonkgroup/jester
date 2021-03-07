--[[
  Support functions for files.
]]

local io = require("io")

--[[
  Returns file size.
]]
function filesize(file)
  local current = file:seek()
  local size = file:seek("end")
  file:seek("set", current)
  return size
end

function filepath_elements(filepath)
  return string.match(filepath, "(.-)([^\\/]-%.?([^%.\\/]*))$")
end

--[[
  Checks for the existence of a file.
]]
function file_exists(n)
  local f = io.open(n)
  if f == nil then
    return false
  else
    io.close(f)
    return true
  end
end

function load_file(filepath)
  local file, err = io.open(filepath, "rb")
  local data
  if file then
    data = {
      filesize = filesize(file),
    }
  else
    data = err
  end
  return file, data
end

--[[
  Write file.
]]
function write_file(filepath, data, mode)
  mode = mode and mode or "w"
  local file
  local success, err = false, nil
  file, err = io.open(filepath, mode)
  if file then
    success, err = file:write(data)
    if success then
      success = true
    end
    file:close()
  end
  return success, err
end

--[[
  Removes file.
]]
function remove_file(filepath)
  local ok, err = os.remove(filepath)
  if ok then
    debug_print(string.format("Removed filepath: %s", filepath))
  else
    error_print(string.format("ERROR: could not remove filepath %s: %s", filepath, err))
  end
end
