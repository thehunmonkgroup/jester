--[[
  Main login sequence.
]]

-- Mailbox to log in for -- may or may not be provided.
mailbox = args(1)

return
{
  -- Direct to the proper login workflow depending on if the mailbox was
  -- provided or not.
  {
    action = "conditional",
    value = mailbox,
    compare_to = "",
    comparison = "equal",
    if_true = "login_missing_mailbox",
    if_false = "login_have_mailbox " .. mailbox,
  },
}

