--[[
  Optionally get an outside number to call, then transfer to the operator
  extension.
]]

-- The sequence to call if the operation is cancelled.
cancel_sequence = args(1)
-- Whether to collect the outside number or not.
collect_outside_number = args(2)
outside_number = storage("get_digits", "call_outside_number")

return
{
  {
    action = "conditional",
    value = collect_outside_number,
    compare_to = "collect",
    comparison = "equal",
    if_true = "sub:collect_outside_number",
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
  -- Set the 'voicemail_call_outside_number' channel variable so the receiving
  -- extension knows where to dial.
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

