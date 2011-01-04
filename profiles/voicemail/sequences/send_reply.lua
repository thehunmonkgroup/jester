--[[
  Set up sending a reply to a message.
]]

-- Message data.
message_number = storage("counter", "message_number")
-- The mailbox to save to is the caller ID of the message.
mailbox = storage("message", "caller_id_number_" .. message_number)
-- The domain to save to is stored with the original message.
domain = storage("message", "caller_domain_" .. message_number)

return
{
  -- Set up the reply information for other sequences to use.
  {
    action = "set_storage",
    storage_area = "send_reply_info",
    data = {
      mailbox = mailbox,
      domain = domain,
    },
  },
  {
    action = "play_phrase",
    phrase = "default_greeting",
    keys = {
      ["#"] = ":break",
    },
  },
  -- Register sequence in the exit loop to save the message in case the caller
  -- doesn't explicitly save it.
  {
    action = "exit_sequence",
    sequence = "send_reply_prepare_message",
  },
  {
    action = "call_sequence",
    sequence = "record_message",
  },
}

