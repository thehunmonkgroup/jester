--[[
  Collect an outdial number to dial from the user.
]]

return
{
  {
    action = "get_digits",
    min_digits = profile.mailbox_min_digits,
    max_digits = 20,
    audio_files = "phrase:collect_outdial_number",
    bad_input = "",
    -- * is for cancelling the collection.  Unfortunately, there's no way in
    -- Lua to escape the timeout and collect the escape key, so if a person
    -- presses *, they'll have to wait for the timeout before the cancel
    -- sequence is called.
    digits_regex = "\\d+|\\*",
    storage_key = "outdial_number",
    timeout = profile.user_input_timeout,
  },
}

