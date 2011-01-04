--[[
  Removes message files that have been deleted from the database.
]]

-- Total number of files to remove.
total_files = storage("message_files_to_remove", "__count")
-- Which file we're currently on.
file_count = storage("counter", "file_row")
-- File info for the current file.
mailbox = storage("message_files_to_remove", "mailbox_" .. file_count)
domain = storage("message_files_to_remove", "domain_" .. file_count)
recording = storage("message_files_to_remove", "recording_" .. file_count)
file_to_remove = profile.voicemail_dir .. "/" .. domain .. "/" .. mailbox .. "/" .. recording

return
{
  -- Increment the group counter by one.  If we're past the total files,
  -- then exit.
  {
    action = "counter",
    increment = 1,
    storage_key = "file_row",
    compare_to = total_files,
    if_greater = "exit",
  },
  {
    action = "delete_file",
    file = file_to_remove,
  },
  -- Call the sequence again to trigger the next file deletion.
  {
    action = "call_sequence",
    sequence = "remove_deleted_message_files",
  },
}

