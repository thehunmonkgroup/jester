mailbox = storage("login_settings", "mailbox_number")
password = storage("mailbox_settings", "password")
entered_password = storage("get_digits", "password")

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
    action = "call_sequence",
    sequence = "sub:load_mailbox_settings " .. mailbox .. "," .. profile.domain .. ",mailbox_settings",
  },
  {
    action = "conditional",
    value = entered_password,
    compare_to = "",
    comparison = "equal",
    if_true = "exit",
  },
  {
    action = "conditional",
    value = password,
    compare_to = entered_password,
    comparison = "equal",
    if_true = "load_new_old_messages",
    if_false = "mailbox_login_incorrect",
  },
}

