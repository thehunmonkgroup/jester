greeting = args(1)

return
{
  {
    action = "play_phrase",
    phrase = "thank_you",
    keys = {
     ["1"] = "accept_greeting " .. greeting,
     ["2"] = "listen_to_greeting " .. greeting,
     ["3"] = "record_greeting " .. greeting,
    },
  },
  {
    action = "call_sequence",
    sequence = "record_greeting_confirm " .. greeting,
  },
}

