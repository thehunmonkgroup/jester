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
-- @copyright 2011-2021 Chad Phillips


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


require "jester.support.file"

local socket = require "socket"
local core = require "jester.core"

local DEFAULT_HANDLER = require("jester.modules.speech_to_text.watson")
local DEFAULT_RETRIES = 3
local DEFAULT_RETRY_WAIT_SECONDS = 60
local DEFAULT_FILE_TYPE = "audio/wav"

local _M = {}

--- Translates a sound file to text.
--
-- @string api_key
--   (Optional) The API key used to access the service.
-- @string filepath
--   The full path to the file to translate.
-- @usage
--   {
--     api_key = profile.speech_to_text_app_key,
--     filepath = "/tmp/foo.wav",
--     storage_area = "foo_to_text",
--   }
function _M.speech_to_text_from_file(arguments, handler)

  local filepath = arguments.filepath
  local file_type = arguments.file_type or DEFAULT_FILE_TYPE
  handler = handler or DEFAULT_HANDLER
  local status = 1
  local transcriptions = {}
  if filepath then
    for i = 1, retries do
      local content_length
      local file, data = load_file(filepath)
      if file then
        local attributes = {
          file = file,
          file_type = file_type,
          content_length = data.filesize
        }
        local success, data = handler.make_request(arguments, attributes)
        if success then
          success, data = handler.parse_transcriptions(data)
          if success then
            status = 0
            transcriptions = data
            return status, transcriptions
          else
            core.debug_log("ERROR: Parsing Speech to Text API response failed: %s", data)
          end
        else
          core.debug_log([[ERROR: Speech to Text API attempt #%d failed: %s]], i, data)
        end
      else
        core.debug_log("ERROR: could not open '%s': %s", filepath, data)
      end
      if i < retries then
        core.debug_log([[ERROR: Re-trying Speech to Text API in %d seconds]], retry_wait_seconds)
        socket.sleep(retry_wait_seconds)
      end
    end
  else
    core.debug_log("ERROR: Missing filepath")
  end
  return status, transcriptions
end

return _M
