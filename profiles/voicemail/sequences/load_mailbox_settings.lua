mailbox = args(1)
domain = args(2)
storage_area = args(3)

return
{
  {
    action = "data_load",
    handler = "odbc",
    config = profile.db_config_mailboxes,
    filters = {
      mailbox = mailbox,
      domain = domain,
    },
    fields = {
      "mailbox",
      "password",
      "email",
      "email_messages",
      "mailbox_provisioned",
      "timezone",
      "saycid",
      "envelope",
    },
    storage_area = storage_area,
  },
}

