--- Custom formatters for sequences.
--
-- This module provides custom formatting functionality for sequences. It can
-- be used to alter the formatting of certain data within a sequence.
--
-- @module format
-- @author Chad Phillips
-- @copyright 2011-2015 Chad Phillips


--- Formats a Unix timestamp as a date string.
--
-- The format string is configurable, and timezones are supported. The
-- formatted result is placed in the 'format' storage area.
--
-- @action format_date
-- @string action
--   format_date
-- @string format
--   (Optional) The format string to use. Should be a string in the form taken
--   by [strftime](http://linux.die.net/man/3/strftime).
--   Default is '<code>%Y-%m-%d %H:%M:%S</code>'.
-- @string storage_key
--   (Optional) The key to store the formatted result under in the 'format'
--   storage area. Default is 'date'.
-- @int timestamp
--   The Unix timestamp to format.
-- @string timezone
--   (Optional) The timezone to use to calculate the time. This should be a
--   string that represents the [timezone name](https://en.wikipedia.org/wiki/Tz_database#Names_of_time_zones)
--   as found in server's timezone database (often in '/usr/share/zoneinfo').
--   Default is 'Etc/UTC'.
-- @usage
--   {
--     action = "format_date",
--     format = "%Y-%m-%d %H:%M:%S",
--     storage_key = "formatted_date",
--     timestamp = 1452792192,
--     timezone = "Etc/UTC",
--   },


--- Formats a string using a given mask.
--
-- The mask can be used to exclude specific characters, and to add additional
-- formatting.
--
-- A specific use case is formatting the number '+15555551212' into the more
-- readable '(555) 555-1212'. The formatted result is placed in the 'format'
-- storage area.
--
-- Note that currently, due to limitations in the parser, the string to be
-- formatted cannot contain any of the mask special placeholder characters,
-- see the 'mask' parameter below for those.
--
-- @action format_string
-- @string action
--   format_string
-- @string mask
--   (Optional) The mask to apply to the string. Default is to do no
--   formatting. The mask has two special placeholder characters, the
--   exclamation point and the underscore. To ignore a character, use the
--   exclamation point. To place a character, use the underscore.
-- @string string
--   The string to format.
-- @string storage_key
--   (Optional) The key to store the formatted result under in the 'format'
--   storage area. Default is 'formatted_string'.
-- @usage
--   {
--     action = "format_string",
--     mask = "!!(___) ___-____",
--     string = "+15555551212",
--     storage_key = "formatted_phone_number",
--   },


local core = require "jester.core"

local _M = {}

--[[
  Formats a string according to the supplied mask.
]]
function _M.format_string(action)
  local f_string = action.string and tostring(action.string)
  local mask = action.mask
  local key = action.storage_key or "formatted_string"
  if f_string then
    local formatted_string = ''
    if mask and mask ~= "" then
      local pos = 1
      local string_placeholder, mask_placeholder
      for i = 1, string.len(mask) do
        string_placeholder = string.sub(f_string, pos, pos)
        mask_placeholder = string.sub(mask, i, i)
        -- Skip character placeholder, increment to the next character if it
        -- exists.
        if mask_placeholder == '!' and string_placeholder then
          pos = pos + 1;
        -- Character placeholder, insert the next character if it exists.
        elseif mask_placeholder == '_' and string_placeholder then
          formatted_string = formatted_string .. string_placeholder
          pos = pos + 1;
        -- Non-placeholder, output directly.
        else
          formatted_string = formatted_string .. mask_placeholder
        end
      end
      -- Extra digits get output at the end if they exist.
      if string.len(f_string) > pos - 1 then
        formatted_string = formatted_string .. string.sub(f_string, pos)
      end
    else
      formatted_string = f_string
    end
    core.debug_log("Formatted string '%s' to '%s'", f_string, formatted_string)
    core.set_storage("format", key, formatted_string)
  end
end

--[[
  Formats a Unix timestamp as a date string, with timezone support.
]]
function _M.format_date(action)
  local timestamp = action.timestamp and tostring(action.timestamp)
  local timezone = action.timezone or "Etc/UTC"
  local format = action.format or "%Y-%m-%d %H:%M:%S"
  local key = action.storage_key or "date"
  if timestamp then
    local api = freeswitch.API()
    local command = string.format("strftime_tz %s %s|%s", timezone, timestamp, format)
    local formatted = api:executeString(command)
    core.debug_log("Formatted timestamp '%s' to '%s'", timestamp, formatted)
    core.set_storage("format", key, formatted)
  end
end

return _M
