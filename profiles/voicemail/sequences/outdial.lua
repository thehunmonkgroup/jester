--[[
  Optionally get an number to call, then transfer to the specified extension.
]]

-- The extension to transfer to for the outdial.
extension = args(1)
-- The sequence to call if the operation is cancelled.
cancel_sequence = args(2)
-- Whether to collect the number or not.
collect_outdial_number = args(3)
outdial_number = storage("get_digits", "outdial_number")

return
{
  {
    action = "conditional",
    value = collect_outdial_number,
    compare_to = "collect",
    comparison = "equal",
    if_true = "sub:collect_outdial_number",
  },
  {
    action = "conditional",
    value = outdial_number,
    compare_to = "*",
    comparison = "equal",
    if_true = cancel_sequence,
  },
  {
    action = "play_phrase",
    phrase = "please_wait_while_connecting",
  },
  -- Set the 'voicemail_outdial_number' channel variable so the receiving
  -- extension knows where to dial.
  {
    action = "set_variable",
    data = {
      voicemail_outdial_number = outdial_number,
    },
  },
  {
    action = "transfer",
    extension = extension,
  },
}

