-- Message data.
message_number = storage("counter", "message_number")
message_id = storage("message", "id_" .. message_number)

return
{
  {
    action = "data_update",
    handler = "odbc",
    config = profile.db_config_messages,
    fields = {
      __folder = args(1),
    },
    filters = {
      __id = message_id,
    },
    update_type = "update",
  },
  {
    action = "conditional",
    value = args(2),
    compare_to = "save",
    comparison = "equal",
    if_true = "message_saved " .. args(1),
  },
}

