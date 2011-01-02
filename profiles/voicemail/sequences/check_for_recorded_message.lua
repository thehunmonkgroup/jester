recording_name = storage("record", "last_recording_name")

return
{
  {
    action = "file_exists",
    file = profile.temp_recording_dir .. "/" .. recording_name,
    if_false = "none",
  },
  {
    action = "conditional",
    value = profile.voicemail_group,
    compare_to = "",
    comparison = "equal",
    if_true = "save_individual_message",
    if_false = "load_voicemail_group " .. profile.voicemail_group,
  },
}

