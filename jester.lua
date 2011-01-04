require "jester.core"
require "jester.conf"
require "jester.debug"

-- Arguments can come from a few different sources, so check them all and
-- provide a default empty table.
jester.bootstrap(argv or arg or {})

if jester.bootstrapped then
  -- Main loop.
  jester.main()
end

