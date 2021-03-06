--- Speech to text translation.
--
-- This module provides speech to text translation. Specific services are
-- supported by the various handlers:
--
-- @{speech_to_text_watson_handler|Watson Speech to Text API}
--
-- The module requires the Lua
-- [lua-cjson](https://luarocks.org/modules/luarocks/lua-cjson) and
-- [luasec](https://luarocks.org/modules/brunoos/luasec) packages.
--
-- @module speech_to_text
-- @author Chad Phillips
-- @copyright 2011-2021 Chad Phillips

--- Parameters used to configure the speech to text request.
--
-- These are common to all handlers, see the specific handler for additional
-- parameters.
--
-- @table params
--
-- @field retries
--   Number of times to try the request.
-- @field retry_wait_seconds
--   Number of seconds to wait between retries.

--- Attributes passed to handlers.
--
-- These are attributes calculated by the speech_to_text module, and passed to
-- handlers.
--
-- @table attributes
--
-- @field file
--   The opened file object for the filepath being transcribed.
-- @field file_type
--   Mime type of the file, default "audio/wav".
-- @field content_length
--   File size in bytes.

require "jester.support.file"

local socket = require "socket"
local core = require "jester.core"

local DEFAULT_HANDLER = require("jester.modules.speech_to_text.watson")
local DEFAULT_RETRIES = 3
local DEFAULT_RETRY_WAIT_SECONDS = 60
local DEFAULT_FILE_TYPE = "audio/wav"

local _M = {}

local function load_file_attributes(params)
  local filepath = params.filepath
  if not filepath then
    return true
  end
  local file_type = params.file_type or DEFAULT_FILE_TYPE
  local content_length
  local file, data = load_file(filepath)
  if file then
    local dirname, basename, ext = filepath_elements(filepath)
    local attributes = {
      file = file,
      file_type = file_type,
      content_length = data.filesize,
      dirname = dirname,
      basename = basename,
      ext = ext,
    }
    return file, attributes
  else
    local message = string.format([[ERROR: could not open '%s': %s]], filepath, data)
    core.log.err(message)
    return false, message
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

local function make_request_using_handler(handler, params, attributes)
  local success, data = handler.make_request(params, attributes)
  if success then
    return parse_response(handler, data)
  else
    return false, string.format([[ERROR: Speech to Text API failed: %s]], data)
  end
end

local function make_request(params, handler)
  local success, data = load_file_attributes(params)
  if success then
    success, data = make_request_using_handler(handler, params, data)
  end
  return success, data
end

local function retry_wait(params, attempt)
  local retries = params.retries or DEFAULT_RETRIES
  local retry_wait_seconds = params.retry_wait_seconds or DEFAULT_RETRY_WAIT_SECONDS
  if attempt < retries then
    core.log.debug([[ERROR: Attempt #%d failed, re-trying Speech to Text API in %d seconds]], attempt, retry_wait_seconds)
    socket.sleep(retry_wait_seconds)
  end
end

local function make_request_with_retry(params, handler)
  local success, data
  local retries = params.retries or DEFAULT_RETRIES
  for attempt = 1, retries do
    success, data = make_request(params, handler)
    if success then
      break
    else
      retry_wait(params, attempt)
    end
  end
  return success, data
end

--- Translates a sound file to text.
--
-- @tab params
--   Method params, see @{params}.
-- @tab handler
--   Speech to text handler module.
-- @treturn bool success
--   Indicates if operation succeeded.
-- @return data
--   Table of transcriptions on success, error message on fail.
-- @usage
--   params = {
--     api_key = "some_api_key",
--     filepath = "/tmp/foo.wav",
--     -- other params...
--   }
--   handler = require "jester.modules.speech_to_text.watson"
--   success, data = speech_to_text_from_file(params, handler)
function _M.speech_to_text_from_file(params, handler)
  handler = handler or DEFAULT_HANDLER
  local success, data = make_request_with_retry(params, handler)
  return success, data
end

return _M
