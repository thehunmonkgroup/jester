--[[
  Set up a message for forwarding, optionally recording a custom message to
  prepend to it.
]]

-- Whether to prepend a message or not.
prepend_message = args(1)

-- Message data.
message_number = storage("counter", "message_number")
recording_name = storage("message", "recording_" .. message_number)
timestamp = storage("message", "timestamp_" .. message_number)
duration = storage("message", "duration_" .. message_number)
caller_id_name = storage("message", "caller_id_name_" .. message_number)
caller_id_number = storage("message", "caller_id_number_" .. message_number)
caller_domain = storage("message", "caller_domain_" .. message_number)

-- The extension to forward to.
mailbox = storage("get_digits", "extension")

return
{
  -- Copy the message to the temp recording area.
  {
    action = "move_file",
    source = profile.mailbox_dir .. "/" .. recording_name,
    destination = profile.temp_recording_dir .. "/" .. recording_name,
    copy = true,
  },
  -- Call the prepend sequence if necessary.
  {
    action = "conditional",
    value = prepend_message,
    compare_to = "prepend",
    comparison = "equal",
    if_true = "sub:forward_message_prepend",
  },
  -- Fake the last recording name here so the standard message saving
  -- sequences can be used.
  {
    action = "set_storage",
    storage_area = "record",
    data = {
      last_recording_name = recording_name,
    },
  },
  -- Set up the message info for saving.
  {
    action = "set_storage",
    storage_area = "message_info",
    data = {
      mailbox = mailbox,
      domain = profile.domain,
      caller_id_number = caller_id_number,
      caller_id_name = caller_id_name,
      caller_domain = caller_domain,
      recording_name = recording_name,
      timestamp = timestamp,
      duration = duration,
    },
  },
  -- The standard message saving sequences can be used to save the message.
  {
    action = "call_sequence",
    sequence = "sub:save_individual_message"
  },
  {
    action = "play_phrase",
    phrase = "thank_you",
  },
  {
    action = "play_phrase",
    phrase = "greeting_saved",
  },
  {
    action = "call_sequence",
    sequence = "message_options"
  },
}

