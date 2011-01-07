--[[
  Transfer to the operator extension.
]]

operator_extension = storage("mailbox_settings", "operator_extension")

return
{
  {
    action = "play_phrase",
    phrase = "transfer_announcement",
  },
  {
    action = "transfer",
    extension = operator_extension,
  },
}
