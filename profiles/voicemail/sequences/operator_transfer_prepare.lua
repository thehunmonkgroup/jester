transfer_keys = {
  ["1"] = "caller_save_recorded_message transfer_to_operator",
}

return
{
  {
    action = "play_phrase",
    phrase = "accept_recording_or_hold",
    keys = transfer_keys,
  },
  {
    action = "wait",
    milliseconds = 3000,
    keys = transfer_keys,
  },
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
