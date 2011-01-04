--[[
  Verify that a message can be replied to.
]]

-- Message data.
message_number = storage("counter", "message_number")
-- The mailbox to save to is the caller ID of the message.
mailbox = storage("message", "caller_id_number_" .. message_number)
-- The domain to save to is stored with the original message.
domain = storage("message", "caller_domain_" .. message_number)
-- Result of the attempt to load the reply to mailbox.
loaded_mailbox = storage("mailbox_settings_message", "mailbox")

return
{
  -- Try to load the mailbox.
  {
    action = "call_sequence",
    sequence = "sub:load_mailbox_settings " .. mailbox .. "," .. domain .. ",mailbox_settings_message",
  },
  -- If it's found, trigger the reply sequence.
  {
    action = "conditional",
    value = loaded_mailbox,
    compare_to = "",
    comparison = "equal",
    if_false = "send_reply",
  },
  -- Otherwise, inform the user that they can't reply to this message.
  {
    action = "play_phrase",
    phrase = "no_mailbox",
  },
  {
    action = "call_sequence",
    sequence = "message_options",
  },
}

