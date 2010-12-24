-- Message data.
message_number = storage("counter", "message_number")
deleted_key = "deleted_" .. message_number
deleted = storage("message", deleted_key)

-- Flip the state.
if deleted == "0" then
  deleted = "1"
else
  deleted = "0"
end

return
{
  {
    action = "call_sequence",
    sequence = "sub:update_message_deleted " .. deleted,
  },
  -- Update the local reference so it can be checked again for reversal in the
  -- same session.
  {
    action = "set_storage",
    storage_area = "message",
    data = {
      [deleted_key] = deleted,
    },
  },
  {
    action = "call_sequence",
    sequence = "message_deleted_undeleted",
  },
}

