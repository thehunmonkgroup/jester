--[[
  Mark a mailbox as set up in the database.
]]

-- Mailbox info.
mailbox = args(1)
domain = args(2)

return
{
  {
    action = "data_update",
    handler = "odbc",
    config = profile.db_config_mailbox,
    fields = {
      mailbox_setup_complete = "yes",
    },
    filters = {
      mailbox = mailbox,
      domain = domain,
    },
    update_type = "update",
  },
}

