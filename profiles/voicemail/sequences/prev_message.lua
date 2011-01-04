--[[
  Checks for previous message, and sets up playback for it if necessary.
]]

-- Message data.
message_number = storage("counter", "message_number")

return
{
  -- If we're already on the first message, send to the 'no more messages'
  -- sequence.
  {
    action = "conditional",
    value = message_number,
    compare_to = 1,
    if_true = "no_more_messages message_options",
  },
  -- Otherwise, decrement the message counter and play the message.
  {
    action = "counter",
    storage_key = "message_number",
    increment = -1,
  },
  {
    action = "call_sequence",
    sequence = "play_messages",
  },
}

