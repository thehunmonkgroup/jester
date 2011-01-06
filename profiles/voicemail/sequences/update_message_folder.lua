--[[
  Update the folder a message lives in.
]]

-- The folder value to update the message to.
folder = args(1)
-- Is this an explicit save or an auto-save?
operation = args(2)

-- Message data.
message_number = storage("counter", "message_number")
message_id = storage("message", "id_" .. message_number)


return
{
  {
    action = "data_update",
    handler = "odbc",
    config = profile.db_config_message,
    fields = {
      __folder = folder,
    },
    filters = {
      __id = message_id,
    },
    update_type = "update",
  },
  -- If it's an explicit save, call the message saved sequence.
  {
    action = "conditional",
    value = operation,
    compare_to = "save",
    comparison = "equal",
    if_true = "message_saved " .. folder,
  },
}

