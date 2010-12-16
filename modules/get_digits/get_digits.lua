module(..., package.seeall)

function get_digits(action)
  local min_digits = action.min_digits or 1
  local max_digits = action.max_digits or 10
  local max_tries = action.max_tries or 3
  local timeout = action.timeout and (action.timeout * 1000) or 3000
  local terminators = action.terminators or "#"
  local audio_files = action.audio_files or ""
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

