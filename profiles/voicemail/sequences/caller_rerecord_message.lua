greeting_keys = {
  ["#"] = ":break",
}

if profile.operator_extension then
  greeting_keys["0"] = "transfer_to_operator"
end

return
{
  {
    action = "call_sequence",
    sequence = "sub:cleanup_temp_recording",
  },
  {
    action = "play_phrase",
    phrase = "default_greeting",
    keys = greeting_keys,
  },
  {
    action = "call_sequence",
    sequence = "record_message",
  },
}

