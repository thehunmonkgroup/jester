-- Message data.
mailbox = storage("message_info", "mailbox")
recording_name = storage("message_info", "recording_name")
timestamp = storage("message_info", "timestamp")
caller_id_number = storage("message_info", "caller_id_number")
caller_id_name = storage("message_info", "caller_id_name")

-- Mailbox settings.
email = storage("mailbox_settings_message", "email")
timezone = storage("mailbox_settings_message", "timezone")

-- Formatted date.
formatted_date = storage("format", "formatted_date")

return
{
  {
    action = "format_date",
    storage_key = "formatted_date",
    timestamp = timestamp,
    timezone = timezone,
    format = profile.email_date_format,
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
    subject = profile.email_subject,
    message = profile.email_message,
    from = profile.email_from_address,
    to = email,
    server = profile.email_server,
    port = profile.email_port,
    tokens = {
      mailbox = mailbox,
      datetime = formatted_date,
      caller_id_number = caller_id_number,
      caller_id_name = caller_id_name,
    },
  },
}
