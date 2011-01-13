--[[
  Collect a new password twice, validate they match, and call the update
  sequence as appropriate.
]]

password_1 = storage("get_digits", "new_password_1")
password_2 = storage("get_digits", "new_password_2")

-- Have we set up this mailbox yet?
mailbox_setup_complete = storage("mailbox_settings", "mailbox_setup_complete")

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
  -- If we're still in mailbox setup and we've made it this far, then re-try.
  {
    action = "conditional",
    value = mailbox_setup_complete,
    compare_to = "yes",
    comparison = "equal",
    if_true = "mailbox_options",
    if_false = "change_password",
  },
}

