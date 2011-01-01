temp_keys = {
  ["1"] = "caller_save_recorded_message exit",
  ["2"] = "caller_playback_recorded_message",
  ["3"] = "caller_rerecord_message",
}

if profile.operator_extension then
  temp_keys["0"] = "transfer_to_operator"
end

return
{
  {
    action = "play",
    file = profile.temp_recording_dir .. "/" .. storage("record", "last_recording_name"),
    keys = temp_keys,
  },
  {
    action = "call_sequence",
    sequence = "review_message",
  },
}

