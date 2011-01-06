--[[
  Load mailbox settings for the specified mailbox.
]]

mailbox = args(1)
domain = args(2)
-- The storage area to save the settings to.
storage_area = args(3)

return
{
  {
    action = "data_load",
    handler = "odbc",
    config = profile.db_config_mailbox,
    filters = {
      mailbox = mailbox,
      domain = domain,
    },
    fields = {
      "mailbox",
      "domain",
      "password",
      "email",
      "email_template",
      "email_messages",
      "mailbox_provisioned",
      "default_timezone",
      "play_caller_id",
      "play_envelope",
    },
    storage_area = storage_area,
  },
}

