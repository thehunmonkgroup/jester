cancel_sequence = args(1)
outside_number = storage("get_digits", "call_outside_number")

return
{
  {
    action = "get_digits",
    min_digits = 1,
    max_digits = 20,
    audio_files = "phrase:call_outside_number",
    bad_input = "",
    digits_regex = "\\d+|\\*",
    storage_key = "call_outside_number",
  },
  {
    action = "conditional",
    value = outside_number,
    compare_to = "*",
    comparison = "equal",
    if_true = cancel_sequence,
  },
  {
    action = "play_phrase",
    phrase = "please_wait_while_connecting",
  },
  {
    action = "set_variable",
    data = {
      voicemail_call_outside_number = outside_number,
    },
  },
  {
    action = "transfer",
    extension = profile.call_outside_number_extension,
  },
}

