--[[
  This is the global configuration file for Jester.

  Probably not a good idea to change any of these settings unless you know
  what you're doing.
]]
local conf = {}

-- Enable this setting to turn on debuggging.
-- This value can be overridden per profile.
conf.debug = true

-- These settings control what debugging information is output.
conf.debug_output = {
  -- Ongoing progress.
  log = true,
  -- These are output right before Jester exits.
  jester_object = false,
  executed_sequences = true,
  run_actions = false,
}

-- This file can be loaded from the shell, so only build these settings if we
-- have access to the API.
if freeswitch then
  local api = freeswitch.API()
  conf.base_dir = api:executeString("global_getvar base_dir")
  conf.sounds_dir = api:executeString("global_getvar sounds_dir")
  -- Override this if scripts are hosted in a non-standard location.
  conf.scripts_dir = conf.base_dir .. "/scripts"
  conf.jester_dir = conf.scripts_dir .. "/jester"
  -- This value can be overridden per profile.
  conf.sequence_path = conf.jester_dir .. "/sequences"
  conf.profile_path = conf.jester_dir .. "/profiles"
end

conf.help_path = "jester/help"

-- The order that keys are played in for announcements.
-- This value can be overridden per profile.
-- This value can be overridden in actions.
conf.key_order = { "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "*", "#" }

-- The modules to load.
-- This value can be overridden per profile.
-- Note that the help system looks at this setting, not profile settings,
-- when it builds the module/action help.  Therefore the recommended
-- configuration is to include all modules here, and override the setting
-- in each profile listing only the modules that need to be loaded for
-- the profile.
conf.modules = {
  "core_actions",
  "couchdb",
  "data",
  "dialplan_tools",
  "email",
  "event",
  "file",
  "format",
  "get_digits",
  "hangup",
  "log",
  "navigation",
  "play",
  "record",
  "service",
  "speech_to_text",
  "system",
  "tracker",
}

return conf
