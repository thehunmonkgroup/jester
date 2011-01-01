caller_id_number = variable("caller_id_number")
caller_id_name = variable("caller_id_name")

return
{
  {
    action = "file_exists",
    file = profile.temp_recording_dir .. "/" .. storage("record", "last_recording_name"),
    if_false = "none",
  },
  {
    action = "set_storage",
    storage_area = "message_info",
    data = {
      caller_id_number = caller_id_number,
      caller_id_name = caller_id_name,
      caller_domain = profile.caller_domain,
    },
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

