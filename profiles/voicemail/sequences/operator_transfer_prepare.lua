--[[
  Ask the caller to save their message or hold for an operator.
]]

-- Key map for transferring.
transfer_keys = {
  ["1"] = "caller_save_recorded_message transfer_to_operator",
}

return
{
  -- Ask to accept message.
  {
    action = "play_phrase",
    phrase = "accept_recording_or_hold",
    keys = transfer_keys,
  },
  -- Wait for response.
  {
    action = "wait",
    milliseconds = profile.menu_replay_wait,
    keys = transfer_keys,
  },
  -- No response, so delete the message and inform the user.
  {
    action = "call_sequence",
    sequence = "sub:cleanup_temp_recording",
  },
  {
    action = "play_phrase",
    phrase = "message_deleted_undeleted",
    phrase_arguments = "1",
  },
  {
    action = "call_sequence",
    sequence = "transfer_to_operator",
  },
}
