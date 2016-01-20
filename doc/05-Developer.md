# Developer documentation

In the future this section will be more detailed. For now it's just a holding place for the outline of the future help, and a quick reference to the Jester core functions that are most commonly used in modules.

The core code and modules are fairly well documented, and much can be learned from reviewed them directly. The most important quick tips are:

 * You must have this line at the top of your main module file:
      local core = require "jester.core"
   This allows you to access Jester core via the <code>core</code> variable.
 * The main module file must named <code>init.lua</code>. The <code>foo</code> module would live at
     jester/modules/foo/init.lua
 * A 'conf.lua' is required:
     jester/modules/foo/conf.lua
   The file contains a mapping of module functions to action names, and can declare multiple handlers for actions.

## Quick reference

 * workflow:
    core.run_action(action)
    core.queue_sequence(sequence)
 * data:
    core.get_storage(area, key, [default])
    core.set_storage(area, key, value)
    core.clear_storage(area, [key])
 * key_presses:
    core.actionable_key()
    core.keys
 * loops:
    -- Different than session:ready()!
    core.ready()
 * logging:
    -- Discouraged to use in a module, let the user do their own custom
    -- logging with the log action.
    core.log(msg, [prefix], [level])
    -- Recommended, use extensively so that problems can be easily spotted
    -- when debugging is turned on.
    core.debug_log(msg, ...)
 * misc:
    core.wait(milliseconds)
    core.trim(string)

Other core functions are available, check the code directly.

## Core stacks

Jester keeps track of a lot of things in stacks, at the following namespaces:

 * <code>core.channel.stack.sequence</code>
 * <code>core.channel.stack.sequence\_name</code>
 * <code>core.channel.stack.navigation</code>
 * <code>core.channel.stack.active</code>
 * <code>core.channel.stack.exit</code>
 * <code>core.channel.stack.hangup</code>

