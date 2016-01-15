--- Track various states in the channel.
--
-- This module provides actions to assist in tracking various states in a
-- channel.
--
-- @module tracker
-- @author Chad Phillips
-- @copyright 2011-2015 Chad Phillips


--- Incremental custom variable counter.
--
-- This action provides a simple method to keep a count of any arbitrary value,
-- and provides access to calling sequences by comparing a number against the
-- total in the counter.  It's useful for storing how many times you've done
-- something, eg. on 3rd failed login attempt, hang up.  Counters are
-- initialized with a value of zero, and placed in storage area 'counter'.
--
-- @action counter
-- @string action
--   counter
-- @int compare_to
--   (Optional) The value to compare the current counter value against.
-- @string if_equal
--   (Optional) The sequence to call if the counter value is equal to the
--   'compare_to' value.
-- @string if_greater
--   (Optional) The sequence to call if the counter value is greater than the
--   'compare_to' value.
-- @string if_less
--   (Optional) The sequence to call if the counter value is less than the
--   'compare_to' value.
-- @int increment
--   (Optional) Increment the counter by this amount before performing the
--   comparison to the 'compare_to' parameter.  Negative increments are allowed.
--   Default is 1. To disable counting, set this to 0.
-- @bool reset
--   (Optional) Set to true to reset the counter to zero.  This happens before
--   any incrementing, so it can be used with incrementing to set a new initial
--   value for the counter.
-- @string storage_key
--   (Optional) The key in the 'counter' storage area where the counter value is
--   stored and checked.  Default is 'counter'
-- @usage
--   {
--     action = "counter",
--     compare_to = profile.max_login_attempts,
--     if_equal = "one_more_try",
--     if_greater = "mailbox_login_failed",
--     if_less = "login",
--     increment = 1,
--     reset = false,
--     storage_key = "failed_login_counter",
--   }


local core = require "jester.core"

local _M = {}

--[[
  Incremental counter that compares the value of the counter against another
  value, and optionally run sequences based on the comparison.
]]
function _M.counter(action)
  local key = action.storage_key or "counter"
  local increment = action.increment and tonumber(action.increment) or 1
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
  if increment ~= 0 then
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
