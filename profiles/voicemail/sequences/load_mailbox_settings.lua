mailbox = args(1)
context = args(2)
storage_area = args(3)

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
      "password",
      "email",
      "email_messages",
      "timezone",
      "saycid",
      "envelope",
    },
    storage_area = storage_area,
  },
}

