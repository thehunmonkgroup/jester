return
{
  {
    action = "counter",
    storage_key = "failed_login_counter",
    increment = 1,
    compare_to = 3,
    if_equal = "mailbox_login_failed",
  },
  {
    action = "conditional",
    value = storage("custom", "login_type"),
    compare_to = "have_mailbox",
    comparison = "equal",
    if_true = "mailbox_login_incorrect_have_mailbox",
    if_false = "mailbox_login_incorrect_missing_mailbox",
  },
}
