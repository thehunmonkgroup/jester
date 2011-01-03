-- Message data.
total_messages = storage("message", "__count")

-- Folder data.
current_folder = storage("message_settings", "current_folder")

temp_keys = {
  ["2"] = "change_folders",
  ["3"] = "advanced_options",
  ["0"] = "mailbox_options",
  ["*"] = "help",
  ["#"] = "exit",
}

-- total_messages may still be empty here, and Lua will complain about
-- comparing a string to a number, so guard against it.
if total_messages ~= "" and total_messages > 0 then
  temp_keys["1"] = "play_messages"
end

-- Overide option for not playing the folder announcement -- used when first
-- logging in to smooth the workflow.
if total_messages == "" or args(1) == "skip_folder_announcement" then
  announcement = "skip"
else
  announcement = current_folder
end

return
{
  keys = temp_keys,
  {
    action = "play_phrase",
    phrase = "announce_folder",
    phrase_arguments = announcement,
  },
  {
    action = "play_phrase",
    phrase = "help",
    phrase_arguments = total_messages .. ":" .. current_folder,
    repetitions = profile.menu_repititions,
    wait = profile.menu_replay_wait,
  },
}

