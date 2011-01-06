--[[
  Play a menu of options for prepending a message to a forward message.
]]

return
{
  {
    action = "play_phrase",
    phrase = "forward_options",
    keys = {
      ["1"] = "forward_message prepend",
      ["2"] = "forward_message",
      ["*"] = "message_options",
    },
    repetitions = profile.menu_repetitions,
    wait = profile.menu_replay_wait,
  },
  {
    action = "call_sequence",
    sequence = "exit"
  },
}

