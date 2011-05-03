--[[
  Records a sound file, then converts the speech to text -- with console
  debugging on the result will be printed to the console.

  The recording is limited to 10 seconds.
]]

file_to_translate = "speech_to_text_demo.wav"

-- Set up initial recording keys.
record_keys = {
  ["#"] = ":break",
}

return
{
  {
    action = "wait",
    milliseconds = 500,
  },
  {
    action = "record",
    location = profile.temp_recording_dir,
    filename = file_to_translate,
    pre_record_sound = "phrase:beep",
    max_length = 10,
    silence_secs = 2,
    keys = record_keys,
  },
  {
    action = "play_phrase",
    phrase = "thank_you",
    keys = record_keys,
  },
  {
    action = "speech_to_text_from_file",
    filepath = profile.temp_recording_dir .. "/" .. file_to_translate,
  },
}

