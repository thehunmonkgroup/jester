recording_name = storage("record", "last_recording_name")

return
{
  {
    action = "move_file",
    source = profile.temp_recording_dir .. "/" .. recording_name,
    destination = profile.mailbox_dir .. "/" .. recording_name,
  },
  {
    action = "data_update",
    handler = "odbc",
    config = profile.db_config_messages,
    fields = {
      context = profile.context,
      mailbox = profile.mailbox,
      -- Inbox folder is 0, all new messages go there.
      __folder = 0,
      caller_id_number = variable("caller_id_number"),
      caller_id_name = variable("caller_id_name"),
      __timestamp = storage("record", "last_recording_timestamp"),
      __duration = storage("record", "last_recording_duration"),
      recording = recording_name,
    },
    update_type = "insert",
  },
}

