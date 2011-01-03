mailbox = storage("login_settings", "mailbox_number")
mailbox_directory = profile.mailboxes_dir .. "/" .. mailbox

return
{
  {
    action = "file_exists",
    file = mailbox_directory .. "/temp.wav",
  },
  {
    action = "play_phrase",
    phrase = "mailbox_options",
    phrase_arguments = storage("file", "file_exists"),
    repetitions = profile.menu_repititions,
    wait = profile.menu_replay_wait,
    keys = {
      ["1"] = "record_greeting unavail",
      ["2"] = "record_greeting busy",
      ["3"] = "record_greeting greet",
      ["4"] = "manage_temp_greeting",
      ["5"] = "change_password",
      ["*"] = "main_menu",
    },
  },
  {
    action = "call_sequence",
    sequence = "exit",
  },
}


