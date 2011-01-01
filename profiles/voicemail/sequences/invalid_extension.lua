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
