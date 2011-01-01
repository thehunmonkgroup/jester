temp_keys = {
  ["4"] = "call_outside_number help,collect",
  ["*"] = "help",
}

return
{
  {
    action = "play_phrase",
    phrase = "advanced_options_list",
    phrase_arguments = "N:N:N:Y:N",
    keys = temp_keys,
    repetitions = 3,
    wait = 3000,
  },
  {
    action = "call_sequence",
    sequence = "exit"
  },
}

