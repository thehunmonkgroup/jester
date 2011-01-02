-- Message data.
new_message_count = storage("messagenew", "__count")
old_message_count = storage("messageold", "__count")

current_folder = ""
messages = ""
if new_message_count > 0 then
  current_folder = "0"
  messages = "messagenew"
elseif old_message_count > 0 then
  current_folder = "1"
  messages = "messageold"
end

temp_keys = {
  ["2"] = "change_folders",
  ["0"] = "mailbox_options",
  ["*"] = "help skip_folder_announcement",
  ["#"] = "exit",
}

if current_folder ~= "" then
  temp_keys["1"] = "play_messages"
end

if profile.operator_extension ~= "" then
  temp_keys["3"] = "main_menu_advanced_options"
end

return
{
  {
    action = "set_storage",
    storage_area = "message_settings",
    data = {
      current_folder = current_folder,
    },
  },
  {
    action = "conditional",
    value = current_folder,
    compare_to = "",
    if_false = "sub:copy_new_old_messages " .. messages,
  },
  {
    action = "counter",
    storage_key = "message_number",
    increment = 1,
    reset = true,
  },
  {
    action = "exit_sequence",
    sequence = "messages_checked",
  },
  {
    action = "play_phrase",
    phrase = "announce_new_old_messages",
    phrase_arguments = new_message_count .. ":" .. old_message_count,
    keys = temp_keys,
  },
  {
    action = "call_sequence",
    sequence = "help skip_folder_announcement",
  },
}

