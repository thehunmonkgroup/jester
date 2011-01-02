mailbox = storage("message_info", "mailbox")
domain = storage("message_info", "domain")
loaded_mailbox = storage("mailbox_settings_message", "mailbox")
email_messages = storage("mailbox_settings_message", "email_messages")
mailbox_provisioned = storage("mailbox_settings_message", "mailbox_provisioned")

return
{
  {
    action = "call_sequence",
    sequence = "sub:load_mailbox_settings " .. mailbox .. "," .. domain .. ",mailbox_settings_message",
  },
  {
    action = "conditional",
    value = loaded_mailbox,
    compare_to = "",
    comparison = "equal",
    if_true = "cleanup_temp_recording",
  },
  {
    action = "conditional",
    value = mailbox_provisioned,
    compare_to = "no",
    comparison = "equal",
    if_true = "sub:provision_mailbox " .. mailbox .. "," .. domain,
  },
  {
    action = "conditional",
    value = email_messages,
    compare_to = "no",
    comparison = "equal",
    if_false = "sub:email_message",
  },
  {
    action = "conditional",
    value = email_messages,
    compare_to = "email_only",
    comparison = "equal",
    if_true = "cleanup_temp_recording",
    if_false = "sub:save_recorded_message",
  },
}

