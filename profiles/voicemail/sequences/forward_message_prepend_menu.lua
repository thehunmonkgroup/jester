return
{
  {
    action = "play_phrase",
    phrase = "forward_options",
    keys = {
      ["1"] = "forward_message_prepend",
      ["2"] = "forward_message",
      ["*"] = "message_options",
    },
    repetitions = 3,
    wait = 3000,
  },
  {
    action = "call_sequence",
    sequence = "exit"
  },
}

