folder = args(1)

return
{
  {
    action = "call_sequence",
    sequence = "sub:get_messages " .. folder,
  },
  {
    action = "set_storage",
    storage_area = "message_settings",
    data = {
      current_folder = folder,
    },
  },
  {
    action = "counter",
    storage_key = "message_number",
    increment = 1,
    reset = true,
  },
}

