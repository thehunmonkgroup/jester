return
{
  {
    action = "play_phrase",
    phrase = "forward_message_choose_method",
    keys = {
      ["1"] = "collect_extension forward_message_prepend_menu,forward_message_menu",
      ["2"] = "invalid_mailbox",
      ["*"] = "message_options",
    },
    repetitions = profile.menu_repititions,
    wait = profile.menu_replay_wait,
  },
  {
    action = "call_sequence",
    sequence = "exit"
  },
}

