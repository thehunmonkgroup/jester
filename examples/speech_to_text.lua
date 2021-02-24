local core = require "jester.core"
local stt = require "jester.modules.speech_to_text"
local watson = require "jester.modules.speech_to_text.watson"

local API_KEY = "[API KEY]"
local SERVICE_URI = "[SERVICE URL]"

function speech_to_text_from_file(filepath)
  local params = {
    api_key = API_KEY,
    service_uri = SERVICE_URI,
    filepath = filepath,
    query_parameters = {
      model = "en-US_NarrowbandModel",
      smart_formatting = true,
      split_transcript_at_phrase_end = true,
    },
    retries = 10,
    retry_wait_seconds = 30,
  }
  local confidence, text
  local success, data = stt.speech_to_text_from_file(params, watson)
  if success then
    confidence, text = watson.transcriptions_to_text(data)
  else
    core.error_log(data)
  end
  return success, data, confidence, text
end

local filepath = arg[1]
core.bootstrap()
local success, data, confidence, text = speech_to_text_from_file(filepath)
