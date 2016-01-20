--- Access to operating system commands.
--
-- This module provides access to various commands available at the operating
-- system level.
--
-- @module system
-- @author Chad Phillips
-- @copyright 2011-2015 Chad Phillips


--- Execute a shell command.
--
-- This action executes a system shell command, storing the return code in the
-- 'return\_code' key of the specificed storage area. The environment the shell
-- command runs in is the same environment FreeSWITCH provides to Lua.
--
-- This action is preferred over the @{shell_command_with_output} action if
-- the output of the command is not needed.
--
-- @action shell_command
-- @string action
--   shell_command
-- @string command
--   The shell command to run. Arguments can be provided if needed.
-- @string storage_area
--   The storage area to store the return code. Default is 'system'.
-- @usage
--   {
--     action = "shell_command",
--     command = "service foo start",
--     storage_area = "service_return_code",
--   }


--- Execute a shell command, saving the output.
--
-- This action executes a system shell command, storing the return code in the
-- 'return\_code' key, and the command output in the 'output' key of the
-- specificed storage area. The environment the shell command runs in is the
-- same environment FreeSWITCH provides to Lua.
--
-- If the command output is not needed, the @{shell_command} action is
-- preferred.
--
-- NOTE: Due to limitations in Lua 5.x, this action has a slightly hackish
-- implementation -- it's not portable, doubtful it will work on Windows,
-- mileage may vary.
--
-- @action shell_command_with_output
-- @string action
--   shell\_command\_with\_output
-- @string command
--   The shell command to run. Arguments can be provided if needed.
-- @string storage_area
--   The storage area to store the return code and output. Default is 'system'.
-- @usage
--   {
--     action = "shell_command_with_output",
--     command = "ls -1 /tmp/*.wav",
--     storage_area = "ls_return",
--   }


local core = require "jester.core"

local _M = {}

--[[
  Executes an operating system shell command and stores the return value.
]]
function _M.shell_command(action)
  local command = action.command
  local area = action.storage_area or "system"
  if command then
    local ret
    local val1, val2, val3 = os.execute(command)
    -- Return signature of os.execute changed in 5.2.
    if _VERSION == "Lua 5.1" then
      ret = val1
    else
      ret = val3
    end
    core.debug_log("Executed command: %s, return code: %s", command, ret)
    core.set_storage(area, "return_code", tonumber(ret))
  end
end

--[[
  Executes an operating system shell command and stores the output and return
  value.
]]
function _M.shell_command_with_output(action)
  local command = action.command
  local area = action.storage_area or "system"
  if command then
    local file = io.popen(command .. ' 2>&1; echo "-retcode:$?"', 'r')
    local full_output = file:read('*a')
    file:close()
    local i1, i2, output, newline, ret = full_output:find('(.*)(.)-retcode:(%d+)\n$')
    if ret then
      -- We're expecting the last character of the shell output to be a newline,
      -- which we want to trim, but if it's not, then stick it back on.
      if newline ~= "\n" then
        output = output .. newline
      end
    else
      output = "Unable to parse command output"
      ret = 1
    end
    core.debug_log("Executed command: %s, output: %s, return code: %s", command, output, ret)
    core.set_storage(area, "output", output)
    core.set_storage(area, "return_code", tonumber(ret))
  end
end

return _M
