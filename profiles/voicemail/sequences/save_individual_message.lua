--[[
  Save a individual message.
]]

-- Mailbox info.
mailbox = storage("message_info", "mailbox")
domain = storage("message_info", "domain")

-- Result of the attempt to load the mailbox.
loaded_mailbox = storage("mailbox_settings_message", "mailbox")

-- Mailbox settings.
email_messages = storage("mailbox_settings_message", "email_messages")
mailbox_provisioned = storage("mailbox_settings_message", "mailbox_provisioned")

return
{
  -- Try to load the mailbox.
  {
    action = "call_sequence",
    sequence = "sub:load_mailbox_settings " .. mailbox .. "," .. domain .. ",mailbox_settings_message",
  },
  -- Mailbox load failed, clean up.
  {
    action = "conditional",
    value = loaded_mailbox,
    compare_to = "",
    comparison = "equal",
    if_true = "cleanup_temp_recording",
  },
  -- Provision the mailbox if it's not provisioned.
  {
    action = "conditional",
    value = mailbox_provisioned,
    compare_to = "no",
    comparison = "equal",
    if_true = "sub:provision_mailbox " .. mailbox .. "," .. domain,
  },
  -- Email the message if necessary.
  {
    action = "conditional",
    value = email_messages,
    compare_to = "no",
    comparison = "equal",
    if_false = "sub:email_message",
  },
  -- Save the message to the mailbox if necessary, otherwise clean up.
  {
    action = "conditional",
    value = email_messages,
    compare_to = "email_only",
    comparison = "equal",
    if_true = "sub:cleanup_temp_recording",
    if_false = "sub:save_recorded_message",
  },
}

