-- Message data.
message_number = storage("counter", "message_number")
mailbox = storage("message", "caller_id_number_" .. message_number)
domain = storage("message", "caller_domain_" .. message_number)
loaded_mailbox = storage("mailbox_settings_message", "mailbox")

return
{
  {
    action = "call_sequence",
    sequence = "sub:load_mailbox_settings " .. mailbox .. "," .. domain .. ",mailbox_settings_message",
  },
  {
    action = "conditional",
    value = loaded_mailbox,
    compare_to = "",
    comparison = "equal",
    if_false = "send_reply",
  },
  {
    action = "play_phrase",
    phrase = "no_mailbox",
  },
  {
    action = "call_sequence",
    sequence = "message_options",
  },
}

