--[[
  Play advanced options menu for the main menu.
]]

outdial_extension = storage("mailbox_settings", "outdial_extension")

return
{
  {
    action = "play_phrase",
    phrase = "advanced_options_list",
    phrase_arguments = "N:N:N:Y:N",
    keys = {
      -- Outdial.
      ["4"] = "outdial " .. outdial_extension .. ",help,collect",
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

