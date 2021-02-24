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

local function check_filepath(filepath)
  if filepath then
    return true
  else
    return false, "ERROR: Missing filepath"
  end
end

local function load_file(arguments)
  local filepath = arguments.filepath
  local file_type = arguments.file_type or DEFAULT_FILE_TYPE
  local content_length
  local file, data = load_file(filepath)
  if file then
    local attributes = {
      file = file,
      file_type = file_type,
      content_length = data.filesize
    }
    return file, data
  else
    return false, string.format([[ERROR: could not open '%s': %s]], filepath, data)
  end
end

local function parse_response(handler, data)
  local success, data = handler.parse_transcriptions(data)
  if success then
    return success, data
  else
    return false, string.format([[ERROR: Parsing Speech to Text API response failed: %s]], data)
  end
end

local function make_request_using_handler(handler, arguments, attributes)
  local success, data = handler.make_request(arguments, attributes)
  if success then
    return parse_response(handler, data)
  else
    return false, string.format([[ERROR: Speech to Text API failed: %s]], data)
  end
end

local function make_request(arguments, handler)
  local success, data = load_file(arguments)
  if success then
    success, data = make_request_using_handler(handler, arguments, data)
  end
  return success, data
end

local function retry_wait(arguments, attempt)
  local retries = arguments.retries or DEFAULT_RETRIES
  local retry_wait_seconds = arguments.retry_wait_seconds or DEFAULT_RETRY_WAIT_SECONDS
  if attempt < retries then
    core.debug_log([[ERROR: Attempt #%d failed, re-trying Speech to Text API in %d seconds]], attempt, retry_wait_seconds)
    socket.sleep(retry_wait_seconds)
  end
end

local function make_request_with_retry(arguments, handler)
  local success, data
  for attempt = 1, retries do
    success, data = make_request(arguments, handler)
    if success then
      break
    else
      retry_wait(arguments, attempt)
    end
  end
  return success, data
end

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
  local success, data = check_filepath(arguments.filepath)
  if success then
    handler = handler or DEFAULT_HANDLER
    success, data = make_request_with_retry(arguments, handler)
  end
  return success, data
end

return _M
