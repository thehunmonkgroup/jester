--[[
  Main greeting for a user's mailbox.
]]

operator_extension = storage("mailbox_settings", "operator_extension")

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
  -- This action will play the first valid file it finds.  It checks, in order:
  -- temporary greeting, unavailable greeting, default greeting.
  {
    action = "play_valid_file",
    files =  {
      profile.mailbox_dir .. "/temp.wav",
      profile.mailbox_dir .. "/unavail.wav",
      "phrase:default_greeting:" .. profile.mailbox,
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

