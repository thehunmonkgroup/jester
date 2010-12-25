require "jester.conf"
require "jester.debug"

-- Make script arguments consistent.
local args
if argv then
  args = argv
elseif arg then
  args = arg
else
  args = {}
end

-- Check to see if we're calling the script from within FreeSWITCH.
if freeswitch and freeswitch.consoleLog then jester.is_freeswitch = true end

-- Check for help query.
if args[1] == "help" then
  require "jester.help"
  return jester.help.get_help(args[2], args[3], args[4], args[5])
end

-- Run normally.
if args[1] and args[2] then

  -- Initialize the channel object.
  jester.init_channel()

  -- Initialize sequence loop stacks.  Sequence stacks are initialized just
  -- prior to each sequence loop run.
  jester.init_stacks({"active", "exit", "hangup"})

  -- Save the initial arguments.
  jester.initial_args = args[3] and jester.parse_args(args[3]) or {}

  -- Add profile configuration here so it can leverage access to channel
  -- variables.
  jester.init_profile(args[1])

  -- Load modules.
  jester.init_modules(jester.conf.modules)

  -- Set up the global key handler.
  key_handler = jester.key_handler
  session:setInputCallback("key_handler")

  -- Turn off autohangup.
  session:setAutoHangup(false)

  -- Load initial sequence.
  local event = {
    event_type = "sequence",
    sequence = args[2] .. " " .. (args[3] or ""),
  }
  table.insert(jester.channel.stack.active, event)

  jester.bootstrapped = true
else
  error("JESTER: missing arguments in call to jester.lua. Run 'luarun jester.lua help' from the FreeSWITCH console for more help", 2)
end

