return
{
  {
    action = "play_phrase",
    phrase = "advanced_options_list",
    phrase_arguments = "N:N:N:Y:N",
    keys = {
      ["4"] = "call_outside_number help,collect",
      ["*"] = "help",
    },
    repetitions = profile.menu_repititions,
    wait = profile.menu_replay_wait,
  },
  {
    action = "call_sequence",
    sequence = "exit"
  },
}

