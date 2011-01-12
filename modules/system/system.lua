module(..., package.seeall)

--[[
  Executes an operating system shell command.
]]
function shell_command(action)
  local command = action.command
  if command then
    os.execute(command)
  end
end

