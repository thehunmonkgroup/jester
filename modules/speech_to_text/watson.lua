local core = require "jester.core"

local _M = {}

local https = require 'ssl.https'
local ltn12 = require("ltn12")
local cjson = require("cjson")

local DEFAULT_LANGUAGE_MODEL = "en-US_NarrowbandModel"

--[[
  Speech to text using Watson's API.
]]
function _M.speech_to_text_from_file(action, attributes)
  local status = 1
  local translations = {}
  local language_model = action.language_model or DEFAULT_LANGUAGE_MODEL

  local api_key = action.api_key
  local service_uri = action.service_uri
  local filepath = action.filepath

  if api_key and service_uri and filepath then

    core.debug_log("Got request to translate file '%s' at URI '%s' using language model '%s'", filepath, service_uri, language_model)

    local response = {}
    local url = string.format("https://apikey:%s@%s/v1/recognize?model=%s", api_key, service_uri, language_model)

    local body, status_code, headers, status_description = https.request({
      method = "POST",
      headers = {
        ["content-length"] = attributes.filesize,
        ["content-type"] = "audio/wav",
        ["accept"] = "application/json",
      },
      url = url,
      sink = ltn12.sink.table(response),
      source = ltn12.source.file(attributes.file),
    })

    if status_code == 200 then
      local response_string = table.concat(response)
      core.debug_log("JSON response string '%s'", response_string)
      local data = cjson.decode(response_string)
      -- Doesn't look like Watson provides any kind of status data for the
      -- translation, so assume it succeeded.
      status = 0
      if status == 0 then
        for k, chunk in ipairs(data.results) do
          translations[k] = {}
          translations[k].text = chunk.alternatives[1].transcript
          translations[k].confidence = chunk.alternatives[1].confidence
        end
      end
    else
      core.debug_log("ERROR: Request to Watson API server failed: %s", status_description)
    end
  else
    core.debug_log("ERROR: Missing API key, service URI, or filepath")
  end

  return status, translations
end

return _M
