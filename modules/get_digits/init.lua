--- Collect user input from the channel.
--
-- This module provides actions for collecting user input from a channel, in the
-- form of DTMF key presses.
--
-- @module get_digits
-- @author Chad Phillips
-- @copyright 2011-2015 Chad Phillips


--- Flush DTMF in the session.
--
-- This action flushes any pending DTMF in the session.
--
-- @action flush_digits
-- @string action
--   flush_digits
-- @usage
--   {
--     action = "flush_digits",
--   }


--- Collect user input from the channel.
--
-- This action collects user input from a channel, in the form of DTMF key
-- presses, and stores the collected digits in the 'get_digits' storage area.
-- Note that if no user input is collected, or validation fails, an empty string
-- is saved to the storage area instead.
--
-- @action get_digits
-- @string action
--   get_digits
-- @tab audio_files
--   A file or files to play to the user during collection. Playback is
--   terminated when the user enters the first key. Usually used to give the
--   user instructions on what to enter. Provide either a single file as a
--   string, or multiple files in a table. The default is to play nothing.
-- @string bad_input
--   (Optional) An audio file to play to the user when input validation fails.
--   Default is 'ivr/ivr-that\_was\_an\_invalid\_entry.wav'.
-- @string digits_regex
--   (Optional) A regular expression to use for validating the user input. If
--   the user input does not match the expression, then validation fails. The
--   regex is in the same form as the regular expressions used in the FreeSWITCH
--   dialplan. Default is '<code>\\d+</code>', which matches one or more digits.
--   Note: If you need to match the * key in the regex, you will have to escape
--   it twice, as in '<code>\\d+|\\*</code>'.
-- @int max_digits
--   (Optional) The maximum number of digits to collect. Default is 10.
--   Alternatively, a string prefixed with a colon can be passed, and the length
--   of the string will be used to set the value.
-- @int max_tries
--   (Optional) The maximum amount of times that validation will fail before
--   giving up. Default is 3.
-- @int min_digits
--   (Optional) The minimum number of digits to collect. Default is 1.
--   Alternatively, a string prefixed with a colon can be passed, and the length
--   of the string will be used to set the value.
-- @string storage_key
--   (Optional) The key to store the collected digits under in the 'get_digits'
--   storage area. Default is 'digits'.
-- @string terminators
--   (Optional) A string of keys that the user can use to end the collection
--   before the timeout. Multiple values keys can be used, eg. '\*' or '\*#'. To
--   accept no terminators, pass an empty string. Default is '#'.
-- @int timeout
--   (Optional) Number of seconds to wait for max_digits before trying to
--   validate. Default is 3.
-- @usage
--   {
--     action = "get_digits",
--     audio_files = {
--       "phrase:extension",
--       "/path/to/another/file.wav",
--     },
--     bad_input = "ivr/ivr-that_was_an_invalid_entry.wav",
--     digits_regex = "\\d+'",
--     max_digits = 8,
--     max_tries = 3,
--     min_digits = 3,
--     storage_key = "extension",
--     terminators = "#*",
--     timeout = 3,
--   },


local core = require "jester.core"

local _M = {}

--[[
  Set the digit length to the length of the passed string if prefixed with the
  length operator.
]]
local function set_digit_length(digit_length)
  if type(digit_length) == "string" and string.sub(digit_length, 1, 1) == ":" then
    digit_length = string.len(digit_length) - 1
  end
  return digit_length
end

--[[
  Gets digit input from the user.
]]
function _M.get_digits(action)
  local min_digits = action.min_digits
  local max_digits = action.max_digits
  if min_digits then
    min_digits = set_digit_length(min_digits)
  else
    min_digits = 1
  end
  if max_digits then
    max_digits = set_digit_length(max_digits)
  else
    max_digits = 10
  end
  local max_tries = action.max_tries or 3
  local timeout = action.timeout and (action.timeout * 1000) or 3000
  local terminators = action.terminators or "#"
  local audio_files = action.audio_files or ""
  -- A list of files was passed, concat them to play in order.
  if type(audio_files) == "table" then
    audio_files = table.concat(audio_files, "!")
  end
  local bad_input = action.bad_input or "ivr/ivr-that_was_an_invalid_entry.wav"
  local digits_regex = action.digits_regex or "\\d+"
  local key = action.storage_key or "digits"
  local digits = session:playAndGetDigits(min_digits, max_digits, max_tries, timeout, terminators, audio_files, bad_input, digits_regex)
  core.log.debug("Got digits: %s", digits)
  core.set_storage("get_digits", key, digits)
end

function _M.flush_digits()
  session:flushDigits()
  core.log.debug("Flushing Digits")
end

return _M
