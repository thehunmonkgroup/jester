--[[
  NOTE: This handler is left for historical purposes, it's doubtful that it
  still works.
]]

local core = require "jester.core"

local _M = {}

--[[
  Get an access token from an AT&T API call.
]]
local function att_get_access_token(action)
  local app_key = action.app_key
  local app_secret = action.app_secret

  local post_data = string.format("client_id=%s&client_secret=%s&grant_type=client_credentials&scope=SPEECH,TTS", app_key, app_secret)

  local response = {}

  local body, status_code, headers, status_description = https.request({
    method = "POST",
    headers = {
      ["content-length"] = post_data:len(),
    },
    url = "https://api.att.com/oauth/v4/token",
    sink = ltn12.sink.table(response),
    source = ltn12.source.string(post_data),
    protocol = "tlsv1",
  })

  if status_code == 200 then
    local response_string = table.concat(response)
    core.log.debug("JSON response string '%s'", response_string)
    local data = cjson.decode(response_string)
    for key, value in pairs(data) do
      if key == "access_token" then
        return value
      end
    end
    core.log.debug("ERROR: No access token found")
  else
    core.log.debug("ERROR: Request to AT&T token server failed: %s", status_description)
  end
end

local https = require 'ssl.https'
local ltn12 = require("ltn12")
local cjson = require("cjson")

--[[
  Speech to text using AT&T's API.
]]
function _M.speech_to_text_from_file(action, attributes)
  local status = 1
  local translations = {}

  local access_token = att_get_access_token(action)

  if access_token then
    local response = {}

    local body, status_code, headers, status_description = https.request({
      method = "POST",
      headers = {
        ["content-length"] = attributes.filesize,
        ["content-type"] = "audio/x-wav",
        ["accept"] = "application/json",
        ["authorization"] = "Bearer " .. access_token,
      },
      url = "https://api.att.com/speech/v3/speechToText",
      sink = ltn12.sink.table(response),
      source = ltn12.source.file(attributes.file),
      protocol = "tlsv1",
    })

    if status_code == 200 then
      local response_string = table.concat(response)
      core.log.debug("JSON response string '%s'", response_string)
      local data = cjson.decode(response_string)
      status = data.Recognition.Status == "OK" and 0 or 1
      if status == 0 and type(data.Recognition.NBest) == "table" then
        for k, chunk in ipairs(data.Recognition.NBest) do
          translations[k] = {}
          translations[k].text = chunk.ResultText
          translations[k].confidence = chunk.Confidence
        end
      end
    else
      core.log.debug("ERROR: Request to AT&T API server failed: %s", status_description)
    end
  end

  return status, translations
end

return _M
