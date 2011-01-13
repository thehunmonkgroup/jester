--[[
  Accept a recorded greeting.
]]

mailbox = storage("login_settings", "mailbox_number")
mailbox_directory = profile.mailboxes_dir .. "/" .. mailbox

-- Have we set up this mailbox yet?
mailbox_setup_complete = storage("mailbox_settings", "mailbox_setup_complete")

greeting = args(1)
greeting_tmp = mailbox_directory .. "/" .. greeting .. ".tmp.wav"
greeting_new = mailbox_directory .. "/" .. greeting .. ".wav"

return
{
  {
    action = "move_file",
    source = greeting_tmp,
    destination = greeting_new,
  },
  {
    action = "play_phrase",
    phrase = "greeting_saved",
  },
  {
    action = "conditional",
    value = mailbox_setup_complete,
    compare_to = "no",
    comparison = "equal",
    if_false = "mailbox_options",
  },
}

