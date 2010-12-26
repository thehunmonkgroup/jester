--[[
  Profile configuration file.  All variables put in here will be processed once
  during the jester bootstrap.

  If you have a variable foo that you want to have a value of "bar", do:
  foo = "bar"

  Array/record syntax is like this:
  foo = { bar = "baz", bing = "bong" }

  Variables from the main configuration may be used in values, by accessing
  them through the jester.conf.<varname> namespace.

  Channel variables may be used in values, by accessing them through the
  jester._get_variable("<varname>") function.
]]

-- Do not edit or remove this line.
module(..., package.seeall)

-- Overrides the global debug configuration for this profile only.
debug = true

-- Modules to load.
-- Overrides the global debug configuration for this profile only.
modules = {
  "core_actions",
  "play",
  "record",
  "file",
  "data",
  "email",
  "format",
}

-- Set this to true to allow a caller to press * to access the voicemail
-- administration area for the mailbox.
check_messages = true

-- Overrides the global debug configuration for this profile only.
sequence_path = jester.conf.profile_path .. "/voicemail_message/sequences"

voicemail_dir = jester.conf.base_dir .. "/storage/voicemail"
temp_recording_dir = "/tmp"
mailbox = jester.initial_args[1]
context = jester.initial_args[2] or "default"
domain = jester.get_variable("domain")

mailboxes_dir = voicemail_dir .. "/" .. context .. "/" .. domain
mailbox_dir = mailboxes_dir .. "/" .. mailbox

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

