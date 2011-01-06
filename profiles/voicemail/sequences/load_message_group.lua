--[[
  Load mailbox information for a message group, then direct to the group save
  sequence.
]]

message_group = args(1)

return
{
  {
    action = "data_load",
    handler = "odbc",
    config = profile.db_config_message_group,
    filters = {
      group_name = message_group,
    },
    fields = {
      "mailbox",
      "domain",
    },
    storage_area = "message_group",
    multiple = true,
  },
  {
    action = "call_sequence",
    sequence = "save_group_message",
  },
}

