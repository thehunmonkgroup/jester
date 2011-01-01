-- TODO: probably want to do some conditional logic up here to determine which
-- advanced options should be available based on the VM settings.
temp_keys = {
  ["1"] = "send_reply",
  ["2"] = "callback",
  ["3"] = "play_cid_envelope advanced_options",
  ["4"] = "call_outside_number message_options,collect",
  ["*"] = "message_options",
}

return
{
  {
    action = "play_phrase",
    phrase = "advanced_options_list",
    phrase_arguments = "Y:Y:Y:Y:N",
    keys = temp_keys,
    repetitions = 3,
    wait = 3000,
  },
  {
    action = "call_sequence",
    sequence = "exit"
  },
}

