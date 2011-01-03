--[[
  Set the outside number to call to the extension that left the message.
]]

-- Message data.
message_number = storage("counter", "message_number")
caller_id_number = storage("message", "caller_id_number_" .. message_number)

return
{
  -- The call_outside_number sequence looks here for the number, so set it
  -- explicitly.
  {
    action = "set_storage",
    storage_area = "get_digits",
    data = {
      call_outside_number = caller_id_number,
    },
  },
  {
    action = "call_sequence",
    sequence = "call_outside_number message_options",
  },
}
