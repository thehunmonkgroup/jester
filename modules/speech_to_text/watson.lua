local core = require "jester.core"

local _M = {}

local DEFAULT_RETRIES = 3
local DEFAULT_RETRY_WAIT_SECONDS = 60

local https = require 'ssl.https'
local ltn12 = require("ltn12")
local cjson = require("cjson")
local socket = require "socket"

local function request(url, attributes)
  local success = false
  local response_string
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
  if status_code == 200 then
    success = true
    response_string = table.concat(response)
    core.debug_log("JSON response string '%s'", response_string)
  else
    response_string = status_description
  end
  return success, response_string
end

local function parse(response_string)
  local transcriptions = {}
  local data = cjson.decode(response_string)
  for k, chunk in ipairs(data.results) do
    transcriptions[k] = {}
    transcriptions[k].text = chunk.alternatives[1].transcript
    transcriptions[k].confidence = chunk.alternatives[1].confidence
  end
  return transcriptions
end

function _M.parse_transcriptions(response_string)
  success, data = pcall(parse, response_string)
  return success, data
end

function _M.make_request(arguments, attributes)

  local success = false
  local response_string
  local api_key = arguments.api_key
  local service_uri = arguments.service_uri
  local filepath = arguments.filepath
  local query_parameters = arguments.query_parameters
  if api_key and service_uri and filepath then
    service_uri = service_uri:gsub("https?://", "")
    local query_string = table.stringify(query_parameters)
    local url = string.format("https://apikey:%s@%s/v1/recognize?%s", api_key, service_uri, query_string)
    core.debug_log("Got request to translate file '%s', using request URI '%s'", filepath, url)
    success, response_string = request(url, attributes)
  else
    response_string = "ERROR: Missing API key, service URI, or filepath"
  end

  return success, response_string

end

return _M
