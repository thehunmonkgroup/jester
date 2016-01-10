local core = require "jester.core"

local _M = {}

--[[
  Formats a number according to the supplied mask.
]]
function _M.format_number(action)
  local number = action.number and tostring(action.number)
  local mask = action.mask
  local key = action.storage_key or "number"
  if number then
    local formatted_number = ''
    if mask and mask ~= "" then
      local pos = 1
      local number_placeholder, mask_placeholder
      for i = 1, string.len(mask) do
        number_placeholder = string.sub(number, pos, pos)
        mask_placeholder = string.sub(mask, i, i)
        -- Skip digit placeholder, increment to the next phone digit if it
        -- exists.
        if mask_placeholder == '!' and number_placeholder then
          pos = pos + 1;
        -- Number placeholder, insert the next digit if it exists.
        elseif mask_placeholder == '_' and number_placeholder then
          formatted_number = formatted_number .. number_placeholder
          pos = pos + 1;
        -- Non-placeholder, output directly.
        else
          formatted_number = formatted_number .. mask_placeholder
        end
      end
      -- Extra digits get output at the end if they exist.
      if string.len(number) > pos - 1 then
        formatted_number = formatted_number .. string.sub(number, pos)
      end
    else
      formatted_number = number
    end
    core.debug_log("Formatted number '%s' to '%s'", number, formatted_number)
    core.set_storage("format", key, formatted_number)
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
