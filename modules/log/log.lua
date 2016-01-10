local core = require "jester.core"

local _M = {}

--[[
  Log to the console.
]]
function _M.log_console(action)
  local message = action.message
  local level = action.level or "info"
  if message then
    core.log(message, "JESTER LOG", level)
  end
end

--[[
  Log to a file on the local filesystem.
]]
function _M.log_file(action)
  local message = action.message
  local file = action.file or '/tmp/jester.log'
  local level = action.level or "INFO"
  if message then
    -- Try to open the log file in append mode.
    local destination, file_error = io.open(file, "a")
    if destination then
      message = os.date("%Y-%m-%d %H:%M:%S") .. " " .. level .. ": " .. message .. "\n"
      destination:write(message)
      destination:close()
    else
      core.debug_log("Failed writing to log file '%s'!: %s", file, file_error)
    end
  end
end

return _M
