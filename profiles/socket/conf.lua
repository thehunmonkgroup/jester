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
  variable("<varname>") function.  Note that it's doubtful you'll have a
  channel when connecting via the socket, so you probably shouldn't use this.

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

-- Modules to load.
-- Overrides the global module configuration for this profile only.
-- Modules that primarily use the session object are not included.  Some of
-- the included modules still have actions that use the session object, and
-- these actions should probably be avoided.
modules = {
  "core_actions",
  "data",
  "email",
  "event",
  "file",
  "format",
  "log",
  "navigation",
  "tracker",
}

-- Overrides the global sequence path for this profile only.
sequence_path = global.profile_path .. "/socket/sequences"

-- Main directory that stores voicemail messages.
-- NOTE: This directory must already be created and writable by the FreeSWITCH
-- user.
voicemail_dir = global.base_dir .. "/storage/voicemail/default"

--[[
  The sections below can be customized safely.
]]

--[[
  Directory paths.
]]

-- The directory where recordings are stored temporarily while recording.
temp_dir = "/tmp"

--[[
  ODBC database table configurations.
]]

-- Table that stores mailbox configurations.
db_config_mailbox = {
  database_type = "mysql",
  database = "jester",
  table = "mailbox",
}

-- Table that stores messages.
db_config_message = {
  database_type = "mysql",
  database = "jester",
  table = "message",
}

-- Table that stores messages.
db_config_message_group = {
  database_type = "mysql",
  database = "jester",
  table = "message_group",
}

