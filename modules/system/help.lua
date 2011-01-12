jester.help_map.system = {}
jester.help_map.system.description_short = [[Access to operating system commands.]]
jester.help_map.system.description_long = [[This module provides access to various commands available at the operating system level.]]

jester.help_map.system.actions = {}

jester.help_map.system.actions.shell_command = {}
jester.help_map.system.actions.shell_command.description_short = [[Execute a shell command.]]
jester.help_map.system.actions.shell_command.description_long = [[This action executes a system shell command.  The environment the shell command runs in is the same environment FreeSWITCH provides to Lua.]]
jester.help_map.system.actions.shell_command.params = {
  command = [[The shell command to run.  Arguments can be provided if needed.]],
}

