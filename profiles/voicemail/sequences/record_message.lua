return
{
  {
    action = "wait",
    milliseconds = 500,
  },
  {
    action = "record",
    location = profile.temp_recording_dir,
    pre_record_sound = "phrase:beep",
    keys = {
      ["#"] = ":break",
    },
  },
  {
    action = "play_phrase",
    phrase = "thank_you",
  },
  {
    action = "call_sequence",
    sequence = "review_message",
  },
}

