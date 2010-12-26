greeting_keys = {
  ["#"] = ":break",
}

if profile.check_messages then
  greeting_keys["*"] = "login " .. profile.mailbox .. "," .. profile.context
end

return
{
  {
    action = "create_directory",
    directory = profile.mailbox_dir,
  },
  {
    action = "play_valid_file",
    files =  {
      profile.mailbox_dir .. "/temp.wav",
      profile.mailbox_dir .. "/unavail.wav",
      "phrase:default_greeting:" .. profile.mailbox,
    },
    keys = greeting_keys,
  },
  {
    action = "exit_sequence",
    sequence = "check_for_recorded_message",
  },
  {
    action = "wait",
    milliseconds = 500,
  },
  {
    action = "record",
    location = profile.temp_recording_dir,
    pre_record_sound = "phrase:beep",
    keys = {
      ["#"] = ":break",
    },
  },
  {
    action = "wait",
    milliseconds = 1000,
  },
  {
    action = "play_phrase",
    phrase = "goodbye",
  },
}
