mailbox = variable("voicemail_mailbox")
mailbox_directory = profile.voicemail_dir .. "/" .. profile.context .. "/" .. profile.domain .. "/" .. mailbox

greeting = args(1)

return
{
  {
    action = "create_directory",
    directory = mailbox_directory,
  },
  {
    action = "play_phrase",
    phrase = "record_greeting",
    phrase_arguments = greeting,
    keys = {
      ["#"] = ":break",
    },
  },
  {
    action = "wait",
    milliseconds = 500,
  },
  {
    action = "record",
    location = mailbox_directory,
    filename = greeting .. ".tmp.wav",
    pre_record_sound = "phrase:beep",
    keys = {
      ["#"] = ":break",
    },
  },
  {
    action = "call_sequence",
    sequence = "record_greeting_thank_you " .. greeting,
  },
}
