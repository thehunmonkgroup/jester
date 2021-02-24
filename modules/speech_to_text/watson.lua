--- Speech to text translation handler, Watson Speech to Text API.
--
--  Uses Watson's Speech to Text service. The service requires a valid developer
--  account and API key, see
--  [here](https://cloud.ibm.com/catalog/services/speech-to-text) for more information.
--
-- @module speech_to_text_watson_handler
-- @author Chad Phillips
-- @copyright 2011-2021 Chad Phillips

--- Parameters used to configure the speech to text request.
--
-- These are specific to the Watson handler, see @{speech_to_text.params} for
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

local core = require "jester.core"

local _M = {}

local DEFAULT_RETRIES = 3
local DEFAULT_RETRY_WAIT_SECONDS = 60

local https = require 'ssl.https'
local ltn12 = require("ltn12")
local cjson = require("cjson")
local socket = require "socket"

local function process_response(response, status_code, status_description)
  if status_code == 200 then
    response_string = table.concat(response)
    core.debug_log("JSON response string '%s'", response_string)
    return true, response_string
  else
    return false, status_description
  end
end

local function request(url, attributes)
  local response = {}
  local body, status_code, headers, status_description = https.request({
    method = "POST",
    headers = {
      ["content-length"] = attributes.content_length,
      ["content-type"] = attributes.file_type,
      ["accept"] = "application/json",
    },
    url = url,
    sink = ltn12.sink.table(response),
    source = ltn12.source.file(attributes.file),
  })
  return process_response(response, status_code, status_description)
end

local function parse(response)
  local transcriptions = {}
  local data = cjson.decode(response)
  for k, chunk in ipairs(data.results) do
    transcriptions[k] = {}
    transcriptions[k].text = chunk.alternatives[1].transcript
    transcriptions[k].confidence = chunk.alternatives[1].confidence
  end
  return transcriptions
end

local function check_params(params)
  if params.api_key and params.service_uri and params.filepath then
    return true
  else
    return false, "ERROR: Missing API key, service URI, or filepath"
  end
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
    local service_uri = params.service_uri:gsub("https?://", "")
    local query_string = table.stringify(params.query_parameters)
    local url = string.format("https://apikey:%s@%s/v1/recognize?%s", params.api_key, service_uri, query_string)
    core.debug_log("Got request to translate file '%s', using request URI '%s'", params.filepath, url)
    success, response = request(url, attributes)
  end
  return success, response
end

return _M
