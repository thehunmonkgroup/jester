--[[
  Play the message number.
]]

-- Message data.
message_number = storage("counter", "message_number")
message_count = storage("message", "__count")

-- Use the profile setting if there's only one total message.
if message_count == 1 then
  location = profile.single_message_announcement
else
  -- Check if we're on the first or last message in the folder, and use first
  -- and last announcements if necessary, otherwise use the message number.
  if message_number == 1 then
    location = "first"
  elseif message_number == message_count then
    location = "last"
  else
    location = message_number
  end
end

return
{
  {
    action = "play_phrase",
    phrase = "message_number",
    phrase_arguments = location,
    keys = {
      ["1"] = "top:play_message",
      ["2"] = "top:change_folders",
      ["3"] = "top:advanced_options",
      ["4"] = "top:prev_message",
      ["5"] = "top:repeat_message",
      ["6"] = "top:next_message",
      ["7"] = "top:delete_undelete_message",
      ["8"] = "top:forward_message_menu",
      ["9"] = "top:save_message",
      ["*"] = "help",
      ["#"] = "exit",
    },
  },
}

