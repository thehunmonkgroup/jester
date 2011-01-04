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

-- Mailbox being accessed.
mailbox = args(1)

-- Domain the mailbox is in -- defaults to the domain variable of the current
-- channel.
domain = args(2)
if domain == "" then
  domain = variable("domain")
end

-- To specify the caller is from another domain, set the channel variable
-- 'voicemail_caller_domain' to the domain before calling Jester.  Otherwise
-- the caller is assumed to be calling from the same domain that the voicemail
-- is in.
caller_domain = variable("voicemail_caller_domain")
if caller_domain == "" then
  caller_domain = domain
end

-- Voicemail group (if provided).
message_group = args(3)

-- Main directory that stores voicemail messages.
-- NOTE: This directory must already be created and writable by the FreeSWITCH
-- user.
voicemail_dir = global.base_dir .. "/storage/voicemail/default"

-- The directory containing the mailboxes for the domain.
mailboxes_dir = voicemail_dir .. "/" .. domain

-- The mailbox directory being accessed.
mailbox_dir = mailboxes_dir .. "/" .. mailbox

-- Modules to load.
-- Overrides the global module configuration for this profile only.
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
  "event",
}

-- Overrides the global sequence path for this profile only.
sequence_path = global.profile_path .. "/voicemail/sequences"

--[[
  The sections below can be customized safely.
]]

--[[
  Directory paths.
]]

-- The directory where recordings are stored temporarily while recording.
temp_recording_dir = "/tmp"

--[[
  Custom extensions.
]]

-- Name of the extension to transfer to when a key is press to reach the
-- operator (must be in the same context).
-- Set this to false to disable the operator extension.
operator_extension = "operator"

-- Name of the extension to transfer to when a request to dial an outside
-- number is made.
call_outside_number_extension = "call_outside_number"

--[[
  Menu options.
]]

-- Number of milliseconds to wait before replaying a menu.
menu_replay_wait = 3000

-- Number of times to play a menu before giving up if no user response.
menu_repetitions = 3

--[[
  Message email options.
  The following token replacements are available:
    :mailbox - Mailbox where the message is being left.
    :datetime - Formatted date/time when the message was left.
    :caller_id_number
    :caller_id_name

  See 'help action email' for more information on sending emails.
]]

-- Format timestamps to this format string -- tokens are same as strftime.
email_date_format = "%Y-%m-%d %H:%M:%S"

-- Server settings.
email_from_address = "noreply@" .. variable("hostname")
email_server = "localhost"
email_port = 25

-- Templates.
email_templates = {}

-- Default template, for message delivery.
email_templates.default = {}
email_templates.default.subject = "New voicemail message for :mailbox"
email_templates.default.message = [[
Mailbox number: :mailbox
Date/time: :datetime
CallerID number: :caller_id_number
CallerID name: :caller_id_name]]

-- Notification template, for message notification.
email_templates.notification = {}
email_templates.notification.subject = "New voicemail message for :mailbox"
email_templates.notification.message = "From: :caller_id_number"
email_templates.notification.allow_attachments = false

--[[
  User input.
]]

-- How many seconds to wait for user input.
user_input_timeout = 3

-- The minimum number of digits in a valid mailbox extension.
mailbox_min_digits = 4

-- The maximum number of digits in a valid mailbox extension.
mailbox_max_digits = 10

-- The minimum number of digits in a valid password.
password_min_digits = 4

-- The maximum number of digits in a valid password.
password_max_digits = 10

--[[
  Other settings.
]]

-- Set this to true to allow a caller to press * to access the voicemail
-- administration area for the mailbox.
check_messages = true

-- Set this to true to allow a caller to press # to review their message after
-- recording it, or false to disable.
review_messages = true

--[[
  ODBC database table configurations.
]]

-- Table that stores mailbox configurations.
db_config_mailboxes = {
  database_type = "mysql",
  database = "jester",
  table = "voicemail",
}

-- Table that stores messages.
db_config_messages = {
  database_type = "mysql",
  database = "jester",
  table = "messages",
}

-- Table that stores messages.
db_config_message_groups = {
  database_type = "mysql",
  database = "jester",
  table = "message_groups",
}

