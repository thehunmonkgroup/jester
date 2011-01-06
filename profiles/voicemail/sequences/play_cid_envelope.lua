--[[
  Play caller ID/envelope information.
]]

-- Coming from where?  Could be either prior to playing the message, or from
-- the advanced menu options.
from = args(1)

-- Always play both if we're coming from the advanced options.
if from == "advanced_options" then
  play_envelope = "yes"
  play_caller_id = "yes"
-- Otherwise, only play the information according to the mailbox settings.
else
  play_envelope = storage("mailbox_settings", "play_envelope")
  play_caller_id = storage("mailbox_settings", "play_caller_id")
end

-- Message data.
message_number = storage("counter", "message_number")
timestamp = storage("message", "timestamp_" .. message_number)
caller_id_number = storage("message", "caller_id_number_" .. message_number)


return
{
  {
    action = "play_phrase",
    phrase = "cid_envelope",
    phrase_arguments = play_envelope .. ":" .. timestamp .. ":" .. play_caller_id .. ":" .. caller_id_number,
    keys = {
      ["1"] = "top:play_message",
      ["2"] = "top:change_folders",
      ["3"] = "top:advanced_options",
      ["4"] = "top:prev_message",
      ["5"] = "top:repeat_message",
      ["6"] = "top:next_message",
      ["7"] = "top:delete_undelete_message",
      ["8"] = "top:forward_message_menu",
      ["9"] = "top:save_message",
      ["*"] = "help",
      ["#"] = "exit",
    },
  },
  {
    action = "conditional",
    value = from,
    compare_to = "advanced_options",
    comparison = "equal",
    if_true = "top:message_options",
  },
}

