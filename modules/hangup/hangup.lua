--- Actions related to hanging up a channel.
--
-- This module provides actions that deal with hanging up a channel, or dealing
-- with a channel in a hung up state.
--
-- @module hangup
-- @author Chad Phillips
-- @copyright 2011-2015 Chad Phillips


--- Hang up a call.
--
-- This action hangs up the call.  No more regular sequences or actions run
-- after this action is called (registered exit/hangup sequences/actions will
-- still run).
--
-- @action hangup
-- @param action
--   hangup
-- @param play
--   (Optional) The path to a file, or a phrase, to play before hanging up.
-- @usage
--   {
--     action = "hangup",
--     play = "phrase:goodbye",
--   }


--- Registers a sequence to be executed on hangup.
--
-- This action registers a sequence to be executed after the call has been hung
-- up.  Channel variables and storage values are available when the registered
-- sequence is run.
--
-- Sequences registered here are run after the sequences registered on exit, and
-- are only run if the caller hangups up the call before Jester finishes running
-- all active sequences related to the call.  If you want to guarantee that the
-- sequence will run regardless of user hangup, it's best to put it in the exit
-- loop instead of here.
--
-- @action hangup_sequence
-- @param action
--   hangup_sequence
-- @param sequence
--   The sequence to execute.
-- @usage
--   {
--     action = "hangup_sequence",
--     sequence = "cleanup_temp_recording",
--   }
-- @see core_actions.exit_sequence

local core = require "jester.core"

local _M = {}

--[[
  Hangup the call.
]]
function _M.hangup(action)
  -- Clean key map to prevent any key presses here.
  core.keys = {}
  -- Play a hangup file if specified.
  if action.play then
    session:streamFile(action.play)
  end
  core.debug_log("Hangup called in sequence action")
  session:hangup();
end

--[[
  Register a sequence to run in the hangup sequence loop.
]]
function _M.register_hangup_sequence(action)
  if action.sequence then
    local event = {}
    event.event_type = "sequence"
    event.sequence = action.sequence
    table.insert(core.channel.stack.hangup, event)
    core.debug_log("Registered hangup sequence: %s", event.sequence)
  end
end

return _M
