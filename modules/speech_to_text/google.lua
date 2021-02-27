--[[
  NOTE: This handler is left for historical purposes, it's doubtful that it
  still works.
]]

local core = require "jester.core"

local _M = {}

local http = require("socket.http")
local ltn12 = require("ltn12")
local cjson = require("cjson")

--[[
  Speech to text using Google's API.
]]
function _M.speech_to_text_from_file_google(action, attributes)
  local status = 1
  local translations = {}

  local response = {}

  local body, status_code, headers, status_description = http.request({
    method = "POST",
    headers = {
      ["content-length"] = attributes.filesize,
      ["content-type"] = "audio/x-flac; rate=8000",
    },
    url = "http://www.google.com/speech-api/v2/recognize?xjerr=1&client=chromium&lang=en-US",
    sink = ltn12.sink.table(response),
    source = ltn12.source.file(attributes.file),
  })

  if status_code == 200 then
    local response_string = table.concat(response)
    core.log.debug("Google API server response: %s", response_string)
    local data = cjson.decode(response_string)
    status = data.status
    if status == 0 and data.hypotheses then
      for k, chunk in ipairs(data.hypotheses) do
        translations[k] = {}
        translations[k].text = chunk.utterance
        translations[k].confidence = chunk.confidence
      end
    end
  else
    core.log.debug("ERROR: Request to Google API server failed: %s", status_description)
  end

  return status, translations
end

return _M
