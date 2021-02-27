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