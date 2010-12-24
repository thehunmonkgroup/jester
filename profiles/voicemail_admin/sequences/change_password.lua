return
{
  {
    action = "get_digits",
    min_digits = 4,
    audio_files = "phrase:enter_new_password",
    bad_input = "",
    storage_key = "new_password_1",
  },
  {
    action = "get_digits",
    min_digits = 4,
    audio_files = "phrase:reenter_new_password",
    bad_input = "",
    storage_key = "new_password_2",
  },
  {
    action = "conditional",
    value = storage("get_digits", "new_password_1"),
    compare_to = storage("get_digits", "new_password_2"),
    comparison = "equal",
    if_true = "update_password",
  },
  {
    action = "play_phrase",
    phrase = "password_mismatch",
  },
  {
    action = "call_sequence",
    sequence = "mailbox_options",
  },
}

