--[[
  Copy loaded new or old message data to the message storage area.
  We already have the message data loaded, and it saves another hit to the
  expensive data_load action.
]]

-- Which set of message data to copy.
storage_area = args(1)

return
{
  {
    action = "copy_storage",
    storage_area = storage_area,
    copy_to = "message",
  },
}
