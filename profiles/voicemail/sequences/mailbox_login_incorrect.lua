--[[
  Bookkeeping/redirection for failed login attempts.
]]

-- The type of login that failed (mailbox/no mailbox).
login_type = storage("login_settings", "login_type")

return
{
  -- Keep track of how many login attempts have happened, and disconnect the
  -- user after 3 failures.
  {
    action = "counter",
    storage_key = "failed_login_counter",
    increment = 1,
    compare_to = 3,
    if_equal = "mailbox_login_failed",
  },
  -- Redirect to the appropriate incorrect login workflow based on the login
  -- type.
  {
    action = "conditional",
    value = login_type,
    compare_to = "have_mailbox",
    comparison = "equal",
    if_true = "mailbox_login_incorrect_have_mailbox",
    if_false = "mailbox_login_incorrect_missing_mailbox",
  },
}
