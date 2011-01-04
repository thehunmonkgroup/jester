--[[
  Say goodby and hang up the call.
]]

return
{
  {
    action = "play_phrase",
    phrase = "goodbye"
  },
  {
    action = "hangup",
  },
}

