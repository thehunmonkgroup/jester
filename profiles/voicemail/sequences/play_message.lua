mailbox = storage("default", "mailbox_number")
mailbox_directory = profile.voicemail_dir .. "/" .. profile.context .. "/" .. profile.domain .. "/" .. mailbox

-- Message data.
message_number = storage("counter", "message_number")
recording_name = storage("message", "recording_" .. message_number)

-- Folder data.
current_folder = storage("default", "current_folder")

return
{
  {
    action = "conditional",
    value = current_folder,
    compare_to = "0",
    if_true = "sub:update_message_folder 1"
  },
  {
    action = "play",
    file = mailbox_directory .. "/" .. recording_name,
    keys = {
      ["1"] = "top:play_first_message",
      ["2"] = ":seek:0",
      ["3"] = "top:advanced_options",
      ["4"] = "top:prev_message",
      ["5"] = "top:repeat_message",
      ["6"] = "top:next_message",
      ["7"] = "top:delete_undelete_message",
      ["8"] = "top:forward_message",
      ["9"] = "top:save_message",
      ["0"] = ":pause",
      ["*"] = ":seek:-5000",
      ["#"] = ":seek:+1500",
    },
  },
  {
    action = "call_sequence",
    sequence = "sub:message_options",
  },
}

