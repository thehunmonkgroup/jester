--[[
  This is a socket listener for running Jester sequences via the FreeSWITCH
  event system.  It is experimental, use at your own risk.

  To start listener, set it as a startup script in
  conf/autoload_configs/lua.conf.xml:
    <param name="startup-script" value="jester/socket.lua"/>

  Or via luarun:
    luarun jester/socket.lua

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

  WARNING: there is no session object available with this approach, so be
  careful not to use actions that need a session (play, record, get_digits,
  etc.) or the listener will crash!  The sequences should be more along the
  lines of performing database/file manipulation, logging to file, etc.
]]

require "jester.core"
require "jester.conf"
require "jester.debug"
require "ESL"

function jester.bootstrap_socket(profile, sequence, sequence_args)

  -- Fake a channel here so stacks and storage will work.
  jester.channel = {}
  jester.channel.stack = {}
  jester.channel.storage = {}

  -- Set up basic directory paths, these are not supplied by the global config
  -- file because no session exists.
  jester.conf.base_dir = jester.socket_base_dir
  jester.conf.jester_dir = jester.conf.base_dir .. "/scripts/jester"
  -- This value can be overridden per profile.
  jester.conf.sequence_path = jester.conf.jester_dir .. "/sequences"
  jester.conf.profile_path = jester.conf.jester_dir .. "/profiles"

  -- Initialize sequence loop stacks.  Sequence stacks are initialized just
  -- prior to each sequence loop run.
  jester.init_stacks({"active", "exit", "hangup"})

  -- Save the initial arguments.
  jester.initial_args = sequence_args and jester.parse_args(sequence_args) or {}

  -- Add profile configuration here so it can leverage access to channel
  -- variables.
  jester.init_profile(profile)

  -- Load modules.
  jester.init_modules(jester.conf.modules)

  -- Load initial sequence.
  local event = {
    event_type = "sequence",
    sequence = sequence .. " " .. (sequence_args or ""),
  }
  table.insert(jester.channel.stack.active, event)

  jester.bootstrapped = true
end

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
  local host = "localhost"
  local port = "8021"
  local password = "Tomato34"
  jester.sock = assert(ESL.ESLconnection(host, port, password))
end


-- This is always true on a socket connection.
jester.is_freeswitch = true
jester.socket_connect()

if jester.sock and jester.sock:connected() then
  jester.socket_log("connected")
  -- Subscribe only to Jester socket events.
  jester.sock:events("plain", "CUSTOM jester::socket")
  jester.continue_socket = true
  -- Store the base directory for later use.
  local base_dir_event = jester.sock:api("global_getvar base_dir")
  jester.socket_base_dir = base_dir_event:getBody()
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
        jester.socket_log(string.format([["received event: profile '%s', sequence '%s']], profile, sequence .. " " .. sequence_args))
        jester.bootstrap_socket(profile, sequence, sequence_args)
        if jester.bootstrapped then
          -- Main loop.
          jester.main()
        end
      end
    end
  end
  jester.socket_log("disconnecting")
end

