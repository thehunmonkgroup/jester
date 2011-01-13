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
    -- Note that there are more columns in the mailbox table, but these
    -- columns are the only ones with support in the profile now.
    fields = {
      "mailbox",
      "domain",
      "password",
      "mailbox_setup_complete",
      "mailbox_provisioned",
      "default_language",
      "default_timezone",
      "email",
      "email_template",
      "email_messages",
      "play_caller_id",
      "play_envelope",
      "review_messages",
      "next_after_command",
      "temp_greeting_warn",
      "operator_extension",
      "callback_extension",
      "outdial_extension",
      "exit_extension",
    },
    storage_area = storage_area,
  },
}

