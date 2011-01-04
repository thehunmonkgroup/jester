--[[
  Save a message to a message group.
]]

-- Total number of users in the message group.
total_mailboxes = storage("message_group", "__count")
-- Which mailbox in the group we're currently on.
row_count = storage("counter", "message_group_row")
-- Mailbox info for the current mailbox.
mailbox = storage("message_group", "mailbox_" .. row_count)
domain = storage("message_group", "domain_" .. row_count)
mailbox_dir = profile.voicemail_dir .. "/" .. domain .. "/" .. mailbox

-- Result of the attempt to load the mailbox.
loaded_mailbox = storage("mailbox_settings_message", "mailbox")

-- Mailbox settings for the loaded mailbox.
email_messages = storage("mailbox_settings_message", "email_messages")
mailbox_provisioned = storage("mailbox_settings_message", "mailbox_provisioned")

return
{
  -- Increment the group counter by one.  If we're past the total mailboxes,
  -- then clean up.
  {
    action = "counter",
    increment = 1,
    storage_key = "message_group_row",
    compare_to = total_mailboxes,
    if_greater = "cleanup_temp_recording",
  },
  -- Try to load the mailbox.
  {
    action = "call_sequence",
    sequence = "sub:load_mailbox_settings " .. mailbox .. "," .. domain .. ",mailbox_settings_message",
  },
  -- No mailbox found, so just re-call the sequence to move on to the next
  -- mailbox.
  {
    action = "conditional",
    value = loaded_mailbox,
    compare_to = "",
    comparison = "equal",
    if_true = "save_group_message",
  },
  -- Provision the mailbox if it's not provisioned.
  {
    action = "conditional",
    value = mailbox_provisioned,
    compare_to = "no",
    comparison = "equal",
    if_true = "sub:provision_mailbox " .. mailbox .. "," .. domain,
  },
  -- Set up the mailbox data for message storage.
  {
    action = "set_storage",
    storage_area = "message_info",
    data = {
      mailbox = mailbox,
      domain = domain,
    },
  },
  -- Email the message if necessary.
  {
    action = "conditional",
    value = email_messages,
    compare_to = "no",
    comparison = "equal",
    if_false = "sub:email_message",
  },
  -- Save the message to the mailbox if necessary.
  {
    action = "conditional",
    value = email_messages,
    compare_to = "email_only",
    comparison = "equal",
    if_false = "sub:save_recorded_message copy",
  },
  -- Call the sequence again to trigger the next user in the group.
  {
    action = "call_sequence",
    sequence = "save_group_message",
  },
}

