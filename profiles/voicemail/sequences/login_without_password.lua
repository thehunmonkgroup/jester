mailbox = storage("login_settings", "mailbox_number")
retrieved_mailbox = storage("mailbox_settings", "mailbox")

return
{
  {
    action = "call_sequence",
    sequence = "sub:load_mailbox_settings " .. mailbox .. "," .. profile.domain .. ",mailbox_settings",
  },
  {
    action = "conditional",
    value = retrieved_mailbox,
    compare_to = "",
    comparison = "equal",
    if_true = "invalid_mailbox",
    if_false = "load_new_old_messages",
  },
}

