-- Message data.
message_number = storage("counter", "message_number")
recording_name = storage("message", "recording_" .. message_number)
timestamp = storage("message", "timestamp_" .. message_number)
duration = storage("message", "duration_" .. message_number)
caller_id_name = storage("message", "caller_id_name_" .. message_number)
caller_id_number = storage("message", "caller_id_number_" .. message_number)
caller_domain = storage("message", "caller_domain_" .. message_number)
prepend_recording_name = storage("record", "last_recording_name")
temp_recording = profile.temp_recording_dir .. "/" .. recording_name
prepend_recording = profile.temp_recording_dir .. "/" .. prepend_recording_name

mailbox = storage("get_digits", "extension")

return
{
  {
    action = "move_file",
    source = profile.mailbox_dir .. "/" .. recording_name,
    destination = temp_recording,
    copy = true,
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
    action = "record_merge",
    base_file = temp_recording,
    merge_file = prepend_recording,
    merge_type = "prepend",
  },
  -- Fake the last recording name here so the standard message saving
  -- sequences can be used.
  {
    action = "set_storage",
    storage_area = "record",
    data = {
      last_recording_name = recording_name,
      last_recording_timestamp = timestamp,
      last_recording_duration = duration,
    },
  },
  {
    action = "set_storage",
    storage_area = "message_info",
    data = {
      caller_id_number = caller_id_number,
      caller_id_name = caller_id_name,
      caller_domain = caller_domain,
    },
  },
  -- Fake a message group with the forwarding mailbox as the only member so
  -- standard message saving sequences can be used.
  {
    action = "clear_storage",
    storage_area = "voicemail_group",
  },
  {
    action = "set_storage",
    storage_area = "voicemail_group",
    data = {
      __count = 1,
      mailbox_1 = mailbox,
      domain_1 = profile.domain,
    },
  },
  {
    action = "call_sequence",
    sequence = "sub:save_group_message"
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

