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
      context = variable("voicemail_context"),
      mailbox = storage("default", "mailbox_number"),
      password = storage("get_digits", "password"),
    },
    fields = {
      "mailbox",
      "saycid",
      "envelope",
      "email",
    },
    storage_area = "mailbox_settings",
  },
  {
    action = "conditional",
    value = storage("get_digits", "password"),
    compare_to = "",
    comparison = "equal",
    if_true = "exit",
  },
  {
    action = "conditional",
    value = storage("mailbox_settings", "mailbox"),
    compare_to = "",
    comparison = "equal",
    if_true = "mailbox_login_incorrect",
  },
  {
    action = "call_sequence",
    sequence = "load_new_old_messages",
  },
}

