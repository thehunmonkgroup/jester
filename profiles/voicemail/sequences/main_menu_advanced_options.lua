--[[
  Play advanced options menu for the main menu.
]]

return
{
  {
    action = "play_phrase",
    phrase = "advanced_options_list",
    phrase_arguments = "N:N:N:Y:N",
    keys = {
      -- Outdial.
      ["4"] = "call_outside_number help,collect",
      ["*"] = "help",
    },
    repetitions = profile.menu_repetitions,
    wait = profile.menu_replay_wait,
  },
  {
    action = "call_sequence",
    sequence = "exit"
  },
}

