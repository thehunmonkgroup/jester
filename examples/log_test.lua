return
{
  {
    action = "log",
    message = "Hello world",
  },
  {
    action = "log",
    message = "Jester sequences directory: " .. global.sequence_path,
  },
  {
    action = "log",
    message = "Jester channel variable : " .. variable("caller_id_number"),
  },
  {
    action = "log",
    message = "Jester storage test: " .. storage("data", "voicemail_settings_mailbox"),
  },
}
