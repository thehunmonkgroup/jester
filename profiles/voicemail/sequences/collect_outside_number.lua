return
{
  {
    action = "get_digits",
    min_digits = profile.mailbox_min_digits,
    max_digits = 20,
    audio_files = "phrase:collect_outside_number",
    bad_input = "",
    digits_regex = "\\d+|\\*",
    storage_key = "call_outside_number",
    timeout = profile.user_input_timeout,
  },
}

