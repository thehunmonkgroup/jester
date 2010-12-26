mailbox = args(1)

return
{
  {
    action = "add_to_stack",
  },
  {
    action = "set_storage",
    storage_area = "login_settings",
    data = {
      mailbox_number = mailbox,
      login_type = "have_mailbox",
    },
  },
  {
    action = "call_sequence",
    sequence = "validate_mailbox_login",
  },
}

