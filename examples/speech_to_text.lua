local inspect = require("inspect")
local core = require "jester.core"
local stt = require "jester.modules.speech_to_text"
local rev_ai = require "jester.modules.speech_to_text.rev_ai"
local watson = require "jester.modules.speech_to_text.watson"

local handler = rev_ai
--local handler = watson

local API_KEY = "[API KEY]"
local SERVICE_URI = "[SERVICE URL]"

function speech_to_text_from_file(filepath)
  local params = {
    api_key = API_KEY,
    service_uri = SERVICE_URI,
    filepath = filepath,
    options = {
      speaker_channels_count = 1,
      remove_disfluencies = true,
      delete_after_seconds = 120,
    },
    query_parameters = {
      model = "en-US_NarrowbandModel",
      smart_formatting = true,
      split_transcript_at_phrase_end = true,
    },
    retries = 10,
    retry_wait_seconds = 30,
    timeout_seconds = 300,
  }
  local confidence, text
  local success, data = stt.speech_to_text_from_file(params, handler)
  if success then
    confidence, text = handler.transcriptions_to_text(data)
  else
    core.log.err(data)
  end
  return success, data, confidence, text
end

local filepath = arg[1]
core.bootstrap()
local success, data, confidence, text = speech_to_text_from_file(filepath)
if success then
  core.log.info("RAW DATA: \n\n%s", inspect(data))
  core.log.info("Confidence in transcription: %.2f%%\n", confidence)
  core.log.info("TEXT: \n\n%s", text)
end
