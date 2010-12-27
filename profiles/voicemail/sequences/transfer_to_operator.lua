
return
{
  {
    action = "call_sequence",
    sequence = "sub:cleanup_temp_recording",
  },
  {
    action = "transfer",
    extension = profile.operator_extension,
  },
}
