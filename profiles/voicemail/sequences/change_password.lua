--[[
  Collect a new password twice, validate they match, and call the update
  sequence as appropriate.
]]

password_1 = storage("get_digits", "new_password_1")
password_2 = storage("get_digits", "new_password_2")

return
{
  {
    action = "get_digits",
    min_digits = profile.password_min_digits,
    max_digits = profile.password_max_digits,
    audio_files = "phrase:enter_new_password",
    bad_input = "",
    storage_key = "new_password_1",
    timeout = profile.user_input_timeout,
  },
  {
    action = "get_digits",
    min_digits = profile.password_min_digits,
    max_digits = profile.password_max_digits,
    audio_files = "phrase:reenter_new_password",
    bad_input = "",
    storage_key = "new_password_2",
    timeout = profile.user_input_timeout,
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

