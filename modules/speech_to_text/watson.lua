local core = require "jester.core"

local _M = {}

local DEFAULT_RETRIES = 3
local DEFAULT_RETRY_WAIT_SECONDS = 60

local https = require 'ssl.https'
local ltn12 = require("ltn12")
local cjson = require("cjson")
local socket = require "socket"

local function parse_transcriptions(response_string)
  local transcriptions = {}
  local data = cjson.decode(response_string)
  for k, chunk in ipairs(data.results) do
    transcriptions[k] = {}
    transcriptions[k].text = chunk.alternatives[1].transcript
    transcriptions[k].confidence = chunk.alternatives[1].confidence
  end
  return transcriptions
end

local function make_request(url, filepath)
  local status = 1
  local transcriptions = {}
  local response = {}
  local content_length
  local file, err = io.open(filepath, "rb")
  if file then
    content_length = (filesize(file))
  else
    core.debug_log("ERROR: could not open '%s': %s", filepath, err)
    return status, transcriptions
  end
  local body, status_code, headers, status_description = https.request({
    method = "POST",
    headers = {
      ["content-length"] = content_length,
      ["content-type"] = "audio/wav",
      ["accept"] = "application/json",
    },
    url = url,
    sink = ltn12.sink.table(response),
    source = ltn12.source.file(file),
  })

  if status_code == 200 then
    local response_string = table.concat(response)
    core.debug_log("JSON response string '%s'", response_string)
    -- Doesn't look like Watson provides any kind of status data for the
    -- transcription, so assume it succeeded.
    success, data = pcall(parse_transcriptions, response_string)
    if success then
      status = 0
      transcriptions = data
    else
      core.debug_log("ERROR: Parsing Watson API response failed: %s", data)
    end
  else
    core.debug_log("ERROR: Request to Watson API server failed: %s", status_description)
  end

  return status, transcriptions
end

--[[
  Speech to text using Watson's API.
]]
function _M.speech_to_text_from_file(action)
  local status = 1
  local transcriptions = {}

  local api_key = action.api_key
  local service_uri = action.service_uri
  local filepath = action.filepath
  local query_parameters = action.query_parameters
  local retries = action.retries or DEFAULT_RETRIES
  local retry_wait_seconds = action.retry_wait_seconds or DEFAULT_RETRY_WAIT_SECONDS

  if api_key and service_uri and filepath then

    service_uri = service_uri:gsub("https?://", "")
    local query_string = table.stringify(query_parameters)

    local url = string.format("https://apikey:%s@%s/v1/recognize?%s", api_key, service_uri, query_string)

    core.debug_log("Got request to translate file '%s', using request URI '%s'", filepath, url)

    for i = 1, retries do
      status, transcriptions = make_request(url, filepath)
      if status == 0 then
        return status, transcriptions
      end
      core.debug_log([[ERROR: Watson API attempt #%d failed]], i)
      if i < retries then
        core.debug_log([[ERROR: Re-trying Watson API in %d seconds]], retry_wait_seconds)
        socket.sleep(retry_wait_seconds)
      end
    end

  else
    core.debug_log("ERROR: Missing API key, service URI, or filepath")
  end

  return status, transcriptions

end

return _M
