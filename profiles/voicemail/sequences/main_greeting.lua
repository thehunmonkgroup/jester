greeting_keys = {
  ["#"] = ":break",
}

if profile.check_messages then
  greeting_keys["*"] = "login " .. profile.mailbox .. "," .. profile.context
end

if profile.operator_extension then
  greeting_keys["0"] = "transfer_to_operator"
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
    action = "call_sequence",
    sequence = "record_message",
  },
}

