mailbox = variable("voicemail_mailbox")
mailbox_directory = profile.voicemail_dir .. "/" .. profile.context .. "/" .. profile.domain .. "/" .. mailbox

return
{
  {
    action = "create_directory",
    directory = mailbox_directory,
  },
  {
    action = "play_valid_file",
    files =  {
      mailbox_directory .. "/temp.wav",
      mailbox_directory .. "/greeting.wav",
      "phrase:default_greeting",
    },
    keys = {
      ["#"] = ":break",
    },
  },
  {
    action = "exit_sequence",
    sequence = "check_for_recorded_message",
  },
  {
    action = "record",
    location = profile.temp_recording_dir,
    keys = {
      ["#"] = ":break",
    },
  },
  {
    action = "play_phrase",
    phrase = "silence",
    phrase_arguments = 3000,
  },
  {
    action = "play_phrase",
    phrase = "goodbye",
  },
}
