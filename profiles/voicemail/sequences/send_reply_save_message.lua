--[[
  Clean up and redirect after saving a message reply.
]]

return
{
  -- Explicitly clear this so the manual message saving sequence can always
  -- accurately know if a reply is being saved or not.
  {
    action = "clear_storage",
    storage_area = "send_reply_info",
  },
  {
    action = "call_sequence",
    sequence = "message_options",
  },
}
