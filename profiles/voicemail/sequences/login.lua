mailbox = args(1)

return
{
  {
    action = "conditional",
    value = mailbox,
    compare_to = "",
    comparison = "equal",
    if_true = "login_missing_mailbox",
    if_false = "login_have_mailbox " .. mailbox,
  },
}

