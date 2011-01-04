--[[
  Workflow for going to the next message in a folder.
]]

-- Message data.
message_number = storage("counter", "message_number")
message_count = storage("message", "__count")

return
{
  -- If we're on the last message, run no more messages sequence.
  {
    action = "conditional",
    value = message_number,
    compare_to = message_count,
    if_true = "no_more_messages message_options",
  },
  -- Otherwise, increment the message counter and send back to the message
  -- playing sequence.
  {
    action = "counter",
    storage_key = "message_number",
    increment = 1,
  },
  {
    action = "call_sequence",
    sequence = "play_messages",
  },
}

