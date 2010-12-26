mailbox = args(1)
context = args(2)

return
{
  {
    action = "data_load",
    handler = "odbc",
    config = profile.db_config_mailboxes,
    filters = {
      mailbox = mailbox,
      context = context,
    },
    fields = {
      "mailbox",
      "email",
      "email_messages",
      "timezone",
    },
    storage_area = "mailbox_settings_message",
  },
}

