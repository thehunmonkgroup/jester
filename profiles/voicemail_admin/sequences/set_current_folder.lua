return
{
  {
    action = "call_sequence",
    sequence = "sub:prepare_messages " .. args(1),
  },
  {
    action = "call_sequence",
    sequence = "help"
  },
}

