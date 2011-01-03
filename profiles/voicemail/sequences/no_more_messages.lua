next_sequence = args(1)

return
{
  {
    action = "play_phrase",
    phrase = "no_more_messages",
    keys = {
      ["3"] = "advanced_options",
      ["4"] = "prev_message",
      ["5"] = "repeat_message",
      ["6"] = "next_message",
      ["7"] = "delete_undelete_message",
      ["8"] = "forward_message_menu",
      ["9"] = "save_message",
      ["*"] = "help",
      ["#"] = "exit",
    },
  },
  {
    action = "call_sequence",
    sequence = next_sequence,
  },
}

