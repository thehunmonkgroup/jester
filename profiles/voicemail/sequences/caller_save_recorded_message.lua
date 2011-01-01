next_sequence = args(1)

return
{
  {
    action = "call_sequence",
    sequence = "sub:check_for_recorded_message",
  },
  {
    action = "play_phrase",
    phrase = "greeting_saved",
  },
  {
    action = "wait",
    milliseconds = 500,
  },
  {
    action = "call_sequence",
    sequence = next_sequence,
  },
}

