--[[
  Prepares a recorded message from the main greeting for saving.
]]

-- Message data.
caller_id_number = variable("caller_id_number")
caller_id_name = variable("caller_id_name")
timestamp = storage("record", "last_recording_timestamp")
duration = storage("record", "last_recording_duration")
recording_name = storage("record", "last_recording_name")

return
{
  {
    action = "set_storage",
    storage_area = "message_info",
    data = {
      mailbox = profile.mailbox,
      domain = profile.domain,
      caller_id_number = caller_id_number,
      caller_id_name = caller_id_name,
      caller_domain = profile.caller_domain,
      timestamp = timestamp,
      duration = duration,
      recording_name = recording_name,
    },
  },
  {
    action = "call_sequence",
    sequence = "check_for_recorded_message",
  },
}

