module(..., package.seeall)

--[[
  Fires a custom event.
]]
function fire_event(action)
  local subclass = action.subclass or "jester"
  local event_type = action.event_type
  local headers = action.headers
  local header_prefix = action.header_prefix or "Jester-"
  local body = action.body
  if event_type then
    local event = freeswitch.Event("custom", subclass .. "::" .. event_type)
    if headers then
      for k, v in pairs(headers) do
        event:addHeader(header_prefix .. k, v)
      end
    end
    if body then
      -- Ensure that the event body has terminating newlines.
      event:addBody(body .. "\n\n")
    end
    jester.debug_log("Firing custom event 'jester::%s'", event_type)
    event:fire()
  end
end

