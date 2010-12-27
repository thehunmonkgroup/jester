recording = storage("record", "last_recording_name")

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

