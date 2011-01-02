module(..., package.seeall)

-- Enable this setting to turn on debuggging.
-- This value can be overridden per profile.
debug = true

-- These settings control what debugging information is output.
debug_output = {
  -- Ongoing progress.
  log = true,
  -- These are output right before Jester exits.
  jester_object = true,
  executed_sequences = true,
  run_actions = true,
}

-- This file can be loaded from the shell, so only build session-based
-- settings if we have a session.
if session then
  base_dir = jester.get_variable("base_dir")
  sounds_dir = jester.get_variable("sounds_dir")
  jester_dir = base_dir .. "/scripts/jester"
  -- This value can be overridden per profile.
  sequence_path = jester_dir .. "/sequences"
  profile_path = jester_dir .. "/profiles"
end

help_path = "jester/help"

-- The order that keys are played in for announcements.
-- This value can be overridden per profile.
-- This value can be overridden in actions.
key_order = { "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "*", "#" }

-- The modules to load.
-- This value can be overridden per profile.
-- Note that the help system looks at this setting, not profile settings,
-- when it builds the module/action help.  Therefore the recommended
-- configuration is to include all modules here, and override the setting
-- in each profile listing only the modules that need to be loaded for
-- the profile.
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
  "dialplan_tools",
  "event",
  "format",
  "email",
}

