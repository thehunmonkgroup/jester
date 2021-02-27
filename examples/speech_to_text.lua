local core = require "jester.core"
local stt = require "jester.modules.speech_to_text"
local rev_ai = require "jester.modules.speech_to_text.rev_ai"

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
    retries = 10,
    retry_wait_seconds = 30,
  }
  local confidence, text
  local success, data = stt.speech_to_text_from_file(params, rev_ai)
  if success then
    confidence, text = rev_ai.transcriptions_to_text(data)
  else
    core.error_log(data)
  end
  return success, data, confidence, text
end

local filepath = arg[1]
core.bootstrap()
local success, data, confidence, text = speech_to_text_from_file(filepath)
