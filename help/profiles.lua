-- profiles
jester.help_map.profiles = {}
jester.help_map.profiles.description_short = [[Basic layout of Jester's configuration system.]]
jester.help_map.profiles.description_long = [[A profile is a high-level configuration tool that allows you to override certain Jester global configurations, in addition to providing your own custom constants that you can access in any sequences loaded within the profile.

Jester must be given a valid profile to run when it is called.

The main advatages of profiles are:

  1. They provide an easy way to store constants that are used over and over again in sequences, such as database connection configurations, or paths to custom sound files, etc.
  2. They allow you to only load the modules you need for the sequences you are running, so you can load different sets of modules at different times depending on what sequences you are running.  Used properly, this can make Jester more efficient.
  3. If you design your sequences intelligently, you can make them behave in different ways by loading different profiles with different settings.]]

-- profiles -> config
jester.help_map.profiles.config = {}
jester.help_map.profiles.config.description_short = [[Profile configuration overview.]]
jester.help_map.profiles.config.description_long = [[The profile configuration lives at 'jester/profiles/[name]/conf.lua ([name] being the name of the profile).  The configuration is loaded after the global configuration to allow overrides, but also loaded fairly early in the bootstrap process to allow for maximum control.

Profiles can use variables from two places:

  Global configuration:
    Variables defined in jester/conf.lua can be accessed through the 'jester.conf' namespace, eg. 'jester.conf.base_dir' accesses the 'base_dir' variable from the global configuration.
  Channel variables:
    Variables defined in the current FreeSWITCH channel that Jester is running in can be accessed through the 'jester.get_variable()' function, eg. 'jester.get_variable("caller_id_name")' accesses the 'caller_id_name' variable from the channel.

Profile configurations are allowed to override the main configuration for the following variables:

modules, sequence_path, key_order, debug

The default 'voicemail' profile configuration file is well commented, check it out for more details.]]

-- profiles -> files
jester.help_map.profiles.files = {}
jester.help_map.profiles.files.description_short = [[Information on other things typically stored with a profile.]]
jester.help_map.profiles.files.description_long = [[Profiles are meant to be an easy way to keep everything together.

In typical practice, the sequences, phrase macros, database schemas, etc. that a profile uses are all stored under the main profile directory, to make it centralized and portable.

This does require a bit of extra configuration in some areas:

  Sequences:
    The global 'sequence_path' variable will need to be overridden, and instead pointed to a location inside the profile.  A common line would be:
      sequence_path = jester.conf.profile_path .. "/[name]/sequences"

  Phrase macros:
    These are normally kept in the various 'lang' folders in the main FreeSWITCH configuration, but they can be stored in a custom location.  A typical configuration line for that in, for example, the 'conf/lang/en/en.xml' FreeSWITCH configuration file, would be:
      <X-PRE-PROCESS cmd="include" data="$${base_dir}/scripts/jester/profiles/[name]/phrases.xml"/>]]

-- profiles -> default
jester.help_map.profiles.default = {}
jester.help_map.profiles.default.description_short = [[Overview of the default profile shipped with Jester.]]
jester.help_map.profiles.default.description_long = [[The included default 'voicemail' profile is a replica of Asterisk's Comedian Mail.

It is intended to be an exact replica of the original, a showcase of the power and flexibility of the Jester system, and a template to use as a starting place for learning and building other workflows.

Everything needed to set up the profile is included in the profile directory.  Check out the INSTALL.txt there for more details.]]

