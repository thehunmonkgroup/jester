mailbox = args(1)

return
{
  {
    action = "set_storage",
    storage_area = "login_settings",
    data = {
      voicemail_domain = profile.domain,
    },
  },
  {
    action = "conditional",
    value = mailbox,
    compare_to = "",
    comparison = "equal",
    if_true = "login_missing_mailbox",
    if_false = "login_have_mailbox " .. mailbox,
  },
}

