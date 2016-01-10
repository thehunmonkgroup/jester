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
