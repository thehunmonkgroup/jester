loaded_mailbox = storage("mailbox_settings_message", "mailbox")
email_messages = storage("mailbox_settings_message", "email_messages")

return
{
  {
    action = "call_sequence",
    sequence = "sub:load_mailbox_settings " .. profile.mailbox .. "," .. profile.context,
  },
  {
    action = "conditional",
    value = loaded_mailbox,
    compare_to = "",
    comparison = "equal",
    if_true = "cleanup_temp_recording"
  },
  {
    action = "conditional",
    value = email_messages,
    compare_to = "no",
    comparison = "equal",
    if_false = "sub:email_message"
  },
  {
    action = "conditional",
    value = email_messages,
    compare_to = "email_only",
    comparison = "equal",
    if_true = "cleanup_temp_recording"
    if_false = "sub:save_message " .. profile.mailbox .. "," .. profile.context
  },
}

