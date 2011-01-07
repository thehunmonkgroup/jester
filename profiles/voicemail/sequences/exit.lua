--[[
  Say goodbye and exit voicemail.
]]

-- How are we exiting?
exit_type = args(1)
exit_extension = storage("mailbox_settings", "exit_extension")

-- Build the exit action based on how we should exit.
if exit_type == "exit_extension" and exit_extension ~= "" then
  exit = {
    action = "transfer",
    extension = exit_extension,
  }
else
  exit = {
    action = "hangup",
  }
end

return
{
  {
    action = "play_phrase",
    phrase = "goodbye"
  },
  exit,
}

