--[[
  Validate a login attempt to a mailbox.
]]

uuid = storage("channel", "uuid")

-- Mailbox info.
mailbox = storage("login_settings", "mailbox_number")
password = storage("mailbox_settings", "password")
-- The user entered password.
entered_password = storage("get_digits", "password")

-- Have we set up this mailbox yet?
mailbox_setup_complete = storage("mailbox_settings", "mailbox_setup_complete")

return
{
  -- Load the mailbox for the user.
  {
    action = "call_sequence",
    sequence = "sub:load_mailbox_settings " .. mailbox .. "," .. profile.domain .. ",mailbox_settings",
  },
  -- Clear the DTMF queue before collecting the password, in case a stray
  -- terminator key was pressed when entering the mailbox number.
  {
    action = "api_command",
    command = "uuid_flush_dtmf " .. uuid,
  },
  -- Get a password from the user.  Use the correct password to set the
  -- max_digit parameter -- smoothes user experience.
  {
    action = "get_digits",
    audio_files = "phrase:get_password",
    bad_input = "",
    max_digits = ":" .. password,
    storage_key = "password",
    timeout = profile.user_input_timeout,
  },
  -- No entered password is a fail.
  {
    action = "conditional",
    value = entered_password,
    compare_to = "",
    comparison = "equal",
    if_true = "exit",
  },
  -- Check for password match, fail if incorrect.
  {
    action = "conditional",
    value = password,
    compare_to = entered_password,
    comparison = "equal",
    if_false = "mailbox_login_incorrect",
  },
  -- Check for new user condition and redirect as appropriate.
  {
    action = "conditional",
    value = mailbox_setup_complete,
    compare_to = "yes",
    comparison = "equal",
    if_true = "load_new_old_messages",
    if_false = "new_user_walkthrough",
  },
}

