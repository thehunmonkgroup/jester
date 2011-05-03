--[[
  Profile configuration file.  All variables put in here will be processed once
  during the jester bootstrap.

  If you have a variable foo that you want to have a value of "bar", do:
  foo = "bar"

  Array/record syntax is like this:
  foo = { bar = "baz", bing = "bong" }

  Variables from the main configuration may be used in values, by accessing
  them through the global.<varname> namespace.

  Channel variables may be used in values, by accessing them through the
  variable("<varname>") function.

  Storage variables may be used in values, by accessing them through the
  storage("<varname>") function.

  Initial arguments may be used in values, by accessing them through the
  args(<argnum>) function.
]]

--[[
  Everything in this section should not be edited unless you know what you are
  doing!
]]

-- Overrides the global debug configuration for this profile only.
debug = true

-- Overrides the global sequence path for this profile only.
sequence_path = global.profile_path .. "/demos/sequences"

--[[
  The sections below can be customized safely.
]]

--[[
  Directory paths.
]]

-- The directory where recordings are stored temporarily while recording.
temp_recording_dir = "/tmp"

