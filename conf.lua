module(..., package.seeall)

-- Enable this setting to get debuggging messages.
debug = true

-- This file can be loaded from the shell, so only build session-based
-- settings if we have a session.
if session then
  base_dir = jester.get_variable("base_dir")
  sounds_dir = jester.get_variable("sounds_dir")
  jester_dir = base_dir .. "/scripts/jester"
  sequence_path = jester_dir .. "/sequences"
  profile_path = jester_dir .. "/profiles"
end

help_path = "jester/help"
key_order = { "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "*", "#" }
modules = {
  "core_actions",
  "navigation",
  "play",
  "get_digits",
  "record",
  "file",
  "log",
  "data",
  "tracker",
  "hangup",
}
