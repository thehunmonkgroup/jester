--[[
  Provision a mailbox.
]]

-- Mailbox info.
mailbox = args(1)
domain = args(2)

return
{
  -- Try to create the domain directory since it may not be created yet.
  {
    action = "create_directory",
    directory = profile.voicemail_dir .. "/" .. domain,
  },
  -- Create the mailbox directory.
  {
    action = "create_directory",
    directory = profile.voicemail_dir .. "/" .. domain .. "/" .. mailbox,
  },
  -- Mark the mailbox as provisioned.
  {
    action = "data_update",
    handler = "odbc",
    config = profile.db_config_mailbox,
    fields = {
      mailbox_provisioned = "yes",
    },
    filters = {
      mailbox = mailbox,
      domain = domain,
    },
    update_type = "update",
  },
}

