--[[
  Add examples/private.lua in same directory as this file, with these
  global variables set:

  Rev.ai
    REV_AI_API_KEY

  Watson
    WATSON_API_KEY
    WATSON_SERVICE_URI
]]
require("jester.examples.private")

local inspect = require("inspect")
local core = require "jester.core"
local stt = require "jester.modules.speech_to_text"
local rev_ai = require "jester.modules.speech_to_text.rev_ai"
local watson = require "jester.modules.speech_to_text.watson"

local DEFAULT_HANDLER = "watson"

local rev_ai_handler = rev_ai:new({
  api_key = REV_AI_API_KEY,
  options = {
    speaker_channels_count = 1,
    remove_disfluencies = true,
    delete_after_seconds = 120,
  },
})
local watson_handler = watson:new({
  api_key = WATSON_API_KEY,
  service_uri = WATSON_SERVICE_URI,
  query_parameters = {
    model = "en-US_NarrowbandModel",
    smart_formatting = true,
    split_transcript_at_phrase_end = true,
  },
})

function speech_to_text_from_file(filepath, handler)
  local params = {
    retries = 10,
    retry_wait_seconds = 30,
    timeout_seconds = 300,
  }
  local file_params = {
    path = filepath,
  }
  local confidence, text
  local stt_obj = stt:new(handler, params)
  local success, data = stt_obj:speech_to_text_from_file(file_params)
  if success then
    confidence, text = handler:transcriptions_to_text(data)
  else
    core.log.err(data)
  end
  return success, data, confidence, text
end

local filepath = arg[1]
local handler_arg = arg[2] or DEFAULT_HANDLER
local handler
if handler_arg == "watson" then
  handler = watson_handler
elseif handler_arg == "revai" then
  handler = rev_ai_handler
end
core.bootstrap()
local success, data, confidence, text = speech_to_text_from_file(filepath, handler)
if success then
  core.log.info("RAW DATA: \n\n%s", inspect(data))
  core.log.info("Confidence in transcription: %.2f%%\n", confidence)
  core.log.info("TEXT: \n\n%s", text)
end
