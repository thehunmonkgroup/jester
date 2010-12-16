return [[
Configurations are stored in three different places in Jester:

 1. jester/conf.lua - Main configuration
 2. profiles/[name].lua - Profile configuration
 3. modules/[name]/conf.lua - Module configuration

The main configuration gets loaded for all calls to Jester, while the profile
configuration only gets loaded for the profile that Jester is currently
running.

Profile configurations are allowed to override the main configuration for the
following variables:

modules, sequence_path, key_order

One important thing to note about these configurations is that any variables in
them are only processed once, when Jester initially loads.  If you have
variables that change throughout the course of the call, you'll need to put
in storage or in channel variables.
]]
