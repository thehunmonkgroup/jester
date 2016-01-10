module(..., package.seeall)

--[[
  Executes an operating system shell command and stores the return value.
]]
function shell_command(action)
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
    jester.debug_log("Executed command: %s, return code: %s", command, ret)
    jester.set_storage(area, "return_code", tonumber(ret))
  end
end

--[[
  Executes an operating system shell command and stores the output and return
  value.
  Due to limitations in Lua 5.1, this action has a slightly hackish
  implementation -- it's not portable, doubtful it will work on Windows,
  mileage may vary.
]]
function shell_command_with_output(action)
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
    jester.debug_log("Executed command: %s, output: %s, return code: %s", command, output, ret)
    jester.set_storage(area, "output", output)
    jester.set_storage(area, "return_code", tonumber(ret))
  end
end

