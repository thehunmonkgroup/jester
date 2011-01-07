--[[
  Cleans messages from a mailbox marked as deleted.
]]

mailbox = args(1)
domain = args(2)

-- Are there any messages to remove?
messages_to_remove = storage("message_files_to_remove", "__count")

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
  -- See if there are any messages to remove.
  {
    action = "conditional",
    value = messages_to_remove,
    compare_to = 0,
    comparison = "equal",
    if_true = "none",
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

