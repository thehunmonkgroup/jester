mailbox = storage("login_settings", "mailbox_number")
mailbox_directory = profile.mailboxes_dir .. "/" .. mailbox

greeting = args(1)

return
{
  {
    action = "play_phrase",
    phrase = "greeting_options",
    repetitions = 3,
    wait = 3000,
    keys = {
     ["1"] = "accept_greeting " .. greeting,
     ["2"] = "listen_to_greeting " .. greeting,
     ["3"] = "record_greeting " .. greeting,
    },
  },
  {
    action = "call_sequence",
    sequence = "exit",
  },
}
