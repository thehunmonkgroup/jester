jester.help_map.core_actions = {}
jester.help_map.core_actions.description_short = [[Actions provided by jester core.]]
jester.help_map.core_actions.description_long = [[This module provides actions that are closely tied to the core functionality of Jester.]]

jester.help_map.core_actions.actions = {}

jester.help_map.core_actions.actions.none = {}
jester.help_map.core_actions.actions.none.description_short = [[Dummy action which does nothing]]
jester.help_map.core_actions.actions.none.description_long = [[This action is just a placeholder.  It can be used to skip taking any action, or to provide a way to call another sequence without taking any other action.]]

jester.help_map.core_actions.actions.call_sequence = {}
jester.help_map.core_actions.actions.call_sequence.description_short = [[Call a new sequence from the currently running sequence.]]
jester.help_map.core_actions.actions.call_sequence.description_long = [[This action calls a new sequence from the currently running sequence.]]
jester.help_map.core_actions.actions.call_sequence.params = {
  sequence = [[The new sequence to call.  By default the original sequence is not resumed when the new sequence completes.  To resume the old sequence (effectively making the new sequence a subroutine of the original), prefix the sequence with 'sub:', eg. 'sub:somesequence arg1,arg2'.  See 'help sequences subsequences' for more information.]],
}

jester.help_map.core_actions.actions.conditional = {}
jester.help_map.core_actions.actions.conditional.description_short = [[Call a new sequence based on a simple conditional check.]]
jester.help_map.core_actions.actions.conditional.description_long = [[This action allows simple comparison of a value against another value, and can call another sequence based on if the comparison returns true or false.  It's really only meant for fairly simple sequence logic -- for more complex logic see 'help sequences tricks'.]]
jester.help_map.core_actions.actions.conditional.params = {
  value = [[The value that you want to compare.]],
  compare_to = [[The value that you expect it to be, or for pattern matching, any valid Lua pattern (see the Lua manual for more information on Lua patterns).]],
  comparison = [[(Optional) The kind of comparison to perform.  Valid values are "equal", "match", "greater_than", and "less_than".  Default is "equal".]],
  if_true = [[(Optional) The sequence to call if the comparison is true.]],
  if_false = [[(Optional) The sequence to call if the comparison is false.]],
}

jester.help_map.core_actions.actions.set_variable = {}
jester.help_map.core_actions.actions.set_variable.description_short = [[Sets channel variables.]]
jester.help_map.core_actions.actions.set_variable.description_long = [[This action sets channel variables on the channel that Jester is currently running.]]
jester.help_map.core_actions.actions.set_variable.params = {
  data = [[A table of channel variables to set.  Keys are the variable names, values are the variable values, eg. 'data = { context = "default", shape = "square" }'.]],
}

jester.help_map.core_actions.actions.set_storage = {}
jester.help_map.core_actions.actions.set_storage.description_short = [[Set storage values in a given storage area.]]
jester.help_map.core_actions.actions.set_storage.description_long = [[This action sets key/value pairs in the given storage area.]]
jester.help_map.core_actions.actions.set_storage.params = {
  storage_area = [[(Optional) The area to store the value in. Defaults to 'default'.]],
  data = [[A table of data to store in the storage area.  Keys are the storage keys, values are the storage values, eg. 'data = { foo = "bar", baz = "bang" }'.]],
}

jester.help_map.core_actions.actions.copy_storage = {}
jester.help_map.core_actions.actions.copy_storage.description_short = [[Copy storage values from one storage area to another.]]
jester.help_map.core_actions.actions.copy_storage.description_long = [[This action performs a complete copy of all keys in a storage area, placing them in the specified new storage area.  Note that only basic data types (string, number, boolean) are copied -- all others are ignored.]]
jester.help_map.core_actions.actions.copy_storage.params = {
  storage_area = [[(Optional) The area to copy. Defaults to 'default'.]],
  copy_to = [[The storage area to copy the data to.  Note that any data already existing in this area will be removed prior to the copy.]],
  move = [[(Optional) If set to true, clears the data from the original storage area, which effectively makes the operation a move.  Default is false.]],
}

jester.help_map.core_actions.actions.clear_storage = {}
jester.help_map.core_actions.actions.clear_storage.description_short = [[Remove storage values from a given storage area.]]
jester.help_map.core_actions.actions.clear_storage.description_long = [[This action removes key/value pairs from the given storage area.]]
jester.help_map.core_actions.actions.clear_storage.params = {
  storage_area = [[(Optional) The area to clear. Defaults to 'default'.]],
  data_keys = [[(Optional) A table of keys to remove from the storage area.  If this parameter is not given, then the entire storage area is cleared, use caution! Eg. 'data = { "key1","key2" }'.]],
}

jester.help_map.core_actions.actions.exit_sequence = {}
jester.help_map.core_actions.actions.exit_sequence.description_short = [[Registers a sequence to be executed on exit.]]
jester.help_map.core_actions.actions.exit_sequence.description_long = [[This action registers a sequence to be executed after Jester has finished running all sequences related to the active call.  Channel variables and storage values are available when the registered sequence is run.

Sequences registered here are run before the sequences registered on hangup, and are always run, regardless if the user actively hung up the call.  If you want to guarantee that the sequence will run regardless of user hangup, it's best to put it here instead of in the hangup loop.]]
jester.help_map.core_actions.actions.exit_sequence.params = {
  sequence = [[The sequence to execute.]],
}

jester.help_map.core_actions.actions.wait = {}
jester.help_map.core_actions.actions.wait.description_short = [[Wait before performing the next action.]]
jester.help_map.core_actions.actions.wait.description_long = [[This action causes Jester to wait before continuing on.  Silence is streamed on the channel during the wait period.]]
jester.help_map.core_actions.actions.wait.params = {
  milliseconds = [[The number of milliseconds to wait.]],
  keys = [[(Optional) See 'help sequences keys'.]],
}

jester.help_map.core_actions.actions.load_profile = {}
jester.help_map.core_actions.actions.load_profile.description_short = [[Load a profile dynamically.]]
jester.help_map.core_actions.actions.load_profile.description_long = [[This action allows you to load a profile dynamically from within a sequence.  This can be useful for loading a 'heavier' profile only when needed from within a 'lighter' profile.]]
jester.help_map.core_actions.actions.load_profile.params = {
  profile = [[The new profile to load.]],
  sequence = [[(Optional) A sequence to execute after loading the profile.  If this is provided, any running sequences in the current loop will be discarded, and this sequence will be run from the top of a new sequence stack.]],
}

jester.help_map.core_actions.actions.api_command = {}
jester.help_map.core_actions.actions.api_command.description_short = [[Execute a FreeSWITCH API command.]]
jester.help_map.core_actions.actions.api_command.description_long = [[This action allows you to execute a FreeSWITCH API command, as if from the console command line.  The command result is stored in the specified key.]]
jester.help_map.core_actions.actions.api_command.params = {
  command = [[The command to execute.]],
  storage_key = [[(Optional) The key to store the command result under in the 'api_command' storage area.  Default is 'result'.]],
}

