--[[
  Main greeting for a user's mailbox.
]]

operator_extension = storage("mailbox_settings", "operator_extension")
-- Result of the check for the name greeting.
greet_exists = storage("file", "file_exists")
greet = profile.mailbox_dir .. "/greet.wav"

-- Build the default name greeting based on if the name greeting exists or
-- not.
default_greet = "phrase:default_greeting_name:" .. greet
if greet_exists == "false" then
  default_greet = "phrase:default_greeting:" .. profile.mailbox
end

-- Set up the available key presses for the caller based on the profile
-- configuration.
greeting_keys = {
  ["#"] = ":break",
}
if profile.check_messages then
  greeting_keys["*"] = "login " .. profile.mailbox .. "," .. profile.domain
end
-- If there's an available operator extension, then include it in the options
-- and pass that data along to the record sequence.
operator_on_record = ""
if operator_extension ~= "" then
  greeting_keys["0"] = "transfer_to_operator"
  operator_on_record = "operator"
end

return
{
  -- Load the mailbox settings, we'll need these for some of the message
  -- options.
  {
    action = "call_sequence",
    sequence = "sub:load_mailbox_settings " .. profile.mailbox .. "," .. profile.domain .. ",mailbox_settings",
  },
  -- Check for existence of the name greeting, which might be used in the
  -- default greeting below.
  {
    action = "file_exists",
    file = greet,
  },
  -- This action will play the first valid file it finds.  It checks, in order:
  -- temporary greeting, unavailable greeting, default greeting.
  {
    action = "play_valid_file",
    files =  {
      profile.mailbox_dir .. "/temp.wav",
      profile.mailbox_dir .. "/unavail.wav",
      default_greet,
    },
    keys = greeting_keys,
  },
  -- Register saving the message in the exit loop, in case the caller hangs up
  -- instead of explicitly saving the message.
  {
    action = "exit_sequence",
    sequence = "main_greeting_prepare_message",
  },
  {
    action = "call_sequence",
    sequence = "record_message " .. operator_on_record,
  },
}

