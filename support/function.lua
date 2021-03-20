local socket = require "socket"
local core = require "jester.core"
core.bootstrap()

local LOG_PREFIX = "JESTER::SUPPORT::FUNCTION"

local log = core.logger({prefix = LOG_PREFIX})

--[[
  Issues a query against the database, retrying if failed.
]]
function call_function_with_retry(tries, retry_interval_seconds, func, ...)
  local name = debug.getinfo(func).name or "unamed"
  log.debug("Calling function '%s', %d tries left", name, tries)
  local data = { pcall(func, ...) }
  local success = table.remove(data, 1)
  if success then
    return unpack(data)
  else
    log.err("Failed call of function '%s', error: %s", name, data[1])
    tries = tries - 1
    if tries > 0 then
      log.err("Trying function '%s' call again in %d seconds", name, retry_interval_seconds)
      socket.sleep(retry_interval_seconds)
      return call_function_with_retry(tries, retry_interval_seconds, func, ...)
    else
      log.err("All tries on calling function '%s' exhausted, giving up", name)
    end
    return false
  end
end
