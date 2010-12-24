mailbox = variable("voicemail_mailbox")
mailbox_directory = profile.voicemail_dir .. "/" .. profile.context .. "/" .. profile.domain .. "/" .. mailbox

greeting = args(1)
greeting_filename = mailbox_directory .. "/" .. greeting .. ".tmp.wav"

return
{
  {
    action = "play",
    file = greeting_filename,
    keys = {
     ["1"] = "accept_greeting " .. greeting,
     ["2"] = "listen_to_greeting " .. greeting,
     ["3"] = "record_greeting " .. greeting,
     ["#"] = ":break",
    },
  },
  {
    action = "call_sequence",
    sequence = "record_greeting_confirm " .. greeting,
  },
}
