local core = require "jester.core"

local _M = {}

--[[
  Dummy action.
]]
function _M.none(action) end

--[[
  Call a sequence.
]]
function _M.call_sequence(action)
  if action.sequence then
    core.queue_sequence(action.sequence)
  end
end

--[[
  Compare two values, and optionally call sequences if they match or not.
]]
function _M.conditional(action)
  local value = action.value
  local compare_to = action.compare_to
  local operator = action.comparison or "equal"
  local if_true = action.if_true
  local if_false = action.if_false
  if value and compare_to then
    core.debug_log("Comparing '%s' to '%s' using comparison method '%s'", tostring(value), tostring(compare_to), operator)
    local match
    if operator == "equal" then
      match = value == compare_to
    elseif operator == "match" then
      match = string.match(value, compare_to) or false
    elseif operator == "greater_than" then
      match = value > compare_to
    elseif operator == "less_than" then
      match = value < compare_to
    end
    if match == nil then
      core.debug_log("Invalid comparison operator")
    elseif match == false then
      core.debug_log("Comparison result: false")
      if if_false then
        core.queue_sequence(if_false)
      end
    else
      core.debug_log("Comparison result: true")
      if if_true then
        core.queue_sequence(if_true)
      end
    end
  end
end

--[[
  Set channel variables.
]]
function _M.set_variable(action)
  local data = action.data or {}
  for k, v in pairs(data) do
    core.set_variable(k, v)
  end
end

--[[
  Set storage variables.
]]
function _M.set_storage(action)
  local area = action.storage_area or "default"
  local data = action.data or {}
  for k, v in pairs(data) do
    core.set_storage(area, k, v)
  end
end

--[[
  Copy storage from one area to another.
]]
function _M.copy_storage(action)
  local area = action.storage_area or "default"
  local copy_area = action.copy_to
  local move = action.move
  if copy_area then
    -- Clear out the copy area before copying.
    core.clear_storage(copy_area)
    core.debug_log("Copying data from area '%s' to area '%s'", area, copy_area)
    for k, v in pairs(core.channel.storage[area]) do
      -- Only copy basic data types, others will not copy reliably.
      if type(v) == "string" or type(v) == "number" or type(v) == "boolean" then
        core.set_storage(copy_area, k, v)
      end
    end
    if move then
      core.clear_storage(area)
    end
  end
end

--[[
  Clear a storage key or storage area.
]]
function _M.clear_storage(action)
  local area = action.storage_area or "default"
  local data_keys = action.data_keys
  if data_keys then
    if type(data_keys) == "table" then
      for _, v in ipairs(data_keys) do
        core.clear_storage(area, v)
      end
    end
  else
    core.clear_storage(area)
  end
end

--[[
  Register a sequence to run in the exit sequence loop.
]]
function _M.register_exit_sequence(action)
  local sequence = action.sequence
  if sequence then
    local event = {}
    event.event_type = "sequence"
    event.sequence = sequence
    table.insert(core.channel.stack.exit, event)
    core.debug_log("Registered exit sequence: %s", sequence)
  end
end

--[[
  Wait for a specified amount of time.
]]
function _M.wait(action)
  local milliseconds = action.milliseconds
  if milliseconds then
    core.wait(milliseconds)
  end
end

--[[
  Load another profile.
]]
function _M.load_profile(action)
  local profile = action.profile
  local sequence = action.sequence
  if profile then
    -- Copy in new initial args here if a sequence is going to be called, so
    -- profile has access to them.
    if sequence then
      local s_type, sequence_name, sequence_args = core.parse_sequence(sequence)
      core.initial_args = core.parse_args(sequence_args)
    end
    core.init_profile(profile)
    core.init_modules(core.conf.modules)
    if sequence then
      core.queue_sequence(sequence)
    end
  end
end

--[[
  Execute a FreeSWITCH API command.
]]
function _M.api_command(action)
  local command = action.command
  local key = action.storage_key or "result"
  if command then
    core.debug_log("Executing API command: %s", command)
    local api = freeswitch.API()
    local result = api:executeString(command)
    -- Remove final carriage return from result.
    result = string.sub(result, 1, -2)
    core.debug_log("Command result: %s", result)
    core.set_storage("api_command", key, result)
  end
end

return _M
