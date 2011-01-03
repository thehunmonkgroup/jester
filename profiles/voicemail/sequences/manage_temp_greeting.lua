mailbox = storage("login_settings", "mailbox_number")
mailbox_directory = profile.mailboxes_dir .. "/" .. mailbox

return
{
  {
    action = "file_exists",
    file = mailbox_directory .. "/temp.wav",
  },
  {
    action = "conditional",
    value = storage("file", "file_exists"),
    compare_to = "false",
    comparison = "equal",
    if_true = "record_greeting temp",
  },
  {
    action = "play_phrase",
    phrase = "temp_greeting_options",
    repetitions = profile.menu_repititions,
    wait = profile.menu_replay_wait,
    keys = {
      ["1"] = "record_greeting temp",
      ["2"] = "erase_temp_greeting",
    },
  },
  {
    action = "call_sequence",
    sequence = "exit",
  },
}


