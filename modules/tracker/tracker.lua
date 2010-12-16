module(..., package.seeall)

function counter(action)
  local key = action.storage_key or "counter"
  local increment = action.increment and tonumber(action.increment) or nil
  local compare_to = action.compare_to and tonumber(action.compare_to) or nil
  -- Perform reset first to allow increment to be used to set the initial
  -- value of the counter.
  if action.reset then jester.clear_storage("counter", key) end
  local current_count = jester.get_storage("counter", key)
  if not current_count then
    current_count = 0
    jester.set_storage("counter", key, current_count)
  end
  if increment then
    current_count = current_count + increment
    jester.debug_log("Incremented counter '%s' by %d, new value %d", key, increment, current_count)
    jester.set_storage("counter", key, current_count)
  end
  if compare_to then
    jester.debug_log("Comparing counter '%s' (%d) to %d", key, current_count, compare_to)
    if current_count == compare_to then
      jester.debug_log("Comparison result: equal")
      if action.if_equal then
        jester.run_sequence(action.if_equal)
      end
    elseif current_count < compare_to then
      jester.debug_log("Comparison result: less")
      if action.if_less then
        jester.run_sequence(action.if_less)
      end
    else
      jester.debug_log("Comparison result: greater")
      if action.if_greater then
        jester.run_sequence(action.if_greater)
      end
    end
  end
end

