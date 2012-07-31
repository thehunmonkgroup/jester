jester.help_map.system = {}
jester.help_map.system.description_short = [[Access to operating system commands.]]
jester.help_map.system.description_long = [[This module provides access to various commands available at the operating system level.]]

jester.help_map.system.actions = {}

jester.help_map.system.actions.shell_command = {}
jester.help_map.system.actions.shell_command.description_short = [[Execute a shell command.]]
jester.help_map.system.actions.shell_command.description_long = [[This action executes a system shell command, storing the return code in the 'return_code' key of the specificed storage area.  The environment the shell command runs in is the same environment FreeSWITCH provides to Lua.

This action is preferred over the 'shell_command_with_output' action if the output of the command is not needed.]]
jester.help_map.system.actions.shell_command.params = {
  command = [[The shell command to run.  Arguments can be provided if needed.]],
  storage_area = [[The storage area to store the return code. Default is 'system'.]],
}

jester.help_map.system.actions.shell_command_with_output = {}
jester.help_map.system.actions.shell_command_with_output.description_short = [[Execute a shell command saving the output.]]
jester.help_map.system.actions.shell_command_with_output.description_long = [[This action executes a system shell command, storing the return code in the 'return_code' key, and the command output in the 'output' key of the specificed storage area.  The environment the shell command runs in is the same environment FreeSWITCH provides to Lua.

NOTE: Due to limitations in Lua 5.1, this action has a slightly hackish implementation -- it's not portable, doubtful it will work on Windows, mileage may vary.]]
jester.help_map.system.actions.shell_command_with_output.params = {
  command = [[The shell command to run.  Arguments can be provided if needed.]],
  storage_area = [[The storage area to store the return code and output. Default is 'system'.]],
}

