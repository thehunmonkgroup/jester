--[[
  This is a socket listener for running Jester sequences via the FreeSWITCH
  event system.  It is experimental, use at your own risk.

  To start listener, set it as a startup script in
  conf/autoload_configs/lua.conf.xml:
    <param name="startup-script" value="jester/socket.lua [server] [port] [password]"/>

  Or via luarun:
    luarun jester/socket.lua [server] [port] [password]

  It listens for CUSTOM events of subclass 'jester::socket'.

  Firing an event for the listener looks something like this:

  sendevent CUSTOM
  Event-Subclass: jester::socket
  Jester-Profile: socket
  Jester-Sequence: mysequence
  Jester-Sequence-Args: arg1,arg2

  Jester-Sequence:
    Required.  The name of the sequence to run.
  Jester-Profile:
    Optional.  The profile to run the sequence under.  Defaults to 'socket'.
  Jester-Sequence-Args:
    Optional.  Arguments to pass to the sequence, in the same form that normal
    sequence arguments are passed.

  To exit the listener, you can send this event:

    sendevent CUSTOM
    Event-Subclass: jester::socket
    Jester-Socket-Exit: yes

  WARNING: there is no session object available with this approach, so be
  careful not to use actions that need a session (play, record, get_digits,
  etc.) or the listener will crash!  The sequences should be more along the
  lines of performing database/file manipulation, logging to file, etc.
]]

require "jester.core"
require "jester.conf"
require "jester.debug"
require "ESL"

--[[
  Logs socket information to the FreeSWITCH console.
]]
function jester.socket_log(message)
  jester.log(message, "JESTER SOCKET")
end

--[[
  Connect to FreeSWITCH.
]]
function jester.socket_connect()
  -- Login information for the event socket.
  local host = argv[1] or "localhost"
  local port = argv[2] or "8021"
  local password = argv[3] or "ClueCon"
  jester.sock = assert(ESL.ESLconnection(host, port, password))
end


-- This is always true on a socket connection, setting it here allows early
-- logging.
jester.is_freeswitch = true
jester.socket_connect()

if jester.sock and jester.sock:connected() then
  jester.socket_log("connected")
  -- Subscribe only to Jester socket events.
  jester.sock:events("plain", "CUSTOM jester::socket")
  jester.continue_socket = true
  while jester.sock and jester.sock:connected() and jester.continue_socket do
    local event = jester.sock:recvEvent()
    -- Provide a way to turn exit the listener.
    if event:getHeader("Jester-Socket-Exit") then
      jester.continue_socket = false
      jester.socket_log("received disconnect command")
    else
      local sequence = event:getHeader("Jester-Sequence")
      if sequence then
        local profile = event:getHeader("Jester-Profile") or "socket"
        local sequence_args = event:getHeader("Jester-Sequence-Args") or ""
        local args = {
          profile,
          sequence,
        }
        if sequence_args then
          table.insert(args, sequence_args)
        end
        jester.socket_log(string.format([[received Jester event: %s]], table.concat(args, " ")))
        jester.bootstrap(args)
        if jester.bootstrapped then
          -- Main loop.
          jester.main()
        end
      end
    end
  end
  jester.socket_log("disconnecting")
  if jester.sock and jester.sock:connected() then
    jester.sock:disconnect()
  end
end

