voicemail_group = args(1)

return
{
  {
    action = "data_load",
    handler = "odbc",
    config = profile.db_config_voicemail_groups,
    filters = {
      group_name = voicemail_group,
    },
    fields = {
      "mailbox",
      "context",
      "domain",
    },
    storage_area = "voicemail_group",
    multiple = true,
  },
  {
    action = "call_sequence",
    sequence = "save_group_message",
  },
}

