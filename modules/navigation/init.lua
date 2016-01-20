--- Menu/phone tree navigation.
--
-- This module provides actions that help with navigating menus and phone trees.
--
-- The actions in this module are most often used directly when responding to
-- user input, see @{03-Sequences.md.Capturing_user_key_input} for more
-- information.
--
-- @module navigation
-- @author Chad Phillips
-- @copyright 2011-2015 Chad Phillips


--- Add a sequence to the navigation path.
--
-- This action adds a sequence to the navigation path.  It can be used for
-- tracking when a channel moves deeper into a menu tree.  Adding a sequence to
-- the path allows for using the navigation actions to traverse through
-- previous additions to the path.
--
-- @action navigation_add
-- @string action
--   navigation_add
-- @string sequence
--   (Optional) The sequence to add to the path.  Defaults to the currently
--   running sequence.
-- @usage
--   {
--     action = "navigation_add",
--     sequence = "some_sequence",
--   }


--- Move to the beginning of the navigation path.
--
-- This action clears the navigation path, and executes the first item from the
-- old path, placing it at the beginning of the new path.  It can be used for
-- providing 'return to beginning' functionality in phone trees.
--
-- This action is most often used in the 'keys' array like so:
--
--    keys = {
--      ["9"] = "@navigation_beginning",
--    }
--
-- It can however be used in a regular sequence as well.
--
-- @action navigation_beginning
-- @string action
--   navigation_beginning
-- @usage
--   {
--     action = "navigation_beginning",
--   }


--- Clear the navigation path.
--
-- This action clears the navigation path.  No sequences will be left on the
-- path after this operation.
--
-- @action navigation_clear
-- @string action
--   navigation_clear
-- @usage
--   {
--     action = "navigation_clear",
--   }


--- Move to the previous item on the navigation path.
--
-- This action pops the current action off the navigation path, and executes
-- the previously added item in the path.  It can be used for providing
-- 'previous menu' functionality in phone trees.
--
-- This action is most often used in the 'keys' array like so:
--
--    keys = {
--      ["9"] = "@navigation_previous"
--    }
--
-- It can however be used in a regular sequence as well.
--
-- @action navigation_previous
-- @string action
--   navigation_previous
-- @usage
--   {
--     action = "navigation_previous",
--   }


--- Set the current sequence as the new navigation path beginning.
--
-- This action clears the navigation path, and sets the last item in the old
-- path to be the first item in the new path.  It can be used to set a new
-- beginning for the navigation path.
--
-- @action navigation_reset
-- @string action
--   navigation_reset
-- @usage
--   {
--     action = "navigation_reset",
--   }



local core = require "jester.core"

local _M = {}

--[[
  Initialize the navigation module.
]]
local function init()
  -- Initialize navigation stack.
  core.reset_stack("navigation")

  -- Register clearing the stack on hangup.
  local event = {}
  event.event_type = "action"
  event.action = {
    action = "navigation_clear",
    ad_hoc = true,
  }
  -- We want this to be cleared before any user hangup sequences/actions are
  -- run, so force it into first position.
  table.insert(core.channel.stack.exit, 1, event)
end

--[[
  Log the current navigation stack.
]]
local function show_navigation_stack(stack)
  core.debug_log("Current navigation stack: %s", table.concat(stack, " | "))
end

--[[
  Add a sequence to the navigation path.
]]
function _M.navigation_add(action)
  local stack = core.channel.stack.navigation
  local sequence_stack = core.channel.stack.sequence
  local p = core.channel.stack.sequence_stack_position
  -- Default to the currently running sequence.
  local sequence = action.sequence or (sequence_stack[p].name .. " " .. sequence_stack[p].args)
  -- Don't add to the stack if the last sequence on the stack is the same.
  if not (sequence == stack[#stack]) then
    table.insert(core.channel.stack.navigation, sequence)
    core.debug_log("Adding '%s' to navigation stack", sequence)
    show_navigation_stack(stack)
  end
end

--[[
  Go to the previous item in the navigation path.
]]
function _M.navigation_previous(action)
  local stack = core.channel.stack.navigation
  if #stack == 0 then
    core.debug_log("Cannnot navigate to previous item, path is empty!")
  else
    local last_sequence, new_sequence
    -- Remove the current sequence from the stack unless it's the only one.
    if #stack > 1 then
      last_sequence = table.remove(core.channel.stack.navigation)
    end
    -- Last item on the stack is now up one level.
    new_sequence = stack[#stack]
    core.debug_log("Moving to previous navigation item from sequence '%s' to sequence '%s'", tostring(last_sequence), new_sequence)
    show_navigation_stack(stack)
    core.queue_sequence(new_sequence)
  end
end

--[[
  Clear the navigation path.
]]
function _M.navigation_clear(action)
  core.channel.stack.navigation = {}
  core.debug_log("Navigation path cleared.")
end

--[[
  Go to the begining of the navigation path.
]]
function _M.navigation_beginning(action)
  local stack = core.channel.stack.navigation
  if #stack == 0 then
    core.debug_log("Cannnot navigate to the beginning of the path, path is empty!")
  else
    local last_sequence, new_sequence
    last_sequence = stack[#stack]
    new_sequence = stack[1]
    -- New stack starts with first sequence from old stack.
    core.channel.stack.navigation = { new_sequence }
    core.debug_log("Moving to beginning of path from sequence '%s' to sequence '%s'", last_sequence, new_sequence)
    core.queue_sequence(new_sequence)
  end
end

--[[
  Set the last item on the navigation path as the new beginning.
]]
function _M.navigation_reset(action)
  local stack = core.channel.stack.navigation
  if #stack == 0 then
    core.debug_log("Cannnot reset path, path is empty!")
  else
    -- New stack starts with last sequence from old stack.
    new_sequence = table.remove(stack)
    core.channel.stack.navigation = { new_sequence }
    core.debug_log("Reset beginning of path to sequence '%s'", new_sequence)
  end
end

-- Make sure module initialization only runs once.
if not _M.init_run then
  _M.init_run = true
  init()
end

return _M
