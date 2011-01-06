--[[
  Menu for changing to another folder.
]]

-- Folder data.
current_folder = storage("message_settings", "current_folder")

return
{
  -- Place key map in the sequence space, since all actions use the same map.
  keys = {
    ["0"] = "set_current_folder 0",
    ["1"] = "set_current_folder 1",
    ["2"] = "set_current_folder 2",
    ["3"] = "set_current_folder 3",
    ["4"] = "set_current_folder 4",
    ["#"] = "set_current_folder " .. current_folder,
  },
  {
    action = "play_phrase",
    phrase = "change_to_folder",
  },
  {
    action = "play_keys",
    key_announcements = {
      ["0"] = "new_messages",
      ["1"] = "old_messages",
      ["2"] = "work_messages",
      ["3"] = "family_messages",
      ["4"] = "friends_messages",
      ["#"] = "pound_cancel",
    },
    order = {
      "0",
      "1",
      "2",
      "3",
      "4",
      "#",
    },
    repetitions = profile.menu_repetitions,
    wait = profile.menu_replay_wait,
  },
  {
    action = "call_sequence",
    sequence = "exit",
  },
}

