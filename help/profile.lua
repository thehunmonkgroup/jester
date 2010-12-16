return [[
A profile is a high-level configuration tool that allows you to override
certain Jester global configurations, in addition to providing your own custom
configurations.

Jester must be given a valid profile to run when it is called.  The included
'voicemail' profile is a replica of Asterisk's Comedian Mail.

The main advatages of profiles are:

 1. If you design your sequences intelligently, you can make them behave in
    different ways by loading different profiles with different settings.
 2. They allow you to only load the modules you need for the sequences you
    are running, so you can load different sets of modules at different times
    depending on what sequences you are running.  Used properly, this can make
    Jester much more efficient.

See 'help config' to learn which global variables can be overridden by
profiles.
]]
