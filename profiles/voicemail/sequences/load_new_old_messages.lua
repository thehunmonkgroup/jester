--[[
  Initial load of new and old messages, then send to main menu.
]]

timezone = storage("mailbox_settings", "default_timezone")
default_language = storage("mailbox_settings", "default_language")

return
{
  -- Set the timezone channel variable to the mailbox's timezone, so the say
  -- applications will say date/time correctly.
  {
    action = "set_variable",
    data = {
      timezone = timezone,
      default_language = default_language,
    },
  },
  {
    action = "call_sequence",
    sequence = "sub:get_messages 0,new",
  },
  {
    action = "call_sequence",
    sequence = "sub:get_messages 1,old",
  },
  {
    action = "call_sequence",
    sequence = "main_menu",
  },
}

