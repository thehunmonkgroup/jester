--[[
  Play the main menu to the caller.
]]

-- Message data.
new_message_count = storage("messagenew", "__count")
old_message_count = storage("messageold", "__count")

-- Determine which folder will be selected by default.
current_folder = ""
messages = ""
if new_message_count > 0 then
  current_folder = "0"
  messages = "messagenew"
elseif old_message_count > 0 then
  current_folder = "1"
  messages = "messageold"
end

-- Set up the initial key press options.
main_menu_keys = {
  ["2"] = "change_folders",
  ["0"] = "mailbox_options",
  ["*"] = "help skip_folder_announcement",
  ["#"] = "exit",
}

-- New or old messages exist, so provide a play option.
if current_folder ~= "" then
  main_menu_keys["1"] = "play_messages"
end

-- Operator outdial is enabled, so provide access to the advanced options from
-- the main menu.
if profile.operator_extension ~= "" then
  main_menu_keys["3"] = "main_menu_advanced_options"
end

return
{
  -- Store the current folder -- it remains the same until the user changes it.
  {
    action = "set_storage",
    storage_area = "message_settings",
    data = {
      current_folder = current_folder,
    },
  },
  -- If new or old messages exist, copy whichever was selected as the default
  -- into the message storage area.
  {
    action = "conditional",
    value = current_folder,
    compare_to = "",
    if_false = "sub:copy_new_old_messages " .. messages,
  },
  -- Start the message counter on the first message.
  {
    action = "counter",
    storage_key = "message_number",
    increment = 1,
    reset = true,
  },
  -- Register an exit sequence for firing the 'messages_checked' event.
  {
    action = "exit_sequence",
    sequence = "messages_checked",
  },
  -- Announce new/old messages.
  {
    action = "play_phrase",
    phrase = "announce_new_old_messages",
    phrase_arguments = new_message_count .. ":" .. old_message_count,
    keys = main_menu_keys,
  },
  -- Send the user to help.
  {
    action = "call_sequence",
    sequence = "help skip_folder_announcement",
  },
}

