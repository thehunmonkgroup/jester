--[[
  Menu for getting the method of collecting the number to call.
]]

-- Message data.
message_number = storage("counter", "message_number")
caller_id_number = storage("message", "caller_id_number_" .. message_number)

outdial_extension = storage("mailbox_settings", "outdial_extension")

return
{
  {
    action = "play_phrase",
    phrase = "callback",
    phrase_arguments = caller_id_number,
    keys = {
      ["1"] = "callback_set_number",
      ["2"] = "outdial " .. outdial_extension .. ",message_options,collect",
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

