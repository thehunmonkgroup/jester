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
  "play",
  "record",
  "file",
  "data",
  "email",
  "format",
  "navigation",
  "get_digits",
  "log",
  "tracker",
  "hangup",
  "dialplan_tools",
}

-- Overrides the global debug configuration for this profile only.
sequence_path = global.profile_path .. "/voicemail/sequences"

-- Main directory that stores voicemail messages.
voicemail_dir = global.base_dir .. "/storage/voicemail"

-- The directory where recordings are stored temporarily while recording.
temp_recording_dir = "/tmp"

-- Mailbox being accessed.
mailbox = args(1)

-- Context the mailbox is in -- defaults to "default".
if args(2) == "" then
  context = "default"
else
  context = args(2)
end

-- Voicemail group (if provided).
voicemail_group = args(3)

-- The domain that the messages are stored under.
domain = variable("domain")

-- The directory containing the mailboxes for this context/domain.
mailboxes_dir = voicemail_dir .. "/" .. context .. "/" .. domain

-- The mailbox directory being accessed.
mailbox_dir = mailboxes_dir .. "/" .. mailbox

-- Set this to true to allow a caller to press * to access the voicemail
-- administration area for the mailbox.
check_messages = true

-- Set this to true to allow a caller to press # to review their message after
-- recording it, or false to disable.
review_messages = true

-- Name of the extension to transfer to when a key is press to reach the
-- operator (must be in the same context).
-- Set this to false to disable the operator extension.
operator_extension = "operator"

-- ODBC configuration for the table that stores mailbox configurations.
db_config_mailboxes = {
  database_type = "mysql",
  database = "jester",
  table = "voicemail",
}

-- ODBC configuration for the table that stores messages.
db_config_messages = {
  database_type = "mysql",
  database = "jester",
  table = "messages",
}

-- ODBC configuration for the table that stores messages.
db_config_voicemail_groups = {
  database_type = "mysql",
  database = "jester",
  table = "message_groups",
}

