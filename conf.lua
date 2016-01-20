--- Global configuration file.
--
-- Probably not a good idea to change any of these settings unless you know
-- what you're doing.
--
-- Some values can be overridden per-profile, check the documentation below.
--
-- @module core.conf
-- @author Chad Phillips
-- @copyright 2011-2015 Chad Phillips


--- Global configuration table.
--
-- Check the conf.lua file for further descriptions of these values.
--
-- @table conf
-- @field debug
--   Enable this setting to turn on debuggging.
--   This value can be overridden per profile.
-- @field debug_output
--   Control debug output.
-- @field base_dir
--   Full path to FreeSWITCH base directory.
-- @field sounds_dir
--   Full path to FreeSWITCH sounds directory.
-- @field scripts_dir
--   Full path to FreeSWITCH scripts directory.
-- @field jester_dir
--   Full path to Jester directory.
-- @field sequence_path
--   Full path to Jester's global sequence directory.
--   This value can be overridden per profile.
-- @field profile_path
--   Full path to Jester's global profile directory.
-- @field key_order
--   The order that keys are played in for announcements.
--   This value can be overridden per profile.
--   This value can be overridden in actions.
-- @field modules
--   The modules to load.
--   This value can be overridden per profile.
local conf = {}

conf.debug = true

-- These settings control what debugging information is output, only edit the
-- values of the table, not the keys.
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
  conf.sequence_path = conf.jester_dir .. "/sequences"
  conf.profile_path = conf.jester_dir .. "/profiles"
end

conf.key_order = { "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "*", "#" }

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
