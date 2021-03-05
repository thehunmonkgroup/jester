--- Speech to text translation handler, Rev.ai API.
--
--  Uses Rev.ai's service. The service requires a valid developer
--  account and API key, see
--  [here](https://www.rev.ai/getting_started) for more information.
--
-- @module speech_to_text_rev_ai_handler
-- @author Chad Phillips
-- @copyright 2021 Chad Phillips

--- Parameters used to configure the speech to text request.
--
-- These are specific to the Rev.ai handler, see @{speech_to_text.params} for
-- general parameters.
--
-- @table params
--
-- @field api_key
--   Developer API key as obtained from the service credentials.
-- @field service_uri
--   Service URL as obtained from the service credentials.
-- @field query_parameters
--   Table of query parameters to pass to the API call.

local inspect = require "inspect"
local core = require "jester.core"
require "jester.support.table"
local mp = require "jester.support.multipart-post"

local _M = {}

local https = require 'ssl.https'
--local http = require 'socket.http'
local ltn12 = require("ltn12")
local cjson = require("cjson")

--local BASE_URL = "http://localhost:3000/v1"
local BASE_URL = "https://api.rev.ai/speechtotext/v1"
local DEFAULT_OPTIONS = {}

local function process_response(response, status_code, status_description)
  if status_code == 200 then
    response_string = table.concat(response)
    core.log.debug("JSON response string '%s'", response_string)
    return true, response_string
  else
    core.log.err("Request failed, status %s: '%s'", status_code, status_description)
    return false, status_description
  end
end

local function request(url, api_key, options, params, attributes)
  local request_handler = params.request_handler or https
  local response = {}
  local options_string = cjson.encode(options)
  local rq = mp.gen_request({
    media = {
      filename = attributes.basename,
      data = attributes.file,
      len = attributes.content_length,
      content_type = attributes.file_type,
    },
    options = options_string,
  })
  rq.url = url
  rq.headers.authorization = string.format([[Bearer %s]], api_key)
  rq.sink = ltn12.sink.table(response)
  --local body, status_code, headers, status_description = http.request(rq)
  local body, status_code, headers, status_description = request_handler.request(rq)
  --core.log.debug(inspect(table.concat(response)))
  return process_response(response, status_code, status_description)
end

local function parse(response)
  local transcriptions = {}
  local data = cjson.decode(response)
  local inspect = require "inspect"
  print(inspect(data))
  for k, chunk in ipairs(data.results) do
    transcriptions[k] = {}
    transcriptions[k].text = chunk.alternatives[1].transcript
    transcriptions[k].confidence = chunk.alternatives[1].confidence
  end
  return transcriptions
end

local function check_params(params)
  if params.api_key and params.filepath then
    return true
  else
    return false, "ERROR: Missing API key, service URI, or filepath"
  end
end

local function assemble_transcriptions_to_text(confidence_sum, text_parts, data, next_i)
  local i, part = next(data, next_i)
  if i then
    confidence_sum = confidence_sum + part.confidence
    table.insert(text_parts, part.text)
    return assemble_transcriptions_to_text(confidence_sum, text_parts, data, i)
  else
    local confidence = confidence_sum == 0 and 0 or (confidence_sum / #data * 100)
    local text = table.concat(text_parts, "\n\n")
    return confidence, text
  end
end

--- Format transcription data to plain text.
--
-- @tab data
--   A table of transcription data as returned by @{parse_transcriptions}.
-- @treturn number confidence
--   Number from zero to one hundred, representing the average confidence of all
--   translated parts.
-- @treturn string text
--   Concatenated transcription.
-- @usage
--   confidence, text = transcriptions_to_text(data)
function _M.transcriptions_to_text(data)
  local confidence_sum = 0
  local text_parts = {}
  local confidence, text = assemble_transcriptions_to_text(confidence_sum, text_parts, data)
  core.log.debug("Confidence in transcription: %.2f%%\n", confidence)
  core.log.debug("TEXT: \n\n%s", text)
  return confidence, text
end

--- Parse a response from a successful API call.
--
-- @string response
--   The response from the API call.
-- @treturn bool success
--   Indicates if operation succeeded.
-- @return data
--   Table of transcriptions on success, error message on fail.
-- @usage
--   success, data = parse_transcriptions(response)
function _M.parse_transcriptions(response)
  success, data = pcall(parse, response)
  return success, data
end

--- Make a request to the Watson Speech to Text API to transcribe an audio file.
--
-- @tab params
--   Method params, see @{speech_to_text.params} and @{params}.
-- @tab attributes
--   Method attributes, see @{speech_to_text.attributes}.
-- @treturn bool success
--   Indicates if operation succeeded.
-- @treturn string response
--   Contents of response on success, error message on fail.
-- @usage
--   success, response = make_request(params, attributes)
function _M.make_request(params, attributes)
  local success, response = check_params(params)
  if success then
    local url = string.format("%s/jobs", BASE_URL)
    local options = params.options or DEFAULT_OPTIONS
    core.log.debug("Got request to translate file '%s', using request URI '%s'", params.filepath, url)
    success, response = request(url, params.api_key, options, params, attributes)
  end
  return success, response
end

return _M
