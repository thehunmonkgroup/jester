return
{
  {
    action = "set_variable",
    data = {
      voicemail_mailbox = profile.mailbox,
      voicemail_context = profile.context,
    },
  },
  {
    action = "load_profile",
    profile = "voicemail_admin",
    sequence = "login_have_mailbox",
  },
}

