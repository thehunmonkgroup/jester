require "jester.core"
require "jester.bootstrap"

if jester.bootstrapped then
  -- Main loop.
  jester.main()
  if jester.debug then
    debug_dump(jester, true)
  end
end

