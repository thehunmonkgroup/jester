local key_map = {
  ["9"] = ":navigation_up",
  ["*"] = ":navigation_top",
  invalid_sound = "ivr/ivr-that_was_an_invalid_entry.wav"
}

return
{
  {
    action = "play",
    file = global.sounds_dir .. "/ohno1/answering_machine.wav",
    keys = key_map,
  },
}
