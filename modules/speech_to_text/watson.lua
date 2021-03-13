--- Speech to text transcription handler, Watson Speech to Text API.
--
--  Uses Watson's Speech to Text service. The service requires a valid developer
--  account and API key, see
--  [here](https://cloud.ibm.com/catalog/services/speech-to-text) for more information.
--
-- @module speech_to_text_watson_handler
-- @author Chad Phillips
-- @copyright 2011-2021 Chad Phillips

require "jester.support.table"
require "jester.modules.speech_to_text.support"
local core = require "jester.core"
core.bootstrap()

local LOG_PREFIX = "JESTER::MODULE::SPEECH_TO_TEXT::WATSON"
local DEFAULT_PARAMS = {
  retries = 3,
  retry_wait_seconds = 60,
  query_parameters = {
  },
}

local _M = {}

local https = require 'ssl.https'
local ltn12 = require("ltn12")
local cjson = require("cjson")

local function process_response(self, response, status_code, status_description)
  local response_string = table.concat(response)
  if status_code == 200 then
    self.log.debug("JSON response string '%s'", response_string)
    return true, response_string
  else
    self.log.err("Request failed, status %s: description: %s, response: %s", status_code, status_description, response_string)
    return false, status_description
  end
end

local function request(self, url, attributes)
  local request_handler = self.params.request_handler or https
  local response = {}
  local body, status_code, headers, status_description = request_handler.request({
    method = "POST",
    headers = {
      ["content-length"] = attributes.content_length,
      ["content-type"] = attributes.content_type,
      ["accept"] = "application/json",
    },
    url = url,
    sink = ltn12.sink.table(response),
    source = ltn12.source.file(attributes.file),
  })
  return process_response(self, response, status_code, status_description)
end

local function build_and_execute_request(self, attributes)
  local service_uri = self.params.service_uri:gsub("https?://", "")
  local query_string = table.stringify(self.params.query_parameters)
  local url = string.format("https://apikey:%s@%s/v1/recognize?%s", self.params.api_key, service_uri, query_string)
  self.log.debug("Got request to transcribe file '%s', using request URI '%s'", attributes.path, url)
  return request(self, url, attributes)
end

local function parse(self, response)
  local transcriptions = {}
  local data = cjson.decode(response)
  for k, chunk in ipairs(data.results) do
    transcriptions[k] = {}
    transcriptions[k].text = chunk.alternatives[1].transcript
    transcriptions[k].confidence = chunk.alternatives[1].confidence
  end
  return transcriptions
end

local function check_params(params, file_params)
  if params.api_key and params.service_uri and file_params.path then
    params = stt_set_start_end_timestamps(params)
    return true, params
  else
    return false, "ERROR: Missing API key, service URI, or filepath"
  end
end

local function assemble_transcriptions_to_text(self, confidence_sum, text_parts, data, next_i)
  local i, part = next(data, next_i)
  if i then
    confidence_sum = confidence_sum + part.confidence
    table.insert(text_parts, part.text)
    return assemble_transcriptions_to_text(self, confidence_sum, text_parts, data, i)
  else
    local confidence = confidence_sum == 0 and 0 or (confidence_sum / #data * 100)
    local text = table.concat(text_parts, "\n\n")
    return confidence, text
  end
end

--- Format transcription data to plain text.
--
-- @param self
-- @tab data
--   A table of transcription data as returned by @{parse_transcriptions}.
-- @treturn number confidence
--   Number from zero to one hundred, representing the average confidence of all
--   transcribed parts.
-- @treturn string text
--   Concatenated transcription.
-- @usage
--   confidence, text = transcriptions_to_text(data)
function _M:transcriptions_to_text(data)
  local confidence_sum = 0
  local text_parts = {}
  local confidence, text = assemble_transcriptions_to_text(self, confidence_sum, text_parts, data)
  self.log.debug("Confidence in transcription: %.2f%%\n", confidence)
  self.log.debug("TEXT: \n\n%s", text)
  return confidence, text
end

--- Parse a response from a successful API call.
--
-- @param self
-- @string response
--   The response from the API call.
-- @treturn bool success
--   Indicates if operation succeeded.
-- @return data
--   Table of transcriptions on success, error message on fail.
-- @usage
--   success, data = parse_transcriptions(response)
function _M:parse_transcriptions(response)
  success, data = pcall(parse, self, response)
  return success, data
end

--- Make a request to the Watson Speech to Text API to transcribe an audio file.
--
-- @param self
-- @param file_params
--   Table of file parameters, as passed to @{speech_to_text_support.load_file_attributes}.
-- @treturn bool success
--   Indicates if operation succeeded.
-- @treturn string response
--   Contents of response on success, error message on fail.
-- @usage
--   local file_params = {
--     path = "/tmp/myfile.wav",
--   }
--   success, response = handler:make_request(file_params)
function _M:make_request(file_params)
  local success, response = check_params(self.params, file_params)
  if success then
    self.params = response
    success, response = load_file_attributes(file_params)
    if success then
      return build_and_execute_request(self, response)
    end
  end
  return success, response
end

--- Create a new Watson speech to text handler object.
--
-- @param self
-- @tab params
--   Configuration parameters, see @{speech_to_text.new} for general parameters.
-- @param params.api_key
--   Developer API key as obtained from the service credentials.
-- @param params.service_uri
--   Service URL as obtained from the service credentials.
-- @param params.query_parameters
--   Table of query parameters to pass to the API call.
-- @return A Watson speech to text handler object.
-- @usage
--   local watson = require("jester.modules.speech_to_text.watson")
--   local params = {
--     api_key = "some_api_key",
--     service_uri = "some_service_uri",
--     -- other params...
--   }
--   local handler = watson:new(params)
function _M.new(self, params)
  local watson = {}
  watson.params = table.merge(DEFAULT_PARAMS, params or {})
  watson.log = core.logger({prefix = LOG_PREFIX})
  setmetatable(watson, self)
  self.__index = self
  watson.log.debug("New Watson speech to text handler object")
  return watson
end

return _M
