--[[
  Set up for re-recording a message.
]]

operator_extension = storage("mailbox_settings", "operator_extension")

greeting_keys = {
  ["#"] = ":break",
}

-- If an operator extension is allowed on record, then add that to the menu
-- options, and pass that data along to the record sequence.
operator_on_record = ""
if operator_extension ~= "" then
  greeting_keys["0"] = "transfer_to_operator"
  operator_on_record = "operator"
end

return
{
  -- Get rid of the old recording first so it's not saved if the caller hangs
  -- up here.
  {
    action = "call_sequence",
    sequence = "sub:cleanup_temp_recording",
  },
  {
    action = "play_phrase",
    phrase = "default_greeting",
    keys = greeting_keys,
  },
  {
    action = "call_sequence",
    sequence = "record_message " .. operator_on_record,
  },
}

