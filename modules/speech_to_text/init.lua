--- Speech to text translation (experimental).
--
-- **WARNING:** totally experimental, no guarantees it will work!
--
-- This module provides speech to text translation.
--
-- The module requires the Lua
-- [lua-cjson](https://luarocks.org/modules/luarocks/lua-cjson) and
-- [luasec](https://luarocks.org/modules/brunoos/luasec) packages.
--
-- @module speech_to_text
-- @author Chad Phillips
-- @copyright 2011-2018 Chad Phillips


--- The Watson handler (default).
--
--  Uses Watson's Speech to Text service. The service requires a valid developer
--  account and api key, see
--  [here](https://cloud.ibm.com/catalog/services/speech-to-text) for more information.
--
-- @handler watson
-- @usage
--   {
--     action = "speech_to_text_from_file",
--     handler = "watson",
--     -- ...other required params...
--     service_uri = "[obtain from service]",
--     -- ...other optional params...
--     query_parameters = {
--       -- key/value pairs to pass as query parameters
--     },
--     retries = 3,
--     retry_wait_seconds = 60,
--   }


--- Speech to text storage.
--
-- Translations are stored in the specified storage area with the following
-- keys, where <code>X</code> is the chunk number:
--
-- A 'status' key is also placed in the storage area, indicating the result of
-- the translation. A value of 0 indicates the translation was successful.
--
-- @table speech_to_text
--
-- @field translation_X
--   The translated text for the chunk.
-- @field confidence_X
--   The confidence level of the translated chunk, a decimal number in the
--   range of 0 to 1.


--- Translates a sound file to text.
--
-- This action requires that [flac](https://xiph.org/flac) is installed and
-- executable by FreeSWITCH.
--
-- @action speech_to_text_from_file
-- @string action
--   speech\_to\_text\_from\_file
-- @string api_key
--   (Optional) The API key used to access the service.
-- @string filepath
--   The full path to the file to translate.
-- @string storage_area
--   (Optional) The storage area to store the response in. Defaults to
--   'speech\_to\_text'.
-- @usage
--   {
--     action = "speech_to_text_from_file",
--     api_key = profile.speech_to_text_app_key,
--     filepath = "/tmp/foo.wav",
--     storage_area = "foo_to_text",
--   }


local core = require "jester.core"

local io = require("io")
local lfs = require("lfs")
require "jester.support.file"

--local google = require("jester.modules.speech_to_text.google")
--local att = require("jester.modules.speech_to_text.att")
local watson = require("jester.modules.speech_to_text.watson")

local _M = {}

--[[
  Speech to text base function.

  This function wraps the handler's specific functionaliy.
]]
local function speech_to_text_from_file(action, handler)
  local filepath = action.filepath
  local area = action.storage_area or "speech_to_text"

  if filepath then
    -- Verify file exists.
    local success, file_error = lfs.attributes(filepath, "mode")
    if success then
      local file = io.open(filepath, "rb")
      local filesize = (filesize(file))
      local attributes = {
        file = file,
        filesize = filesize,
      }
      status, translations = handler(action, attributes)
      core.set_storage(area, "status", status)
      for k, translation in ipairs(translations) do
        core.set_storage(area, "translation_" .. k, translation.text)
        core.set_storage(area, "confidence_" .. k, translation.confidence)
      end
    else
      core.debug_log("ERROR: File %s does not exist", filepath)
    end
  end
end

--[[
  Speech to text using Google's API.
]]
--function speech_to_text_from_file_google(action)
--  speech_to_text_from_file(action, google.speech_to_text_from_file)
--end

--[[
  Speech to text using AT&T's API.
]]
--function _M.speech_to_text_from_file_att(action)
--  speech_to_text_from_file(action, att.speech_to_text_from_file)
--end

--[[
  Speech to text using Watson's API.
]]
function _M.speech_to_text_from_file_watson(action)
  speech_to_text_from_file(action, watson.speech_to_text_from_file)
end

return _M
