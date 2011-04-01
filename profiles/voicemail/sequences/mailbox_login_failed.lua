--[[
  Login failed, notify user and hang up.
]]

return
{
  {
    action = "play_phrase",
    phrase = "login_incorrect",
  },
  {
    action = "call_sequence",
    sequence = "exit",
  },
}

