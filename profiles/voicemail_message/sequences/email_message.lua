mailbox = args(1)
caller_id_name = variable("caller_id_name")
caller_id_number = variable("caller_id_number")
recording_name = storage("record", "last_recording_name")
timestamp = storage("record", "last_recording_timestamp")
email = storage("mailbox_settings_message", "email")
timezone = storage("mailbox_settings_message", "timezone")
formatted_date = storage("format", "formatted_date")

return
{
  {
    action = "format_date",
    storage_key = "formatted_date",
    timestamp = timestamp,
    timezone = timezone,
  },
  {
    action = "email",
    attachments = {
      {
        filetype = "audio/x-wav",
        filename = "message.wav",
        filepath = profile.temp_recording_dir .. "/" .. recording_name,
      }
    },
    message = [[
Mailbox number: :mailbox
Date/time: :datetime
CallerID number: :caller_id_number
CallerID name: :caller_id_name]],
    subject = "New voicemail message for :mailbox",
    to = email,
    tokens = {
      mailbox = mailbox,
      datetime = formatted_date,
      caller_id_number = caller_id_number,
      caller_id_name = caller_id_name,
    },
  },
}
