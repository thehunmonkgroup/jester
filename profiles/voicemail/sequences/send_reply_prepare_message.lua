--[[
  Prepare a message reply for saving.
]]

-- Message data.
mailbox = storage("send_reply_info", "mailbox")
domain = storage("send_reply_info", "domain")
timestamp = storage("record", "last_recording_timestamp")
duration = storage("record", "last_recording_duration")
recording_name = storage("record", "last_recording_name")

return
{
  {
    action = "set_storage",
    storage_area = "message_info",
    data = {
      mailbox = mailbox,
      domain = domain,
      caller_id_number = profile.mailbox,
      -- TODO: Comedian mail doesn't CID name for replies, but perhaps
      -- there's a way it can be done on FreeSWITCH?
      caller_id_name = "",
      caller_domain = profile.domain,
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

