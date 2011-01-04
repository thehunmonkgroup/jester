--[[
  Saves a recorded message.
]]

-- Copy or move the temporary recording?
operation = args(1)

-- Message data.
mailbox = storage("message_info", "mailbox")
domain = storage("message_info", "domain")
recording_name = storage("message_info", "recording_name")
timestamp = storage("message_info", "timestamp")
duration = storage("message_info", "duration")
caller_id_number = storage("message_info", "caller_id_number")
caller_id_name = storage("message_info", "caller_id_name")
caller_domain = storage("message_info", "caller_domain")

-- Set up the file move action, specifying copying if necessary.
file_operation = {
  action = "move_file",
  source = profile.temp_recording_dir .. "/" .. recording_name,
  destination = profile.voicemail_dir .. "/" .. domain .. "/" .. mailbox .. "/" .. recording_name,
}
if operation == "copy" then
  file_operation.copy = true
end

return
{
  file_operation,
  {
    action = "data_update",
    handler = "odbc",
    config = profile.db_config_messages,
    fields = {
      domain = domain,
      mailbox = mailbox,
      -- Inbox folder is 0, all new messages go there.
      __folder = 0,
      caller_id_number = caller_id_number,
      caller_id_name = caller_id_name,
      caller_domain = caller_domain,
      __timestamp = timestamp,
      __duration = duration,
      recording = recording_name,
    },
    update_type = "insert",
  },
  -- Fire an event indicating a new message was received.
  {
    action = "fire_event",
    event_type = "new_message",
    headers = {
      Mailbox = mailbox,
      Domain = domain,
    },
  },
}

