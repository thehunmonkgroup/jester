--[[
  Checks to see if deleted messages should be removed automatically, and calls
  the deletion sequence if necessary.
]]

mailbox = storage("login_settings", "mailbox_number")

return
{
  {
    action = "conditional",
    value = profile.auto_delete_messages,
    compare_to = true,
    comparison = "equal",
    if_true = "remove_mailbox_deleted_messages " .. mailbox .. "," .. profile.domain,
  },
}
