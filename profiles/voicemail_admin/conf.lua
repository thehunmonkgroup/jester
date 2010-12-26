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
sequence_path = global.profile_path .. "/voicemail_admin/sequences"

voicemail_dir = global.base_dir .. "/storage/voicemail"
context = variable("voicemail_context")
domain = variable("domain")

mailboxes_dir = voicemail_dir .. "/" .. context .. "/" .. domain

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

