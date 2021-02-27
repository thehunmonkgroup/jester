--- Custom logger for sequences.
--
-- This module provides custom logging functionality for sequences. It can be
-- used to log data somewhere from within a sequence.
--
-- @module log
-- @author Chad Phillips
-- @copyright 2011-2015 Chad Phillips


--- The console handler (default).
--
--  Logs to the FreeSWITCH console.
--
--  When using this handler, the 'level' argument for the action can be any
--  valid level used by
--  [freeswitch.consoleLog](https://freeswitch.org/confluence/display/FREESWITCH/Lua+API+Reference#LuaAPIReference-freeswitch.consoleLog)
--
-- @handler console
-- @usage
--   {
--     action = "log",
--     handler = "console",
--     level = "info",
--     -- other params...
--   }


--- The file handler.
--
--  Logs to a file on the local filesystem.
--
--  When using this handler, the 'level' argument for the action can be any
--  arbitrary value the user decides.
--
-- @handler file
-- @usage
--   {
--     action = "log",
--     handler = "file",
--     level = "WARN",
--     -- other params...
--   }


--- Log a custom message.
--
-- Allows logging a message from within a sequence, with a custom level.
--
-- @action log
-- @string action
--   log
-- @string file
--   (Optional) Required only for handlers that log to a file. Provide a full
--   path to the file. Default is '/tmp/jester.log'.
-- @string level
--   (Optional) The log level of the message. This value will vary depending on
--   the handler, see [handlers](#Handlers). Default is 'info'.
-- @string message
--   The message to log.
-- @string handler
--   The handler to use, see [handlers](#Handlers). If not specified, defaults
--   to the default handler for the module.
-- @usage
--   {
--     action = "log",
--     file = "/tmp/jester.log",
--     level = "info",
--     message = "A custom log message",
--     handler = "file",
--   }


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
      core.log.debug("Failed writing to log file '%s'!: %s", file, file_error)
    end
  end
end

return _M
