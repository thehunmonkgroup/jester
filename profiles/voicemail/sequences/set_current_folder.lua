folder = args(1)

return
{
  {
    action = "call_sequence",
    sequence = "sub:prepare_messages " .. folder,
  },
  {
    action = "call_sequence",
    sequence = "help"
  },
}

