greeting = args(1)

mailbox = storage("login_settings", "mailbox_number")
mailbox_directory = profile.mailboxes_dir .. "/" .. mailbox
mailbox_provisioned = storage("mailbox_settings", "mailbox_provisioned")

return
{
  {
    action = "conditional",
    value = mailbox_provisioned,
    compare_to = "no",
    comparison = "equal",
    if_true = "sub:provision_mailbox " .. mailbox .. "," .. profile.domain,
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

