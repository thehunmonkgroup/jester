return
{
  {
    action = "file_exists",
    file = profile.temp_recording_dir .. "/" .. storage("record", "last_recording_name"),
    if_true = "save_message_metadata",
  },
}

