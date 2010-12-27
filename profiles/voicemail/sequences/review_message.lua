temp_keys = {
  ["1"] = "caller_save_recorded_message",
  ["2"] = "caller_playback_recorded_message",
  ["3"] = "caller_rerecord_message",
}

if profile.operator_extension then
  temp_keys["0"] = "transfer_to_operator"
end

return
{
  {
    action = "conditional",
    value = profile.review_messages,
    compare_to = true,
    comparison = "equal",
    if_false = "exit",
  },
  {
    action = "play_phrase",
    phrase = "greeting_options",
    keys = temp_keys,
    repetitions = 3,
    wait = 3000,
  },
  {
    action = "call_sequence",
    sequence = "exit",
  },
}

