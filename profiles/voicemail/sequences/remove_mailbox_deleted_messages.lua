--[[
  Cleans messages from a mailbox marked as deleted.
]]

mailbox = args(1)
domain = args(2)

return
{
  -- Load file information for all message files that are to be removed.
  {
    action = "data_load",
    handler = "odbc",
    config = profile.db_config_message,
    fields = {
      "recording",
    },
    filters = {
      mailbox = mailbox,
      domain = domain,
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
      mailbox = mailbox,
      domain = domain,
      __deleted = 1,
    },
  },
  -- Clean up the message files.
  {
    action = "call_sequence",
    sequence = "remove_mailbox_deleted_message_files " .. mailbox .. "," .. domain,
  },
}

