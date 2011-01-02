module(..., package.seeall)

--[[
  Fires a custom event.
]]
function fire_event(action)
  local event_type = action.event_type
  local headers = action.headers
  local body = action.body
  if event_type then
    local event = freeswitch.Event("custom", "jester::" .. event_type)
    if headers then
      for k, v in pairs(headers) do
        event:addHeader("Jester-" .. k, v)
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

