--[[
  Play message and all message-related annoucements for a message.
]]

-- Message data.
message_count = storage("message", "__count")

return
{
  {
    action = "call_sequence",
    sequence = "sub:play_message_number",
  },
  {
    action = "call_sequence",
    sequence = "sub:play_cid_envelope",
  },
  {
    action = "call_sequence",
    sequence = "sub:play_message",
  },
  --[[
  --This section may be used later for auto-advancing messages.
  {
    action = "counter",
    storage_key = "message_number",
    increment = 1,
  },
  {
    action = "call_sequence",
    sequence = "play_messages",
  },
  ]]
}
