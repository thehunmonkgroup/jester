module(..., package.seeall)

--[[
  Dummy action.
]]
function none(action) end

--[[
  Call a sequence.
]]
function call_sequence(action)
  if action.sequence then
    jester.queue_sequence(action.sequence)
  end
end

--[[
  Compare two values, and optionally call sequences if they match or not.
]]
function conditional(action)
  local value = action.value
  local compare_to = action.compare_to
  local operator = action.comparison or "equal"
  local if_true = action.if_true
  local if_false = action.if_false
  if value and compare_to then
    jester.debug_log("Comparing '%s' to '%s' using comparison method '%s'", tostring(value), tostring(compare_to), operator)
    local match
    if operator == "equal" then
      match = value == compare_to
    elseif operator == "match" then
      match = string.match(value, compare_to) or false
    end
    if match == nil then
      jester.debug_log("Invalid comparison operator")
    elseif match == false then
      jester.debug_log("Comparison result: false")
      if if_false then
        jester.queue_sequence(if_false)
      end
    else
      jester.debug_log("Comparison result: true")
      if if_true then
        jester.queue_sequence(if_true)
      end
    end
  end
end

--[[
  Set channel variables.
]]
function set_variable(action)
  local data = action.data or {}
  for k, v in pairs(data) do
    jester.set_variable(k, v)
  end
end

--[[
  Set storage variables.
]]
function set_storage(action)
  local area = action.storage_area or "default"
  local data = action.data or {}
  for k, v in pairs(data) do
    jester.set_storage(area, k, v)
  end
end

--[[
  Copy storage from one area to another.
]]
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

--[[
  Clear a storage key or storage area.
]]
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

--[[
  Register a sequence to run in the exit sequence loop.
]]
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

--[[
  Wait for a specified amount of time.
]]
function wait(action)
  local milliseconds = action.milliseconds
  if milliseconds then
    jester.wait(milliseconds)
  end
end

--[[
  Load another profile.
]]
function load_profile(action)
  local profile = action.profile
  local sequence = action.sequence
  if profile then
    -- Copy in new initial args here if a sequence is going to be called, so
    -- profile has access to them.
    if sequence then
      local s_type, sequence_name, sequence_args = jester.parse_sequence(sequence)
      jester.initial_args = jester.parse_args(sequence_args)
    end
    jester.init_profile(profile)
    jester.init_modules(jester.conf.modules)
    if sequence then
      jester.queue_sequence(sequence)
    end
  end
end

--[[
  Execute a FreeSWITCH API command.
]]
function api_command(action)
  local command = action.command
  local key = action.storage_key or "result"
  if command then
    jester.debug_log("Executing API command: %s", command)
    local api = freeswitch.API()
    local result = api:executeString(command)
    -- Remove final carriage return from result.
    result = string.sub(result, 1, -2)
    jester.debug_log("Command result: %s", result)
    jester.set_storage("api_command", key, result)
  end
end

