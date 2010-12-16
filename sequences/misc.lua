local key_map = {
  ["1"] = "foo",
  ["9"] = ":navigation_up",
  invalid_sound = "ivr/ivr-that_was_an_invalid_entry.wav"
}

return
{
  {
    action = "play",
    file = "voicemail/vm-greeting.wav",
    keys = key_map,
  },
  {
    action = "play",
    file = "voicemail/vm-has_been_changed_to.wav",
    keys = key_map,
  },
  {
    action = "play",
    file = "silence_stream://2000",
    keys = key_map,
  },
}
