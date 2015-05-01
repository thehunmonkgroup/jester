# Jester

## Update 2015-05-01:

Although I still fully intend to upgrade Jester to Lua 5.2, I have not been
able to do so yet. As of this writing, it only works with Lua 5.1, and some
older versions of the dependencies. Using LuaRocks, the following will set
up a working dependencies for Lua 5.1:

```
luarocks install luasocket 2.0.2-5
luarocks install luafilesystem 1.5.0-3
```

The newer versions of FreeSWITCH allow you to use a system-installed Lua,
which should allow a workaround until this software is upgraded.

If you'd like to help me with the Lua 5.2 upgrade (either with a patch or
funding/sponsorship), please file an issue!

## Introduction
Jester is a scripting toolkit for [FreeSWITCH](https://freeswitch.org) written in the Lua programming language. It's functionality sits squarely between the feature set of the XML dialplan, IVR menus, and custom scripting. The goal of Jester is to ease development of voice workflows by providing a simple, unified way to implement more complex features that normally require custom scripting.

## Installation
See **INSTALL.md** for installation instructions.

## Architecture
Jester is written to be small, simple, and extensible. The core code is less than 800 lines! Most user tasks are carried out by pluggable modules, and people familiar with Lua scripting will find it easy to add new modules to extend functionality further. End users are spared the complexity of writing full scripts, and instead work inside script-like templates called 'sequences', that allow them to pass commands with parameters to the underlying modules, which handle all the dirty work.

## Comedian mail replica
Jester's default profile is a replica of Asterisk's Comedian Mail system. Those transitioning from Asterisk to FreeSWITCH with concerns about the differences between the two voicemail systems can leverage this to provide a seamless transition to their end users.

## Documentation

Jester comes with an extensive help system, available from both the command line and within the FreeSWITCH console, which should make it easy for new users and developers to get up to speed.

Once you've installed Jester, the next best step is to read the help.  The exact way help is accessed depends on where you're calling it from. ```help scripts jhelp``` would be called in the following ways depending on where/how you're accessing help:

 * From the command line:

   ```
   cd /path/to/freeswitch/scripts
   lua jester/jester.lua help scripts jhelp
   ```
 * From the FreeSWITCH console:

   ```
   lua jester/jester.lua help scripts jhelp
   ```
 * Using the jhelp script (find this in the jester/scripts directory):

   ```
   jhelp scripts jhelp
   ```

## Support

The issue tracker for this project is provided to file bug reports, feature requests, and project tasks -- support requests are not accepted via the issue tracker. For all support-related issues, including configuration, usage, and training, consider hiring a competent consultant.

## Other stuff
See **LICENSE.txt** to view the license for this software.

See **BUGS.md** for a list of known issues.

See **TODO.md** for a list of things we're working on.
