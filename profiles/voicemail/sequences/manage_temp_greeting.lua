--[[
  Check for a temporary greeting, redirect to record it if not found, otherwise
  give the user options for recording/erasing it.
]]

-- Mailbox info.
mailbox = storage("login_settings", "mailbox_number")
mailbox_directory = profile.mailboxes_dir .. "/" .. mailbox
-- Result of the check for the temporary greeting.
file_exists = storage("file", "file_exists")

return
{
  {
    action = "file_exists",
    file = mailbox_directory .. "/temp.wav",
  },
  -- If no temporary greeting exists, redirect the user to record one.
  {
    action = "conditional",
    value = file_exists,
    compare_to = "false",
    comparison = "equal",
    if_true = "record_greeting temp",
  },
  -- Otherwise, give them a menu to record/erase it.
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


