--- Actions provided by Jester core.
--
-- This module provides actions that are closely tied to the core functionality
-- of Jester.
--
-- @module core_actions
-- @author Chad Phillips
-- @copyright 2011-2015 Chad Phillips


--- Execute a FreeSWITCH API command.
--
-- This action allows you to execute a FreeSWITCH API command, as if from the
-- console command line. The command result is stored in the specified key.
--
-- @action api_command
-- @string action
--   api_command
-- @string command
--   The command to execute.
-- @string storage_key
--   (Optional) The key to store the command result under in the 'api_command'
--   storage area. Default is 'result'.
-- @usage
--   {
--     action = "api_command",
--     command = "uptime",
--     storage_key = "uptime_result",
--   }


--- Call a new sequence from the currently running sequence.
--
-- This action calls a new sequence from the currently running sequence.
--
-- @action call_sequence
-- @string action
--   call_sequence
-- @string sequence
--   The new sequence to call. By default the original sequence is not resumed
--   when the new sequence completes. To resume the old sequence (effectively
--   making the new sequence a subroutine of the original), prefix the sequence
--   with 'sub:'. See @{03-Sequences.md.Subroutines} for more information.
-- @usage
--   {
--     action = "call_sequence",
--     sequence = "foo_sequence arg1",
--   }
--   -- or...
--   {
--     action = "call_sequence",
--     sequence = "sub:foo_sequence arg1,arg2",
--   }


--- Remove storage values from a given storage area.
--
-- This action removes key/value pairs from the given storage area.
--
-- @action clear_storage
-- @string action
--   clear_storage
-- @tab data_keys
--   (Optional) A table of keys to remove from the storage area. If this
--   parameter is not given, then the entire storage area is cleared, use
--   caution!
-- @string storage_area
--   (Optional) The area to clear. Defaults to 'default'.
-- @usage
--   {
--     action = "clear_storage",
--     data_keys = {
--       "key1",
--       "key2",
--     },
--     storage_area = "someplace",
--   }


--- Call a new sequence based on a simple conditional check.
--
-- This action allows simple comparison of a value against another value, and
-- can call another sequence based on if the comparison returns true or false.
-- It's really only meant for fairly simple sequence logic -- for more complex
-- logic see @{03-Sequences.md.Advanced_tricks} for more information.
--
-- @action conditional
-- @string action
--   conditional
-- @string compare_to
--   The value that you expect it to be, or for pattern matching, any valid Lua
--   pattern (see the Lua manual for more information on Lua patterns).
-- @string comparison
--   (Optional) The kind of comparison to perform. Valid values are "equal",
--   "match", "greater\_than", and "less\_than". Default is "equal".
-- @string if_false
--   (Optional) The sequence to call if the comparison is false.
-- @string if_true
--   (Optional) The sequence to call if the comparison is true.
-- @string value
--   The value that you want to compare.
-- @usage
--   {
--     action = "conditional",
--     value = number_of_messages,
--     compare_to = 0,
--     comparison = "equal",
--     if_true = "exit",
--     if_false = "play_messages",
--   }
--   -- or...
--   {
--     action = "conditional",
--     value = name,
--     compare_to = "^bob",
--     comparison = "match",
--     if_true = "its_bob",
--     if_false = "not_bob",
--   }


--- Copy storage values from one storage area to another.
--
-- This action performs a complete copy of all keys in a storage area, placing
-- them in the specified new storage area. Note that only basic data types
-- (string, number, boolean) are copied -- all others are ignored.
--
-- @action copy_storage
-- @string action
--   copy_storage
-- @string copy_to
--   The storage area to copy the data to. Note that any data already existing
--   in this area will be removed prior to the copy.
-- @bool move
--   (Optional) If set to true, clears the data from the original storage area,
--   which effectively makes the operation a move. Default is false.
-- @string storage_area
--   (Optional) The area to copy. Defaults to 'default'.
-- @usage
--   {
--     action = "copy_storage",
--     copy_to = "new_place",
--     move = true,
--     storage_area = "old_place",
--   }


--- Registers a sequence to be executed on exit.
--
-- This action registers a sequence to be executed after Jester has finished
-- running all sequences related to the active call. Channel variables and
-- storage values are available when the registered sequence is run.
--
-- Sequences registered here are run before the sequences registered on hangup,
-- and are always run, regardless if the user actively hung up the call. If you
-- want to guarantee that the sequence will run regardless of user hangup, it's
-- best to put it here instead of in the hangup loop.
--
-- @action exit_sequence
-- @string action
--   exit_sequence
-- @string sequence
--   The sequence to execute.
-- @usage
--   {
--     action = "exit_sequence",
--     sequence = "perform_maintenance",
--   }
-- @see hangup.hangup_sequence


--- Load a profile dynamically.
--
-- This action allows you to load a profile dynamically from within a sequence.
-- This can be useful for loading a 'heavier' profile only when needed from
-- within a 'lighter' profile.
--
-- @action load_profile
-- @string action
--   load_profile
-- @string profile
--   The new profile to load.
-- @string sequence
--   (Optional) A sequence to execute after loading the profile. If this is
--   provided, any running sequences in the current loop will be discarded, and
--   this sequence will be run from the top of a new sequence stack.
-- @usage
--   {
--     action = "load_profile",
--     profile = "another_profile",
--     sequence = "start",
--   }


--- Dummy action which does nothing.
--
-- This action is just a placeholder. It can be used to skip taking any action,
-- or to provide a way to call another sequence without taking any other action.
--
-- @action none
-- @string action
--   none
-- @usage
--   {
--     action = "none",
--   }


--- Set storage values in a given storage area.
--
-- This action sets key/value pairs in the given storage area.
--
-- @action set_storage
-- @string action
--   set_storage
-- @tab data
--   A table of data to store in the storage area. Keys are the storage keys,
--   values are the storage values.
-- @string storage_area
--   (Optional) The area to store the value in. Defaults to 'default'.
-- @usage
--   {
--     action = "set_storage",
--     data = {
--       foo = "bar",
--       baz = "bang",
--     },
--     storage_area = "some_storage",
--   }


--- Set channel variables.
--
-- This action sets FreeSWITCH channel variables on the channel that Jester is
-- currently running.
--
-- @action set_variable
-- @string action
--   set_variable
-- @tab data
--   A table of channel variables to set. Keys are the variable
--   names, values are the variable values.
-- @usage
--   {
--     action = "set_variable",
--     data = {
--       foo = "bar",
--       baz = "bang",
--     },
--   }


--- Wait before performing the next action.
--
-- This action causes Jester to wait before continuing on. Silence is streamed
-- on the channel during the wait period.
--
-- @action wait
-- @string action
--   wait
-- @tab keys
--   (Optional) See @{03-Sequences.md.Capturing_user_key_input|keys} documentation.
-- @int milliseconds
--   The number of milliseconds to wait.
-- @usage
--   {
--     action = "wait",
--     keys = profile.some_keys_setting,
--     milliseconds = 3000,
--   }


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
