greeting = args(1)

mailbox = storage("login_settings", "mailbox_number")
mailbox_directory = profile.mailboxes_dir .. "/" .. mailbox

return
{
  {
    action = "play_phrase",
    phrase = "greeting_options",
    repetitions = profile.menu_repititions,
    wait = profile.menu_replay_wait,
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
