return
{
  {
    action = "get_digits",
    min_digits = 4,
    audio_files = "phrase:get_mailbox_number",
    bad_input = "",
  },
  {
    action = "set_storage",
    storage_area = "login_settings",
    data = {
      mailbox_number = storage("get_digits", "digits"),
      login_type = "missing_mailbox",
    },
  },
  {
    action = "call_sequence",
    sequence = "validate_mailbox_login",
  },
}

