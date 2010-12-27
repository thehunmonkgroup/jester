group = ""

return
{
  {
    action = "file_exists",
    file = profile.temp_recording_dir .. "/" .. storage("record", "last_recording_name"),
    if_false = "none",
  },
  {
    action = "conditional",
    value = group,
    compare_to = "",
    comparison = "equal",
    if_true = "save_individual_message",
    if_false = "save_group_message " .. group,
  },
}

