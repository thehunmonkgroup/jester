--[[
  Collect and extension from the user, validate that it's a valid extension,
  then pass to the appropriate next sequence.
]]

-- Options for next sequence to call.
valid_extension_sequence = args(1)
invalid_extension_sequence = args(2)
-- Collected extension.
extension = storage("get_digits", "extension")
-- Result of the mailbox load.
loaded_mailbox = storage("mailbox_settings_message", "mailbox")

return
{
  {
    action = "get_digits",
    min_digits = profile.mailbox_min_digits,
    max_digits = profile.mailbox_max_digits,
    audio_files = "phrase:extension",
    bad_input = "",
    storage_key = "extension",
    timeout = profile.user_input_timeout,
  },
  {
    action = "call_sequence",
    sequence = "sub:load_mailbox_settings " .. extension .. "," .. profile.domain .. ",mailbox_settings_message",
  },
  {
    action = "conditional",
    value = loaded_mailbox,
    compare_to = "",
    comparison = "equal",
    if_false = valid_extension_sequence,
    if_true = "invalid_extension " .. invalid_extension_sequence,
  },
}

