--- Speech to text translation support functions.
--
-- This module provides support functions for speech to text translation.
--
-- @module speech_to_text_support
-- @author Chad Phillips
-- @copyright 2011-2021 Chad Phillips

function set_start_end_timestamps(params)
  params.start_timestamp = params.start_timestamp and tonumber(params.start_timestamp) or os.time()
  if not params.end_timestamp and params.timeout_seconds then
    params.end_timestamp = params.start_timestamp + tonumber(params.timeout_seconds)
  end
  return params
end

function format_timeout_message(timestamp)
  return string.format([[Request timed out at: %s]], os.date("!%Y-%m-%dT%TZ", timestamp))
end
