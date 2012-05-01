domain = args(1)
mailbox = args(2)
folder = args(3)
message_type = args(4)

return
{
  {
    action = "data_load_count",
    handler = "odbc",
    config = profile.db_config_message,
    filters = {
      mailbox = mailbox,
      domain = domain,
      __folder = folder,
      __deleted = 0,
    },
    count_field = "id",
    storage_key = "message_" .. message_type .. "_count",
  },
}

