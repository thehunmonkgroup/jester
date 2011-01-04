--[[
  Check for a valid recorded message, and call the appropriate save sequence
  if one is found.
]]

recording_name = storage("record", "last_recording_name")

return
{
  {
    action = "file_exists",
    file = profile.temp_recording_dir .. "/" .. recording_name,
    if_false = "none",
  },
  -- Individual messages and message groups have different save workflows, so
  -- detect which one it is here.
  {
    action = "conditional",
    value = profile.message_group,
    compare_to = "",
    comparison = "equal",
    if_true = "save_individual_message",
    if_false = "load_message_group " .. profile.message_group,
  },
}

