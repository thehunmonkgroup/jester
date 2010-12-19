-- scripts
jester.help_map.scripts = {}
jester.help_map.scripts.description_short = [[Various helper scripts]]
jester.help_map.scripts.description_long = [[Developing in any code system can be a complicated process, and developers inevitably come up with various helper scripts to help smooth the process.

Here you will find some scripts that ease working with Jester.]]

-- scripts -> jhelp
jester.help_map.scripts.jhelp = {}
jester.help_map.scripts.jhelp.description_short = [[Easy access to Jester's help system from anywhere.]]
jester.help_map.scripts.jhelp.description_long = [[jhelp is a small script that makes accessing the Jester help system from the command line much faster.  Instead of the very verbose:
  cd /path/to/scripts; lua jester/jester.lua help [sub-topic] [sub-sub-topic]

You can instead type:
  jhelp [sub-topic] [sub-sub-topic]
  
To install:

  1. Set the FREESWITCH_SCRIPTS_DIR variable to the full path of your FreeSWITCH 'scripts' directory (where the jester directory is located).  In a typical installation this would be '/usr/local/freeswitch/scripts' which is the default setting.

  2. Move (or better yet, symlink) this script somewhere into your $PATH (~/bin, /usr/local/bin, etc.)

This script should work on most Linux/Unix systems, but not on Windows, sorry!]]

-- scripts -> jsequence
jester.help_map.scripts.jsequence = {}
jester.help_map.scripts.jsequence.description_short = [[Easily generate properly formatted sequence templates or action fragments with one command.]]
jester.help_map.scripts.jsequence.description_long = [[jsequence removes the major headache of getting initial sequence templates laid out.  Probably the most frustrating part of building sequences is dealing with syntax errors due to improper formatting, and this script eliminates many of those issues.

When called with no arguments, it brings up a dialog asking a few simple questions which it uses to generate the template.  Alternatively, it can be called with a variable number of arguments, each the name of an action, and it will output just the structure for the passed actions, which can then be copied or piped into an existing sequence.  Or, when called with just the argument 'keys', it will output the template for the rather complex 'keys' parameter.
  
To install:

  1. Follow the instructions in the main Jester INSTALL.txt for properly setting your LUA_PATH environment variable.

  2. Move (or better yet, symlink) this script somewhere into your $PATH (~/bin, /usr/local/bin, etc.)]]
