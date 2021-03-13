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

require "jester.modules.speech_to_text.support"

local socket = require "socket"
local core = require "jester.core"
core.bootstrap()

local LOG_PREFIX = "JESTER::MODULE::SPEECH_TO_TEXT"
local DEFAULT_CONTENT_TYPE = "audio/wav"
local DEFAULT_PARAMS = {
  retries = 3,
  retry_wait_seconds = 60,
}

local _M = {}

local function parse_response(self, data)
  local success, data = self.handler:parse_transcriptions(data)
  if success then
    return success, data
  else
    return false, string.format([[Parsing Speech to Text API response failed: %s]], data)
  end
end

local function make_request_using_handler(self, attributes)
  local success, data = self.handler:make_request(attributes)
  if success then
    return parse_response(self, data)
  else
    return false, string.format([[Speech to Text API failed: %s]], data)
  end
end

local function retry_wait(self, attempt)
  if attempt < self.params.retries then
    self.log.warning([[Attempt #%d failed, re-trying Speech to Text API in %d seconds]], attempt, self.params.retry_wait_seconds)
    socket.sleep(self.params.retry_wait_seconds)
  end
end

local function make_request_with_retry(self, file_params)
  local success, data
  for attempt = 1, self.params.retries do
    success, data = make_request_using_handler(self, file_params)
    if success then
      break
    else
      if self.params.end_timestamp and os.time() > self.params.end_timestamp then
        return false, stt_format_timeout_message(self.params.end_timestamp)
      end
      self.log.warning([[Request failed: %s]], data)
      retry_wait(self, attempt)
    end
  end
  return success, data
end

--- Translates a sound file to text.
--
-- @param file_params
--   Table of file parameters, as passed to @{speech_to_text_support.load_file_attributes}.
-- @treturn bool success
--   Indicates if operation succeeded.
-- @return data
--   Table of transcriptions on success, error message on fail.
-- @usage
--   local file_params = {
--     path = "/tmp/myfile.wav",
--   }
--   success, data = stt_obj:speech_to_text_from_file(file_params)
function _M:speech_to_text_from_file(file_params)
  self.params = stt_set_start_end_timestamps(self.params)
  local success, data = make_request_with_retry(self, file_params)
  return success, data
end

--- Create a new speech to text object.
--
-- @param self
-- @tab handler
--   Required. Speech to text handler module.
-- @param params
--   Optional. Table of configuration parameters.
-- @param params.retries
--   Number of times to try the request. Default is 3.
-- @param params.retry_wait_seconds
--   Number of seconds to wait between retries. Default is 60.
-- @param params.end_timestamp
--   Unix timestamp after which the request should time out. Default is no end
--   timestamp.
-- @param params.timeout_seconds
--   Number of seconds to wait before timing out the request. This can be
--   provided instead of end_timestamp, in which case end_timestamp will be
--   calculated by adding timeout_seconds to the current UNIX time of the request.
--   Default is no timeout.
-- @return A speech to text object.
-- @usage
--   stt = require("jester.modules.speech_to_text")
--   rev_ai = require("jester.modules.speech_to_text.rev_ai")
--   local handler_params = {
--     api_key = "some_api_key",
--     -- other params...
--   }
--   local handler = rev_ai:new(handler_params)
--   local stt_params = {
--     retries = 3,
--     -- other params...
--   }
--   stt_obj = stt:new(handler, stt_params)
function _M.new(self, handler, params)
  if not handler then
    error("Handler is required")
  end
  local stt = {}
  stt.handler = handler
  stt.params = table.merge(DEFAULT_PARAMS, params or {})
  stt.handler.params = stt_merge_params(stt.handler.params, stt.params)
  stt.log = core.logger({prefix = LOG_PREFIX})
  setmetatable(stt, self)
  self.__index = self
  stt.log.debug("New speech to text object")
  return stt
end

return _M
