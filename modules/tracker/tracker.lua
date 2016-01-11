local core = require "jester.core"

local _M = {}

--[[
  Incremental counter that compares the value of the counter against another
  value, and optionally run sequences based on the comparison.
]]
function _M.counter(action)
  local key = action.storage_key or "counter"
  local increment = action.increment and tonumber(action.increment) or nil
  local compare_to = action.compare_to and tonumber(action.compare_to) or nil
  -- Perform reset first to allow increment to be used to set the initial
  -- value of the counter.
  if action.reset then core.clear_storage("counter", key) end
  -- Grab the current count.
  local current_count = core.get_storage("counter", key)
  -- No current count, so initialize with a zero value.
  if not current_count then
    current_count = 0
    core.set_storage("counter", key, current_count)
  end
  -- Increment the counter if specified.
  if increment then
    current_count = current_count + increment
    core.debug_log("Incremented counter '%s' by %d, new value %d", key, increment, current_count)
    core.set_storage("counter", key, current_count)
  end
  -- Perform comparisons if specified, and run sequences if there's a match.
  if compare_to then
    core.debug_log("Comparing counter '%s' (%d) to %d", key, current_count, compare_to)
    if current_count == compare_to then
      core.debug_log("Comparison result: equal")
      if action.if_equal then
        core.queue_sequence(action.if_equal)
      end
    elseif current_count < compare_to then
      core.debug_log("Comparison result: less")
      if action.if_less then
        core.queue_sequence(action.if_less)
      end
    else
      core.debug_log("Comparison result: greater")
      if action.if_greater then
        core.queue_sequence(action.if_greater)
      end
    end
  end
end

return _M
