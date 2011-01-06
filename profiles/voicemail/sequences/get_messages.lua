--[[
  Load all messages from the specified folder into the specified storage area.
]]

-- The numeric folder identifier found in the database.
folder = args(1)
-- Special type suffix for initial load of new/old messages, empty otherwise.
message_type = args(2)

mailbox = storage("login_settings", "mailbox_number")

return
{
  {
    action = "data_load",
    handler = "odbc",
    config = profile.db_config_message,
    filters = {
      mailbox = mailbox,
      domain = profile.domain,
      __folder = folder,
      __deleted = 0,
    },
    fields = {
      "__id",
      "caller_id_number",
      "caller_id_name",
      "caller_domain",
      "__timestamp",
      "__duration",
      "__deleted",
      "recording",
    },
    storage_area = "message" .. message_type,
    multiple = true,
    sort = "id",
  },
}

