local core = require "jester.core"
local conf = require "jester.conf"

-- Arguments can come from a few different sources, so check them all and
-- provide a default empty table.
local args = argv or arg or {}

-- Check for help query.
if args[1] == "help" then
  local help = require "jester.help"
  return help.get_help(args[2], args[3], args[4], args[5])
end

-- Run normally.
if args[1] and args[2] then
  core.bootstrap(conf, args[1], args[2], args[3])
  -- Main loop.
  core.main()
else
  error("JESTER: missing arguments in call to jester.lua. Run 'lua jester/jester.lua help' from the FreeSWITCH console for more help", 2)
end

