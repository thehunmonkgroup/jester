--[[
  Play mailbox options menu to the user.
]]

-- Mailbox info.
mailbox = storage("login_settings", "mailbox_number")
mailbox_directory = profile.mailboxes_dir .. "/" .. mailbox

-- Result of the check for the temporary greeting.
file_exists = storage("file", "file_exists")
-- Are we supposed to warn about a temporary greeting?
temp_greeting_warn = storage("mailbox_settings", "temp_greeting_warn")
warn = ""
if temp_greeting_warn == "yes" and file_exists == "true" then
  warn = "true"
end

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
    phrase_arguments = warn,
    repetitions = profile.menu_repetitions,
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


