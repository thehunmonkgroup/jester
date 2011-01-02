next_sequence = args(1)
-- This will always be empty unless a person is replying to a message.
is_reply = storage("send_reply_info", "mailbox")

if is_reply ~= "" then
  prepare_message = "send_reply_prepare_message"
  next_sequence = "send_reply_save_message"
else
  prepare_message = "main_greeting_prepare_message"
end

return
{
  {
    action = "call_sequence",
    sequence = "sub:" .. prepare_message,
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

