--[[
  Records a message.
]]

-- Is the operator option enabled?
operator = args(1)

-- Set up initial recording keys.
record_keys = {
  ["#"] = ":break",
}

-- Add in the operator key action if it's enabled.
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
    max_length = profile.max_message_length,
    silence_secs = profile.recording_silence_end,
    silence_threshold = profile.recording_silence_threshold,
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

