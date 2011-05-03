--[[
  Support functions for files.
]]

--[[
  Returns file size.
]]
function filesize (file)
  local current = file:seek()
  local size = file:seek("end")
  file:seek("set", current)
  return size
end
