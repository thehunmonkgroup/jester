--[[
  Record a greeting.
]]

-- The greeting name to record.
greeting = args(1)

-- Mailbox info.
mailbox = storage("login_settings", "mailbox_number")
mailbox_directory = profile.mailboxes_dir .. "/" .. mailbox
mailbox_provisioned = storage("mailbox_settings", "mailbox_provisioned")

return
{
  -- Provision the mailbox if it's not provisioned yet.
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
  -- Record to a temporary file.
  {
    action = "record",
    location = mailbox_directory,
    filename = greeting .. ".tmp.wav",
    pre_record_sound = "phrase:beep",
    max_length = profile.max_greeting_length,
    silence_secs = profile.recording_silence_end,
    silence_threshold = profile.recording_silence_threshold,
    keys = {
      ["#"] = ":break",
    },
  },
  {
    action = "call_sequence",
    sequence = "record_greeting_thank_you " .. greeting,
  },
}

