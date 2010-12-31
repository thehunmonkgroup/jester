mailbox = storage("login_settings", "mailbox_number")
password = storage("get_digits", "new_password_1")

return
{
  {
    action = "data_update",
    handler = "odbc",
    config = profile.db_config_mailboxes,
    fields = {
      password = password,
    },
    filters = {
      domain = profile.domain,
      mailbox = mailbox,
    },
    update_type = "update",
  },
  {
    action = "play_phrase",
    phrase = "password_updated",
  },
  {
    action = "call_sequence",
    sequence = "mailbox_options",
  },
}

