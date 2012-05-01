--[[
  Check for a valid recorded message, and call the appropriate save sequence
  if one is found.
]]

recording_name = storage("record", "last_recording_name")
file_size = storage("file", "size")

return
{
  -- Make sure we have a recording name set, otherwise we're just checking to see
  -- if our temp_recording_dir exists (which it probably does).
  {
    action = "conditional",
    value = recording_name,
    compare_to = "",
    comparison = "equal",
    if_true = "none",
  },
  {
    action = "file_exists",
    file = profile.temp_recording_dir .. "/" .. recording_name,
    if_false = "none",
  },
  {
    action = "file_size",
    file = profile.temp_recording_dir .. "/" .. recording_name,
  },
  -- Check our file size, if we're too small, bail out.
  {
    action = "conditional",
    value = file_size,
    compare_to = profile.minimum_recorded_file_size,
    comparison = "less_than",
    if_true = "none",
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

