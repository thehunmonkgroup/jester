--[[
  Clean up a temporary recording.
]]

recording = storage("record", "last_recording_name")

-- If no recording exists, we don't want to call the delete function, because
-- it could erroneously try to delete the containing directory, so build the
-- final action based on this.
if recording ~= "" then
  action = {
    action = "delete_file",
    file = profile.temp_recording_dir .. "/" .. recording,
  }
else
  action = {
    action = "none",
  }
end

return
{
  action,
}

