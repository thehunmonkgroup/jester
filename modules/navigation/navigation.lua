--- Navigation module.
-- @module navigation

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
