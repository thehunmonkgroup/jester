local key_map = {
  ["1"] = "misc",
  invalid_sound = "ivr/ivr-that_was_an_invalid_entry.wav"
}

return
{
  {
    action = "data_load",
    handler = "odbc",
    config = profile.db_config,
    filters = { context = args.arg1, mailbox = args.arg2 },
    fields = { "mailbox", "context", "password", "email" },
    prefix = "voicemail_settings_",
    -- sort = { password = "desc" },
    -- multiple = true,
  },
  {
    action = "play",
    file = profile.voicemail_dir .. "/" .. args.arg1 .. "/" .. variable("domain") .. "/" .. storage("data", "voicemail_settings_mailbox") .. "/greeting.wav",
    keys = key_map,
  },
  {
    action = "data_update",
    handler = "odbc",
    config = profile.db_config,
    fields = { password = "1235", email = "foo@example.com" },
    filters = { context = args.arg1, mailbox = "5555555555" },
  },
  {
    action = "data_delete",
    handler = "odbc",
    config = profile.db_config,
    filters = { context = args.arg1, mailbox = "5555555555" },
  },
  {
    action = "play",
    file = "silence_stream://2000",
    keys = key_map,
  },
  {
    action = "play",
    file = "voicemail/vm-goodbye.wav",
  },
}
