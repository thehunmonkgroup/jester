mailbox = variable("voicemail_mailbox")
mailbox_directory = profile.voicemail_dir .. "/" .. profile.context .. "/" .. profile.domain .. "/" .. mailbox
recording_name = storage("record", "last_recording_name")

return
{
  {
    action = "move_file",
    source = profile.temp_recording_dir .. "/" .. recording_name,
    destination = mailbox_directory .. "/" .. recording_name,
  },
  {
    action = "data_update",
    handler = "odbc",
    config = profile.db_config_messages,
    fields = {
      -- Inbox folder is 0, all new messages go there.
      __folder = 0,
      caller_id_number = variable("caller_id_number"),
      caller_id_name = variable("caller_id_name"),
      __timestamp = storage("record", "last_recording_timestamp"),
      __duration = storage("record", "last_recording_duration"),
      recording = recording_name,
    },
    filters = {
      context = profile.context,
      mailbox = mailbox,
    },
    update_type = "insert",
  },
}

