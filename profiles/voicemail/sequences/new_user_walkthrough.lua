--[[
   Walkthrough for new users.
   Prompt them to change their password and record their greet file.
]]

mailbox = storage("login_settings", "mailbox_number")

return
{
  {
    action = "play_phrase",
    phrase = "mailbox_setup",
  },
  {
    action = "call_sequence",
    sequence = "sub:change_password",
  },
  {
    action = "call_sequence",
    sequence = "sub:record_greeting greet",
  },
  -- Update the user's mailbox_setup_complete flag.
  {
    action = "call_sequence",
    sequence = "sub:mailbox_setup " .. mailbox .. "," .. profile.domain,
  },
  -- Reload the mailbox settings.
  {
    action = "call_sequence",
    sequence = "sub:load_mailbox_settings " .. mailbox .. "," .. profile.domain .. ",mailbox_settings",
  },
  {
    action = "call_sequence",
    sequence = "load_new_old_messages",
  },
}
