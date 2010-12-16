return [[
Modules are written by Jester developers.  They are what makes actions
available to the sequences you write.  Most modules have a small collection
of related actions (for example, the 'play' module provides actions which play
sounds on a call).

The most important thing to know about modules is that they are pluggable --
this means that you only have to load modules that contain actions that you
wish to use, which will make Jester run more effeciently.  You are encouraged
to only load those modules that contain actions you use in the profile you're
loading.

One caveat to be aware of is that certain modules may depend on other modules
being enabled for them to function properly.  Check the help for a module to
see if it has dependencies on any other modules.
]]
