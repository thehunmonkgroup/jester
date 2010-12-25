return
{
  {
    action = "delete_file",
    file = profile.temp_recording_dir .. "/" .. storage("record", "last_recording_name"),
  },
}

