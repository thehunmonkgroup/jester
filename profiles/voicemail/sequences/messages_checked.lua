mailbox = storage("login_settings", "mailbox_number")

return
{
  {
    action = "fire_event",
    event_type = "messages_checked",
    headers = {
      Mailbox = mailbox,
      Domain = profile.domain,
    },
  },
}

