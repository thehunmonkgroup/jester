See LICENSE.txt to view the license for this software.

See INSTALL.txt for installation instructions.

See BUGS.txt for a list of known issues.

See TODO.txt for a list of things we're working on.

Once you've installed Jester, the next best step is to read the very extensive
help.  The exact way help is accessed depends on where you're calling it from.
'help scripts jhelp' would be called in the following ways depending on
where/how you're accessing help:

  From the command line:
    cd /path/to/freeswitch/scripts
    lua jester/jester.lua help scripts jhelp
  From the FreeSWITCH console:
    luarun jester/jester.lua help scripts jhelp
  Using the jhelp script (find this in the jester/scripts directory):
    jhelp scripts jhelp
