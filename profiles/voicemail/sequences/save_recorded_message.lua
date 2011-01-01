recording_name = storage("record", "last_recording_name")
mailbox = args(1)
domain = args(2)
operation = args(3)

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
      caller_id_number = variable("caller_id_number"),
      caller_id_name = variable("caller_id_name"),
      caller_domain = profile.caller_domain,
      __timestamp = storage("record", "last_recording_timestamp"),
      __duration = storage("record", "last_recording_duration"),
      recording = recording_name,
    },
    update_type = "insert",
  },
}

