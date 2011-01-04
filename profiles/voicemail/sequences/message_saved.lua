--[[
  Play a message saved announcement.
]]

-- The folder the new message was saved to.
folder = args(1)
-- The message number that's being saved.
message_number = storage("counter", "message_number")

return
{
  {
    action = "play_phrase",
    phrase = "message_saved",
    phrase_arguments = message_number .. ":" .. folder,
    keys = {
      ["2"] = "change_folders",
      ["3"] = "advanced_options",
      ["4"] = "prev_message",
      ["5"] = "repeat_message",
      ["6"] = "next_message",
      ["7"] = "delete_undelete_message",
      ["8"] = "forward_message_menu",
      ["9"] = "save_message",
      ["*"] = "help",
      ["#"] = "exit",
    },
  },
  {
    action = "call_sequence",
    sequence = "message_options",
  },
}

