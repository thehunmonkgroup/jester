-- Message data.
message_number = storage("counter", "message_number")
deleted = storage("message", "deleted_" .. message_number)

return
{
  {
    action = "play_phrase",
    phrase = "message_deleted_undeleted",
    phrase_arguments = deleted,
    keys = {
      ["2"] = "change_folders",
      ["3"] = "advanced_options",
      ["4"] = "prev_message",
      ["5"] = "repeat_message",
      ["6"] = "next_message",
      ["7"] = "delete_undelete_message",
      ["8"] = "forward_message",
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

