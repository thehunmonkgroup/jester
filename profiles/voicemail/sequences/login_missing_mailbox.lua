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
    data = {
      storage_area = "login_settings",
      mailbox_number = storage("get_digits", "digits"),
      login_type = "missing_mailbox",
    },
  },
  {
    action = "call_sequence",
    sequence = "validate_mailbox_login",
  },
}

