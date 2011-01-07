--[[
  Set the number to call to the extension that left the message.
]]

-- Message data.
message_number = storage("counter", "message_number")
caller_id_number = storage("message", "caller_id_number_" .. message_number)

callback_extension = storage("mailbox_settings", "callback_extension")

return
{
  -- The outdial sequence looks here for the number, so set it explicitly.
  {
    action = "set_storage",
    storage_area = "get_digits",
    data = {
      outdial_number = caller_id_number,
    },
  },
  {
    action = "call_sequence",
    sequence = "outdial " .. callback_extension .. ",message_options",
  },
}
