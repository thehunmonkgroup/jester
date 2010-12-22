module(..., package.seeall)

function none(action) end

function call_sequence(action)
  if action.sequence then
    jester.queue_sequence(action.sequence)
  end
end

function conditional(action)
  local value = action.value
  local compare_to = action.compare_to
  local operator = action.comparison or "equal"
  if value and compare_to then
    jester.debug_log("Comparing '%s' to '%s' using comparison method '%s'", tostring(value), tostring(compare_to), operator)
    local match
    if operator == "equal" then
      match = value == compare_to
    elseif operator == "not_equal" then
      match = value ~= compare_to
    elseif operator == "match" then
      match = string.match(value, compare_to) or false
    elseif operator == "no_match" then
      match = not string.match(value, compare_to)
    end
    if match == nil then
      jester.debug_log("Invalid comparison operator")
    elseif match == false then
      jester.debug_log("Comparison result: false")
      if action.if_false then
        jester.queue_sequence(action.if_false)
      end
    else
      jester.debug_log("Comparison result: true")
      if action.if_true then
        jester.queue_sequence(action.if_true)
      end
    end
  end
end

function set_variable(action)
  local data = action.data or {}
  for k, v in pairs(data) do
    jester.set_variable(k, v)
  end
end

function set_storage(action)
  local area = action.storage_area or "default"
  local data = action.data or {}
  for k, v in pairs(data) do
    jester.set_storage(area, k, v)
  end
end

function copy_storage(action)
  local area = action.storage_area or "default"
  local copy_area = action.copy_to
  local move = action.move
  if copy_area then
    -- Clear out the copy area before copying.
    jester.clear_storage(copy_area)
    jester.debug_log("Copying data from area '%s' to area '%s'", area, copy_area)
    for k, v in pairs(jester.channel.storage[area]) do
      -- Only copy basic data types, others will not copy reliably.
      if type(v) == "string" or type(v) == "number" or type(v) == "boolean" then
        jester.set_storage(copy_area, k, v)
      end
    end
    if move then
      jester.clear_storage(area)
    end
  end
end

function clear_storage(action)
  local area = action.storage_area or "default"
  local data_keys = action.data_keys
  if data_keys then
    if type(data_keys) == "table" then
      for _, v in ipairs(data_keys) do
        jester.clear_storage(area, v)
      end
    end
  else
    jester.clear_storage(area)
  end
end

function register_exit_sequence(action)
  local sequence = action.sequence
  if sequence then
    local event = {}
    event.event_type = "sequence"
    event.sequence = sequence
    table.insert(jester.channel.stack.exit, event) 
    jester.debug_log("Registered exit sequence: %s", sequence)
  end
end

function wait(action)
  local milliseconds = action.milliseconds
  if milliseconds then
    jester.wait(milliseconds)
  end
end

