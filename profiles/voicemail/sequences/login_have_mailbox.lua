mailbox = args(1)
login_without_password = variable("voicemail_login_without_password")

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
    action = "conditional",
    value = login_without_password,
    compare_to = "",
    comparison = "equal",
    if_true = "validate_mailbox_login",
    if_false = "login_without_password",
  },
}

