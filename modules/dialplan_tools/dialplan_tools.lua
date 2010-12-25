module(..., package.seeall)

--[[
  Executes a dialplan application.
]]
function execute(action)
  local application = action.application
  local data = action.data or ""
  if application then
    jester.debug_log("Executing dialplan application '%s' with data: %s", application, data)
    session:execute(application, data)
  end
end

--[[
  Transfers the call to another extension.
]]
function transfer(action)
  local extension = action.extension
  local dialplan = action.dialplan or "XML"
  local context = action.context or jester.get_variable("context", "default")
  if extension then
    -- Kill all other sequences in the current stack.
    jester.reset_stack("sequence")
    jester.reset_stack("sequence_name")
    jester.debug_log("Transferring to: %s %s %s", extension, dialplan, context)
    session:transfer(extension, dialplan, context)
  end
end

--[[
  Bridges the call to other endpoints.
]]
function bridge(action)
  local channel = action.channel
  local extension = action.extension
  local variables = action.variables or {}
  local multichannel_type = action.multichannel_type or "first_wins"
  local hangup_after_bridge = action.hangup_after_bridge
  if channel and extension then
  end
end

