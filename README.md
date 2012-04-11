# Jester

## Introduction
Jester is a scripting toolkit for FreeSWITCH written in the Lua programming language. It's functionality sits squarely between the feature set of the XML dialplan, IVR menus, and custom scripting. The goal of Jester is to ease development of voice workflows by providing a simple, unified way to implement more complex features that normally require custom scripting.

## Installation
See **INSTALL.txt** for installation instructions.

## Architecture
Jester is written to be small, simple, and extensible. The core code is less than 800 lines! Most user tasks are carried out by pluggable modules, and people familiar with Lua scripting will find it easy to add new modules to extend functionality further. End users are spared the complexity of writing full scripts, and instead work inside script-like templates called 'sequences', that allow them to pass commands with parameters to the underlying modules, which handle all the dirty work.

## Comedian mail replica
Jester's default profile is a replica of Asterisk's Comedian Mail system. Those transitioning from Asterisk to FreeSWITCH with concerns about the differences between the two voicemail systems can leverage this to provide a seamless transition to their end users.

## Help

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

## Other stuff
See **LICENSE.txt** to view the license for this software.

See **BUGS.txt** for a list of known issues.

See **TODO.txt** for a list of things we're working on.
