--- Main launching point for Jester.
--
-- This script is used to launch the Jester environment from within
-- FreeSWITCH. Invoke it from within your dialplan like this:
--
--```xml
--  <action
--    application="lua"
--    data="jester/jester.lua <profile> <sequence> [arg1],[arg2],...,[argN]"
--  />
--```
--
-- See the @{01-Intro.md|Intro} and other documentation for more details on
-- using Jester.
--
-- @script jester.lua
-- @author Chad Phillips
-- @copyright 2011-2015 Chad Phillips

local core = require "jester.core"
local conf = require "jester.conf"

-- Arguments can come from a few different sources, so check them all and
-- provide a default empty table.
local args = argv or arg or {}

-- Run normally.
if args[1] and args[2] then
  core.bootstrap(conf, args[1], args[2], args[3])
  -- Main loop.
  core.main()
else
  error("JESTER: missing arguments in call to jester.lua. Run 'lua jester/jester.lua help' from the FreeSWITCH console for more help", 2)
end

