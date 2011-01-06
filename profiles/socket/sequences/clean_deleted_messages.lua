--[[
  Cleans messages marked as deleted.
]]

return
{
  -- Load file information for all message files that are to be removed.
  {
    action = "data_load",
    handler = "odbc",
    config = profile.db_config_message,
    fields = {
      "mailbox",
      "domain",
      "recording",
    },
    filters = {
      __deleted = 1,
    },
    multiple = true,
    storage_area = "message_files_to_remove",
  },
  -- Delete the database rows for deleted messages.
  {
    action = "data_delete",
    handler = "odbc",
    config = profile.db_config_message,
    filters = {
      __deleted = 1,
    },
  },
  -- Clean up the message files.
  {
    action = "call_sequence",
    sequence = "remove_deleted_message_files",
  },
}

