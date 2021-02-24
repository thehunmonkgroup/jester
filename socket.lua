-- TODO: Rewrite for library.
--- Socket listener.
--
-- This is a socket listener for running Jester sequences via the FreeSWITCH
-- event system.  It is experimental, use at your own risk.
--
-- To start listener, set it as a startup script in
-- conf/autoload_configs/lua.conf.xml:
--```xml
--   <param
--     name="startup-script"
--     value="jester/socket.lua [server] [port] [password]"
--   />
--```
--
-- Or via luarun:
--```sh
--   luarun jester/socket.lua [server] [port] [password]
--```
--
-- It listens for CUSTOM events of subclass 'jester::socket'.
--
-- Firing an event for the listener looks something like this:
--
--```
-- sendevent CUSTOM
-- Event-Subclass: jester::socket
-- Jester-Profile: socket
-- Jester-Sequence: mysequence
-- Jester-Sequence-Args: arg1,arg2
--```
--
-- Params for the event are as follows:
--
--```
-- Jester-Sequence:
--   Required.  The name of the sequence to run.
-- Jester-Profile:
--   Optional.  The profile to run the sequence under.  Defaults to 'socket'.
-- Jester-Sequence-Args:
--   Optional.  Arguments to pass to the sequence, in the same form that normal
--   sequence arguments are passed.
--```
--
-- To exit the listener, you can send this event:
--
--```
--  sendevent CUSTOM
--  Event-Subclass: jester::socket
--  Jester-Socket-Exit: yes
--```
--
-- **WARNING:** there is no session object available with this approach, so be
-- careful not to use actions that need a session (play, record, get_digits,
-- etc.) or the listener will crash!  The sequences should be more along the
-- lines of performing database/file manipulation, logging to file, etc.
--
-- @script socket.lua
-- @author Chad Phillips
-- @copyright 2011-2015 Chad Phillips

local core = require "jester.core"
local conf = require "jester.conf"
-- The ESL library in older versions doesn't return the ESL object, so leave
-- it as a global for compat.
require "ESL"

local _M = {}
-- Login information for the event socket.
_M.host = argv[1] or "localhost"
_M.port = argv[2] or "8021"
_M.password = argv[3] or "ClueCon"

--[[
  Logs socket information to the FreeSWITCH console.
]]
function _M.socket_log(message)
  core.log(message, "JESTER SOCKET")
end

--[[
  Connect to FreeSWITCH.
]]
function _M.socket_connect()
  _M.sock = ESL.ESLconnection(_M.host, _M.port, _M.password)
end

-- This is always true on a socket connection, setting it here allows early
-- logging.
core.is_freeswitch = true
_M.socket_log("connecting")
_M.socket_connect()

if _M.sock and _M.sock:connected() then
  _M.socket_log("connected")
  -- Subscribe only to Jester socket events.
  _M.sock:events("plain", "CUSTOM jester::socket")
  _M.continue_socket = true
  while _M.sock and _M.sock:connected() and _M.continue_socket do
    local event = _M.sock:recvEvent()
    -- Provide a way to exit the listener.
    if event:getHeader("Jester-Socket-Exit") then
      _M.continue_socket = false
      _M.socket_log("received disconnect command")
    else
      local sequence = event:getHeader("Jester-Sequence")
      if sequence then
        local profile = event:getHeader("Jester-Profile") or "socket"
        local sequence_args = event:getHeader("Jester-Sequence-Args") or ""
        _M.socket_log(string.format([[received Jester event: %s %s %s]], profile, sequence, sequence_args))
        core.bootstrap(conf, profile, sequence, sequence_args)
        -- Main loop.
        core.main()
      end
    end
  end
  _M.socket_log("disconnecting")
  if _M.sock and _M.sock:connected() then
    _M.sock:disconnect()
  end
end

return _M

