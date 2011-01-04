--[[
  Incorrect login workflow when the mailbox is not provided.
]]

-- User's mailbox number input.
mailbox = storage("get_digits", "digits")

return
{
  -- Ask for the mailbox again.
  {
    action = "get_digits",
    min_digits = profile.mailbox_min_digits,
    max_digits = profile.mailbox_max_digits,
    audio_files = "phrase:login_incorrect_mailbox",
    bad_input = "",
    timeout = profile.user_input_timeout,
  },
  {
    action = "set_storage",
    storage_area = "login_settings",
    data = {
      mailbox_number = mailbox,
    },
  },
  {
    action = "call_sequence",
    sequence = "validate_mailbox_login",
  },
}

