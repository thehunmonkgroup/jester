--[[
  Login workflow when a mailbox is provided, and no password is required.
]]

mailbox = storage("login_settings", "mailbox_number")
-- Result of the attempt to load the mailbox.
loaded_mailbox = storage("mailbox_settings", "mailbox")

return
{
  {
    action = "call_sequence",
    sequence = "sub:load_mailbox_settings " .. mailbox .. "," .. profile.domain .. ",mailbox_settings",
  },
  {
    action = "conditional",
    value = loaded_mailbox,
    compare_to = "",
    comparison = "equal",
    if_true = "invalid_extension exit",
    if_false = "load_new_old_messages",
  },
}

