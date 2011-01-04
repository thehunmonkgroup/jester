--[[
  Login workflow when a mailbox is not provided.
]]

-- The user entered mailbox.
mailbox = storage("get_digits", "digits")

return
{
  {
    action = "get_digits",
    min_digits = profile.mailbox_min_digits,
    max_digits = profile.mailbox_max_digits,
    audio_files = "phrase:get_mailbox_number",
    bad_input = "",
    timeout = profile.user_input_timeout,
  },
  {
    action = "set_storage",
    storage_area = "login_settings",
    data = {
      mailbox_number = mailbox,
      login_type = "missing_mailbox",
    },
  },
  {
    action = "call_sequence",
    sequence = "validate_mailbox_login",
  },
}

