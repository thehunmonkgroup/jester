--[[
  Prepare messages in a folder for playing.
]]

-- The folder to prepare.
folder = args(1)

return
{
  -- Load the messages.
  {
    action = "call_sequence",
    sequence = "sub:get_messages " .. folder,
  },
  -- Set the active folder.
  {
    action = "set_storage",
    storage_area = "message_settings",
    data = {
      current_folder = folder,
    },
  },
  -- Reset the message counter.
  {
    action = "counter",
    storage_key = "message_number",
    increment = 1,
    reset = true,
  },
}

