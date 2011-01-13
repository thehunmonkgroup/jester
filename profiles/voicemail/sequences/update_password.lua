--[[
  Update the password for a mailbox.
]]

-- Mailbox info.
mailbox = storage("login_settings", "mailbox_number")
-- The updated password.
password = storage("get_digits", "new_password_1")

-- Have we set up this mailbox yet?
mailbox_setup_complete = storage("mailbox_settings", "mailbox_setup_complete")

return
{
  {
    action = "data_update",
    handler = "odbc",
    config = profile.db_config_mailbox,
    fields = {
      password = password,
    },
    filters = {
      domain = profile.domain,
      mailbox = mailbox,
    },
    update_type = "update",
  },
  -- Fire a 'mailbox_updated' event, passing the new password.
  {
    action = "fire_event",
    event_type = "mailbox_updated",
    headers = {
      Mailbox = mailbox,
      Domain = domain,
    },
    body = "password: " .. password,
  },
  {
    action = "play_phrase",
    phrase = "password_updated",
  },
  {
    action = "conditional",
    value = mailbox_setup_complete,
    compare_to = "no",
    comparison = "equal",
    if_false = "mailbox_options",
  },
}

