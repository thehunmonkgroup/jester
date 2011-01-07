--[[
  Determines where to send the call after a mailbox command.
]]

-- Setting for where to go after a command.
next_after_command = storage("mailbox_settings", "next_after_command")

return
{
  {
    action = "conditional",
    value = next_after_command,
    compare_to = "yes",
    if_true = "next_message",
    if_false = "message_options",
  },
}

