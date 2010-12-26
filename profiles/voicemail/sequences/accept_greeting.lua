mailbox = storage("login_settings", "mailbox_number")
mailbox_directory = profile.mailboxes_dir .. "/" .. mailbox

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
    action = "call_sequence",
    sequence = "mailbox_options",
  },
}

