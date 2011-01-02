operator = args(1)

record_keys = {
  ["#"] = ":break",
}

if operator == "operator" then
  record_keys["0"] = "operator_transfer_prepare"
end

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
    keys = record_keys,
  },
  {
    action = "play_phrase",
    phrase = "thank_you",
    keys = record_keys,
  },
  {
    action = "call_sequence",
    sequence = "review_message " .. operator,
  },
}

