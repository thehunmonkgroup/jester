--- Converts phone call audio into web page data.
--
-- Records a sound file, converts the speech to text, and stores it on a
-- public web server.
--
-- The @{speech_to_text} module must be properly configured, and the default
-- FreeSWITCH voicemail phrase macros must be available for this to work.
--
-- The recording is limited to 10 seconds, you must wait for the "saved"
-- prompt to allow the webservice POST to complete.
--
-- The location of the web page containing the message will be output to the
-- FreeSWITCH console -- on that web page the message will be listed in the
-- QUERY_STRING header.
--
-- This is a very simple workflow -- more robust workflows would deal with
-- the user hanging up before the service requests are made, validating that
-- the translation was successful, etc.

temp_dir = "/tmp"
filename = "post_test.wav"
message = storage("speech_to_text", "translation_1")
post_response = storage("service", "raw")

return
{
  {
    action = "wait",
    milliseconds = 500,
  },
  {
    action = "play_phrase",
    phrase = "voicemail_record_message",
  },
  {
    action = "record",
    location = temp_dir,
    filename = filename,
    pre_record_sound = "tone",
    max_length = 10,
    silence_secs = 2,
    keys = {
      ["0"] = ":break",
      ["1"] = ":break",
      ["2"] = ":break",
      ["3"] = ":break",
      ["4"] = ":break",
      ["5"] = ":break",
      ["6"] = ":break",
      ["7"] = ":break",
      ["8"] = ":break",
      ["9"] = ":break",
      ["*"] = ":break",
      ["#"] = ":break",
    },
  },
  {
    action = "speech_to_text_from_file",
    filepath = temp_dir .. "/" .. filename,
    app_key = profile.att_app_key,
    app_secret = profile.att_app_secret,
  },
  {
    action = "http_request",
    path = "post.php",
    query = {
      dir = "jester",
      message = message,
    },
    server = "posttestserver.com",
  },
  {
    action = "log",
    message = "POST MESSAGE RESPONSE: " .. post_response,
  },
  {
    action = "play_phrase",
    phrase = "voicemail_ack",
    phrase_arguments = "saved",
  },
  {
    action = "hangup",
  },
}
