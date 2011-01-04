--[[
  Play options to the user to save, playback, or re-record their message.
]]

-- Is the operator extension enabled?
operator = args(1)

-- Set up the initial review keys.
review_keys = {
  ["1"] = "caller_save_recorded_message exit",
  ["2"] = "caller_playback_recorded_message",
  ["3"] = "caller_rerecord_message",
}

-- Add in the operator extension if it's enabled.
if operator == "operator" then
  review_keys["0"] = "operator_transfer_prepare"
end

return
{
  -- If message review isn't enabled, then exit the call.
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
    keys = review_keys,
    repetitions = profile.menu_repititions,
    wait = profile.menu_replay_wait,
  },
  {
    action = "call_sequence",
    sequence = "exit",
  },
}

