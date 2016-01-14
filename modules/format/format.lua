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
