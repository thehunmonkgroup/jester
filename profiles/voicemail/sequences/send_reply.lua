-- Message data.
message_number = storage("counter", "message_number")
mailbox = storage("message", "caller_id_number_" .. message_number)
domain = storage("message", "caller_domain_" .. message_number)

return
{
  {
    action = "set_storage",
    storage_area = "send_reply_info",
    data = {
      mailbox = mailbox,
      domain = domain,
    },
  },
  {
    action = "play_phrase",
    phrase = "default_greeting",
    keys = {
      ["#"] = ":break",
    },
  },
  {
    action = "exit_sequence",
    sequence = "send_reply_prepare_message",
  },
  {
    action = "call_sequence",
    sequence = "record_message",
  },
}

