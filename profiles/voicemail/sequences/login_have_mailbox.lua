return
{
  {
    action = "add_to_stack",
  },
  {
    action = "set_storage",
    data = {
      mailbox_number = variable("voicemail_mailbox"),
      login_type = "have_mailbox",
    },
  },
  {
    action = "call_sequence",
    sequence = "validate_mailbox_login",
  },
}

