module(..., package.seeall)

--[[
  Hangup the call.
]]
function hangup(action)
  -- Clean key map to prevent any key presses here.
  jester.keys = {}
  -- Play a hangup file if specified.
  if action.play then
    session:streamFile(action.play)
  end
  jester.debug_log("Hangup called in sequence action")
  session:hangup();
end

--[[
  Register a sequence to run in the hangup sequence loop.
]]
function register_hangup_sequence(action)
  if action.sequence then
    local event = {}
    event.event_type = "sequence"
    event.sequence = action.sequence
    table.insert(jester.channel.stack.hangup, event)
    jester.debug_log("Registered hangup sequence: %s", event.sequence)
  end
end

