context = storage("login_settings", "voicemail_context")
entered_mailbox = storage("login_settings", "mailbox_number")
password = storage("get_digits", "password")
retrieved_mailbox = storage("mailbox_settings", "mailbox")

return
{
  {
    action = "get_digits",
    min_digits = 4,
    audio_files = "phrase:get_password",
    bad_input = "",
    storage_key = "password",
  },
  {
    action = "data_load",
    handler = "odbc",
    config = profile.db_config_mailboxes,
    filters = {
      context = context,
      mailbox = entered_mailbox,
      password = password,
    },
    fields = {
      "mailbox",
      "saycid",
      "envelope",
      "email",
      "timezone",
    },
    storage_area = "mailbox_settings",
  },
  {
    action = "conditional",
    value = password,
    compare_to = "",
    comparison = "equal",
    if_true = "exit",
  },
  {
    action = "conditional",
    value = retrieved_mailbox,
    compare_to = "",
    comparison = "equal",
    if_true = "mailbox_login_incorrect",
  },
  {
    action = "call_sequence",
    sequence = "load_new_old_messages",
  },
}

