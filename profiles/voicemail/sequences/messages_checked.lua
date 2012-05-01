--[[
  Fire an event that messages have been checked.
]]

-- Mailbox that was checked.
mailbox = storage("login_settings", "mailbox_number")

-- Get message count, supplied to the fired event.
message_count = storage("data", "message_new_count")

return
{
  {
    action = "call_sequence",
    sequence = "sub:get_message_count " .. profile.domain .. "," .. mailbox .. ",0,new",
  },
  {
    action = "fire_event",
    event_type = "messages_checked",
    headers = {
      Mailbox = mailbox,
      Domain = profile.domain,
      ["New-Message-Count"] = message_count,
    },
  },
}

