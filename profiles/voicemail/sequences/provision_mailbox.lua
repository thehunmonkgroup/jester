mailbox = args(1)
domain = args(2)

return
{
  {
    action = "create_directory",
    directory = profile.voicemail_dir .. "/" .. domain,
  },
  {
    action = "create_directory",
    directory = profile.voicemail_dir .. "/" .. domain .. "/" .. mailbox,
  },
  {
    action = "data_update",
    handler = "odbc",
    config = profile.db_config_mailboxes,
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

