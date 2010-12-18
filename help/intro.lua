-- intro
jester.help_map.intro = {}
jester.help_map.intro.description_short = [[A high-level introduction to the way Jester works.]]
jester.help_map.intro.description_long = [[Jester is VoIP toolkit for FreeSWITCH written in Lua.  The goal of Jester is to provide a standardized set of tools that allow you to accomplish most of the common tasks you'll face when putting together phone trees, voicemail systems, etc.  And, if Jester can't do something you need, it's modular, extensible design allows you to easily add the functionality in a way that not only you but others can benefit from!]]

-- intro -> run
jester.help_map.intro.run = {}
jester.help_map.intro.run.description_short = [[How to run Jester.]]
jester.help_map.intro.run.description_long = [[Jester is designed to be executed as a standard lua script from the FreeSWITCH dialplan.  The general format is as follows:
    <action application="lua" data="jester/jester.lua <profile> <sequence> [arg1],[arg2],...,[argN]"/>

Jester also has an extensive help system, which can be accessed in one of three ways:

  From the shell (from the directory jester.lua resides in):
    lua jester/jester.lua help [sub-topic] [sub-sub-topic] [...]

  From FreeSWITCH CLI:
    luarun jester/jester.lua help [sub-topic] [sub-sub-topic] [...]
  
  From the jhelp script:
    jhelp [sub-topic] [sub-sub-topic] [...]

  As you can see the jhelp method is much easier -- see 'help scripts jhelp' for more information on how to set it up.]]

-- intro -> config
jester.help_map.intro.config = {}
jester.help_map.intro.config.description_short = [[Basic layout of Jester's configuration system.]]
jester.help_map.intro.config.description_long = [[Configurations are stored in three different places in Jester:

  1. jester/conf.lua - Global configuration
  2. profiles/[name]/conf.lua - Profile configuration
  3. modules/[name]/conf.lua - Module configuration

The global configuration file and the default profile's configuration file are well commented, check them out for more details.

The main configuration gets loaded for all calls to Jester, while the profile configuration only gets loaded for the profile that Jester is currently running.

One important thing to note about these configurations is that any variables in them are only processed once, when Jester initially loads.  If you have variables that change throughout the course of the call, you'll need to put them in storage or in channel variables.]]

-- intro -> help
jester.help_map.intro.help = {}
jester.help_map.intro.help.description_short = [[Basic layout of Jester's help system.]]
jester.help_map.intro.help.description_long = [[Jester's help is implemented in the simple Lua structured data format of tables.  If you find accessing the help from the help system too tedious, the help files themselves are quite readable directly.

The help system lives in two distinct areas:

  1. General help:
    These help files deal with most topics and are located at 'jester/help/*'
  2. Module help:
    Detailed help for modules and the actions they provide.  They are located in 'jester/modules/[name]/help.lua'.]]
