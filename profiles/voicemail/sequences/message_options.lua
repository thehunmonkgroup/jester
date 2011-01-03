-- Message data.
message_number = storage("counter", "message_number")
deleted = storage("message", "deleted_" .. message_number)
total_messages = storage("message", "__count")
prev_message = ""
next_message = ""
delete_undelete_message = "delete"

announcements = {
  ["3"] = "advanced_options",
  ["5"] = "repeat_message",
  ["7"] = "delete_message",
  ["8"] = "forward_message",
  ["9"] = "save_message",
  ["*"] = "help_exit",
  -- The # key is not included here because the helpexit audio file contains
  -- both announcements -- so we just announce the * key.
}


if total_messages > 1 then
  if message_number > 1 then
    announcements["4"] = "prev_message"
  end
  if message_number < total_messages then
    announcements["6"] = "next_message"
  end
end

if deleted == "1" then
  announcements["7"] = "undelete_message"
end

return
{
  {
    action = "play_keys",
    key_announcements = announcements,
    keys = {
      ["2"] = "top:change_folders",
      ["3"] = "top:advanced_options",
      ["4"] = "top:prev_message",
      ["5"] = "top:repeat_message",
      ["6"] = "top:next_message",
      ["7"] = "top:delete_undelete_message",
      ["8"] = "top:forward_message_menu",
      ["9"] = "top:save_message",
      ["*"] = "top:help",
      ["#"] = "top:exit",
    },
    order = {
      "4",
      "3",
      "5",
      "6",
      "7",
      "8",
      "9",
      "*",
    },
    repetitions = profile.menu_repititions,
    wait = profile.menu_replay_wait,
  },
  {
    action = "call_sequence",
    sequence = "top:exit",
  },
}

