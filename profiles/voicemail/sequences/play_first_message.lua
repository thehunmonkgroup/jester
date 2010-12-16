return
{
  {
    action = "counter",
    storage_key = "message_number",
    reset = true,
    increment = 1,
  },
  {
    action = "call_sequence",
    sequence = "play_messages",
  },
}

