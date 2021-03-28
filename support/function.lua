local socket = require "socket"
local core = require "jester.core"
core.bootstrap()

local LOG_PREFIX = "JESTER::SUPPORT::FUNCTION"

local log = core.logger({prefix = LOG_PREFIX})

--[[
  Issues a query against the database, retrying if failed.

  Function to call must return a non-nil value as the first return value for
  the call to be considered successful.

  If the function crashes, and error log is generated, if it returns nil,
  a debug log is generated, and the retry continues.
]]
function call_function_with_retry(tries, retry_interval_seconds, func, ...)
  local name = debug.getinfo(func).name or "unamed"
  log.debug("Calling function '%s', %d tries left", name, tries)
  local data = { pcall(func, ...) }
  local success = table.remove(data, 1)
  local first_return_value = data[1]
  if success and first_return_value ~= nil then
    return unpack(data)
  else
    if success then
      log.debug("Function '%s' returned nil, will retry", name)
    else
      log.err("Failed call of function '%s', error: %s", name, first_return_value)
    end
    tries = tries - 1
    if tries > 0 then
      log.debug("Trying function '%s' call again in %d seconds", name, retry_interval_seconds)
      socket.sleep(retry_interval_seconds)
      return call_function_with_retry(tries, retry_interval_seconds, func, ...)
    else
      log.err("All tries on calling function '%s' exhausted, giving up, error: %s, %s", name, first_return_value, debug.traceback())
    end
    return false
  end
end
