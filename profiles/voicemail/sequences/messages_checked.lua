--[[
  Fire an event that messages have been checked.
]]

-- Mailbox that was checked.
mailbox = storage("login_settings", "mailbox_number")

return
{
  {
    action = "fire_event",
    event_type = "messages_checked",
    headers = {
      Mailbox = mailbox,
      Domain = profile.domain,
    },
  },
}

