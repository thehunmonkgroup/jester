recording_name = storage("record", "last_recording_name")

playback_keys = {
  ["1"] = "caller_save_recorded_message exit",
  ["2"] = "caller_playback_recorded_message",
  ["3"] = "caller_rerecord_message",
}

operator_on_review = ""
if profile.operator_extension then
  playback_keys["0"] = "transfer_to_operator"
  operator_on_review = "operator"
end

return
{
  {
    action = "play",
    file = profile.temp_recording_dir .. "/" .. recording_name,
    keys = playback_keys,
  },
  {
    action = "call_sequence",
    sequence = "review_message " .. operator_on_review,
  },
}

