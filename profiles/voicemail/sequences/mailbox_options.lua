--[[
  Play mailbox options menu to the user.
]]

-- Mailbox info.
mailbox = storage("login_settings", "mailbox_number")
mailbox_directory = profile.mailboxes_dir .. "/" .. mailbox
-- Result of the check for the temporary greeting.
file_exists = storage("file", "file_exists")

return
{
  -- Check for the existence of a temporary greeting -- this result is passed
  -- into the phrase for announcing mailbox options.
  {
    action = "file_exists",
    file = mailbox_directory .. "/temp.wav",
  },
  {
    action = "play_phrase",
    phrase = "mailbox_options",
    phrase_arguments = file_exists,
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


