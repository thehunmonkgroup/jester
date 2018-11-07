local core = require "jester.core"

local _M = {}

local https = require 'ssl.https'
local ltn12 = require("ltn12")
local cjson = require("cjson")

--[[
  Speech to text using Watson's API.
]]
function _M.speech_to_text_from_file(action, attributes)
  local status = 1
  local translations = {}

  local api_key = action.api_key

  if api_key then
    local response = {}

    local body, status_code, headers, status_description = https.request({
      method = "POST",
      headers = {
        ["content-length"] = attributes.filesize,
        ["content-type"] = "audio/wav",
        ["accept"] = "application/json",
      },
      url = string.format("https://apikey:%s@stream.watsonplatform.net/speech-to-text/api/v1/recognize?model=en-US_NarrowbandModel", api_key),
      sink = ltn12.sink.table(response),
      source = ltn12.source.file(attributes.file),
      protocol = "all",
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
          translations[k].text = chunk.alternatives[0].transcript
          translations[k].confidence = chunk.alternatives[0].confidence
        end
      end
    else
      core.debug_log("ERROR: Request to Watson API server failed: %s", status_description)
    end
  end

  return status, translations
end

return _M
