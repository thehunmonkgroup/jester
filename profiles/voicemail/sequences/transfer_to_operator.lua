--[[
  Transfer to the operator extension.
]]

return
{
  {
    action = "play_phrase",
    phrase = "transfer_announcement",
  },
  {
    action = "transfer",
    extension = profile.operator_extension,
  },
}
