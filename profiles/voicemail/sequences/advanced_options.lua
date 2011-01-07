--[[
  Play advanced message options to the caller.
]]

callback_extension = storage("mailbox_settings", "callback_extension")
outdial_extension = storage("mailbox_settings", "outdial_extension")

option_keys = {
  ["1"] = "send_reply_check",
  ["3"] = "play_cid_envelope advanced_options",
  ["*"] = "message_options",
}

callback = "N"
outdial = "N"

-- Add in the option to call back the calling party.
if callback_extension ~= "" then
  option_keys["2"] = "callback"
  callback = "Y"
end

-- Add in the option to place calls to outside numbers.
if outdial_extension ~= "" then
  option_keys["4"] = "outdial " .. outdial_extension .. ",message_options,collect"
  outdial = "Y"
end

return
{
  {
    action = "play_phrase",
    phrase = "advanced_options_list",
    phrase_arguments = "Y:" .. callback .. ":Y:" .. outdial .. ":N",
    keys = option_keys,
    repetitions = profile.menu_repetitions,
    wait = profile.menu_replay_wait,
  },
  {
    action = "call_sequence",
    sequence = "exit"
  },
}

