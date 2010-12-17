--[[
  Profile configuration file.  All variables put in here will be processed once
  during the jester bootstrap.

  If you have a variable foo that you want to have a value of "bar", do:
  foo = "bar"

  Array/record syntax is like this:
  foo = { bar = "baz", bing = "bong" }

  Variables from the main configuration may be used in values, as well as calls
  to channel.variable("<varname>") to get channel variables.
]]

-- Do not edit or remove this line.
module(..., package.seeall)

-- Overrides the global debug configuration for this profile only.
debug = true

-- Modules to load.
-- Overrides the global debug configuration for this profile only.
modules = {
  "core_actions",
  "navigation",
  "play",
  "get_digits",
  "record",
  "file",
  "log",
  "data",
  "tracker",
  "hangup",
}
-- Overrides the global debug configuration for this profile only.
sequence_path = jester.conf.profile_path .. "/voicemail/sequences"

voicemail_dir = jester.conf.base_dir .. "/storage/voicemail"
temp_recording_dir = "/tmp"
context = jester.get_variable("voicemail_context")
domain = jester.get_variable("domain")

mailbox_dir = voicemail_dir .. "/" .. context .. "/" .. domain

db_config_mailboxes = {
  database_type = "mysql",
  database = "jester",
  table = "voicemail",
}

db_config_messages = {
  database_type = "mysql",
  database = "jester",
  table = "messages",
}

