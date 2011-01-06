--[[
  Play a menu of options for collecting the forwarding number.
]]

return
{
  {
    action = "play_phrase",
    phrase = "forward_message_choose_method",
    keys = {
      ["1"] = "collect_extension forward_message_prepend_menu,forward_message_menu",
      -- TODO: Option 2 is for choosing the number from the voicemail
      -- directory, which still needs to be built.
      ["2"] = "invalid_extension message_options",
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

