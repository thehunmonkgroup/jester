--- Interact with the FreeSWITCH event system.
--
-- This module provides actions for interacting with the FreeSWITCH event
-- system.
--
-- @module event
-- @author Chad Phillips
-- @copyright 2011-2015 Chad Phillips


--- Fires a custom event.
--
-- Event-Name will be 'CUSTOM', and Event-Subclass will
-- be '[subclass]::[event_type]'.
--
-- The body will automatically have two newline characters appended to it.
--
-- @action fire_event
-- @string action
--   fire_event
-- @string body
--   (Optional) The event body.
-- @string event_type
--   The second portion of the Event-Subclass header (after the double colons).
-- @string header_prefix
--   (Optional) Prefix all header keys with this string. Defaults to 'Jester-'.
-- @tab headers
--   (Optional) A table of event headers, key = header name, value = header
--   description.  Note that some headers will need to use the full table key
--   syntax.
-- @string subclass
--   (Optional) The first portion of the Event-Subclass header (before the
--   double colons). Default is 'jester'.
-- @usage
--   {
--     action = "fire_event",
--     body = "some message body, if you need it...",
--     event_type = "messages_checked",
--     header_prefix = "Checked-Messages-",
--     headers = {
--       Mailbox = mailbox,
--       Domain = profile.domain,
--       ["New-Message-Count"] = message_count,
--     },
--     subclass = "messages-checked",
--   },


local core = require "jester.core"

local _M = {}

--[[
  Fires a custom event.
]]
function _M.fire_event(action)
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
    core.debug_log("Firing custom event 'jester::%s'", event_type)
    event:fire()
  end
end

return _M
