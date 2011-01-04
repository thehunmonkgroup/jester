--[[
  Incorrect login workflow when the mailbox was provided.
]]

return
{
  {
    action = "play_phrase",
    phrase = "login_incorrect",
  },
  -- Top of the stack will permit another login attempt.
  {
    action = "navigation_top",
  },
}

