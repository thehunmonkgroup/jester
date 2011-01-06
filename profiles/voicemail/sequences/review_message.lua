--[[
  Play options to the user to save, playback, or re-record their message.
]]

-- Is the operator extension enabled?
operator = args(1)
no_review_next_sequence = "exit"

-- Message review option for the mailbox.
review_messages = storage("mailbox_settings", "review_messages")

-- This will always be empty unless a person is replying to a message.
is_reply = storage("send_reply_info", "mailbox")
-- If it's a reply, then send user back to the message options instead of
-- hanging up on them.
if is_reply ~= "" then
  no_review_next_sequence = "message_options"
end

-- Set up the initial review keys.
review_keys = {
  ["1"] = "caller_save_recorded_message exit",
  ["2"] = "caller_playback_recorded_message",
  ["3"] = "caller_rerecord_message",
}

-- Add in the operator extension if it's enabled.
if operator == "operator" then
  review_keys["0"] = "operator_transfer_prepare"
end

return
{
  -- If message review isn't enabled, then exit the call.
  {
    action = "conditional",
    value = review_messages,
    compare_to = "no",
    comparison = "equal",
    if_true = no_review_next_sequence,
  },
  {
    action = "play_phrase",
    phrase = "greeting_options",
    keys = review_keys,
    repetitions = profile.menu_repetitions,
    wait = profile.menu_replay_wait,
  },
  {
    action = "call_sequence",
    sequence = "exit",
  },
}

