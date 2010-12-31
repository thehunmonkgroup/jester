count = storage("counter", "voicemail_group_row")
total_mailboxes = storage("voicemail_group", "__count")
row_count = storage("counter", "voicemail_group_row")
mailbox = storage("voicemail_group", "mailbox_" .. row_count)
domain = storage("voicemail_group", "domain_" .. row_count)
mailbox_dir = profile.voicemail_dir .. "/" .. domain .. "/" .. mailbox
loaded_mailbox = storage("mailbox_settings_message", "mailbox")
email_messages = storage("mailbox_settings_message", "email_messages")

return
{
  {
    action = "counter",
    increment = 1,
    storage_key = "voicemail_group_row",
    compare_to = total_mailboxes,
    if_greater = "cleanup_temp_recording",
  },
  {
    action = "call_sequence",
    sequence = "sub:load_mailbox_settings " .. mailbox .. "," .. domain .. ",mailbox_settings_message",
  },
  {
    action = "conditional",
    value = loaded_mailbox,
    compare_to = "",
    comparison = "equal",
    if_true = "save_group_message",
  },
  {
    action = "create_directory",
    directory = mailbox_dir,
  },
  {
    action = "conditional",
    value = email_messages,
    compare_to = "no",
    comparison = "equal",
    if_false = "sub:email_message " .. mailbox,
  },
  {
    action = "conditional",
    value = email_messages,
    compare_to = "email_only",
    comparison = "equal",
    if_false = "sub:save_recorded_message " .. mailbox .. "," .. domain .. ",copy",
  },
  {
    action = "call_sequence",
    sequence = "save_group_message",
  },
}

