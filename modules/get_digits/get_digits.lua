module(..., package.seeall)

--[[
  Gets digit input from the user.
]]
function get_digits(action)
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
  jester.debug_log("Got digits: %s", digits)
  jester.set_storage("get_digits", key, digits)
end

--[[
  Set the digit length to the length of the passed string if prefixed with the
  length operator.
]]
function set_digit_length(digit_length)
  if type(digit_length) == "string" and string.sub(digit_length, 1, 1) == ":" then
    digit_length = string.len(digit_length) - 1
  end
  return digit_length
end

