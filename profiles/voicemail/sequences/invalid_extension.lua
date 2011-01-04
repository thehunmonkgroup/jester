--[[
  Announce an invalid extension, and send to the next appropriate sequence.
]]

-- Next sequence to call.
next_sequence = args(1)

return
{
  {
    action = "play_phrase",
    phrase = "invalid_extension",
  },
  {
    action = "call_sequence",
    sequence = next_sequence,
  },
}
