# Developer documentation.

In the future this section will be more detailed. For now it's just a holding place for the outline of the future help, and a quick reference to the Jester core functions that are most commonly used in modules.

The core code and modules are fairly well documented, and much can be learned from reviewed them directly. The most important quick tips are:

  You must have this line at the top of your main module file:
    module(..., package.seeall)
  The module file must have the same name as the folder it lives in:
    The 'foo' module would live at 'jester/modules/foo/foo.lua'
  A 'conf.lua' and 'help.lua' are both required:
    'jester/modules/foo/conf.lua'
    'jester/modules/foo/help.lua'

Quick reference to the main core functions that are used in modules, by area:

  workflow:
    jester.run_action(action)
    jester.queue_sequence(sequence)
  data:
    jester.get_storage(area, key, [default])
    jester.set_storage(area, key, value)
    jester.clear_storage(area, [key])
  key_presses:
    jester.actionable_key()
    jester.keys
  loops:
    jester.ready() -- different than session:ready()!
  logging:
    jester.log(msg, [prefix], [level]) -- discouraged to use in a module, let the user do their own custom logging with the log action.
    jester.debug_log(msg, ...) -- recommended, use extensively so that problems can be easily spotted when debugging is turned on.
  misc:
    jester.wait(milliseconds)
    jester.trim(string)

Jester keeps track of a lot of things in stacks, at the following namespaces:
  channel.stack.sequence
  channel.stack.sequence_name
  channel.stack.navigation
  channel.stack.active
  channel.stack.exit
  channel.stack.hangup

