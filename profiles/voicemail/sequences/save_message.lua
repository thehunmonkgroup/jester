return
{
  keys = {
    ["0"] = "update_message_folder 0,save",
    ["1"] = "update_message_folder 1,save",
    ["2"] = "update_message_folder 2,save",
    ["3"] = "update_message_folder 3,save",
    ["4"] = "update_message_folder 4,save",
    ["#"] = "help"
  },
  {
    action = "play_phrase",
    phrase = "save_to_folder",
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
    repetitions = profile.menu_repititions,
    wait = profile.menu_replay_wait,
  },
  {
    action = "call_sequence",
    sequence = "exit",
  },
}

