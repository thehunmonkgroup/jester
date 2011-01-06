--[[
  Record and prepend a custom message to a forward message.
]]

-- Message data.
message_number = storage("counter", "message_number")
recording_name = storage("message", "recording_" .. message_number)
prepend_recording_name = storage("record", "last_recording_name")

return
{
  {
    action = "wait",
    milliseconds = 500,
  },
  {
    action = "record",
    location = profile.temp_recording_dir,
    pre_record_sound = "phrase:beep",
    max_length = profile.max_message_length,
    silence_secs = profile.recording_silence_end,
    silence_threshold = profile.recording_silence_threshold,
    keys = {
      ["#"] = ":break",
    },
  },

  {
    action = "record_merge",
    base_file = profile.temp_recording_dir .. "/" .. recording_name,
    merge_file = profile.temp_recording_dir .. "/" .. prepend_recording_name,
    merge_type = "prepend",
  },
}

