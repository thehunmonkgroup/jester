mailbox = args(1)
domain = args(2)
operation = args(3)

-- Message data.
recording_name = storage("record", "last_recording_name")
timestamp = storage("record", "last_recording_timestamp")
duration = storage("record", "last_recording_duration")
caller_id_number = storage("message_info", "caller_id_number")
caller_id_name = storage("message_info", "caller_id_name")
caller_domain = storage("message_info", "caller_domain")

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
}

