--[[
  Menu for getting the method of collecting the outside number to call.
]]

-- Message data.
message_number = storage("counter", "message_number")
caller_id_number = storage("message", "caller_id_number_" .. message_number)

return
{
  {
    action = "play_phrase",
    phrase = "callback",
    phrase_arguments = caller_id_number,
    keys = {
      ["1"] = "callback_set_number",
      ["2"] = "call_outside_number message_options,collect",
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

