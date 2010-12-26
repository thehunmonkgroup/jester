-- Message data.
message_number = storage("counter", "message_number")
message_count = storage("message", "__count")

return
{
  {
    action = "conditional",
    value = message_number,
    compare_to = message_count,
    if_true = "no_more_messages message_options",
  },
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

