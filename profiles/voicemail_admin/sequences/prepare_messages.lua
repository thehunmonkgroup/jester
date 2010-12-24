return
{
  {
    action = "call_sequence",
    sequence = "sub:get_messages " .. args(1),
  },
  {
    action = "set_storage",
    storage_area = "message_settings",
    data = {
      current_folder = args(1),
    },
  },
  {
    action = "counter",
    storage_key = "message_number",
    increment = 1,
    reset = true,
  },
}

