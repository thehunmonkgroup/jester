password_1 = storage("get_digits", "new_password_1")
password_2 = storage("get_digits", "new_password_2")

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
    value = password_1,
    compare_to = password_2,
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

