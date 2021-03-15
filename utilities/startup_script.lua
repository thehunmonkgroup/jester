--- Startup script controller.
--
-- This script provides a basic controller for the 'startup-script'
-- functionality found in FreeSWITCH's mod_lua.
--
-- It serves the following functions:
--
-- 1. Calls a specified module on a regular, configurable interval.
-- 2. Reloads the module on every invocation (allows editing of your module).
-- 3. Calls the module in protected mode, preserving the infinite loop on
--    crash.
-- 4. Provides basic logging during the loop for successful/failed execution.
-- 5. Examines a special global variable that, when present, allows 'pausing'
--    your module execution in the loop.
--
-- Note that the clearing/reloading approach does come with the cost of a
-- small performance hit, and the benefit of being able to live edit your
-- module even though it is being run by the controller in an infinite loop.
--
-- INPORTANT: Even though the controller reloads your main module on every
-- invocation, you are still responsible for clearing the package cache for
-- any dependent scripts/modules that your module loads. This is not strictly
-- necessary, but will allow those dependent modules to be edited during the
-- infinite loop of the controller as well.
--
-- @module startup_script
-- @author Chad Phillips
-- @copyright 2021 Chad Phillips

local LOG_PREFIX = "JESTER::MODULE::STARTUP_SCRIPT"
local DEFAULT_SLEEP_SECONDS = 60

local api = freeswitch.API()

local function log(level, ...)
  freeswitch.consoleLog(level, string.format("[%s] %s\n", LOG_PREFIX, string.format(...)))
end

local function getvar(name)
  return freeswitch.getGlobalVariable(name)
end

local function sleep(milliseconds)
  freeswitch.msleep(milliseconds)
end

local function require_module(name)
  local success, M = pcall(require, name)
  if success then
    return M
  else
    log("err", "Could not require module '%s': make sure the module is available via a standard require() call", name)
    return false
  end
end

local function verify_module(name, M)
  if type(M) ~= "table" or type(M.main) ~= "function" then
    log("err", "Could not execute module '%s': the module must return a table, with a 'main' key that is the function to execute", name)
    return false
  end
  return true
end

local function execute_module_protected(M)
  return M.main()
end

local function execute_module(name, M)
  local success, data = pcall(execute_module_protected, M)
  if success then
    log("debug", "Executed module '%s' successfully, returned: %s", name, data)
  else
    log("err", "Could not execute module '%s': %s", name, data)
  end
end

local function unload_module(name)
  package.loaded[name] = nil
end

--- Start the main loop of the controller.
--
-- @string name
--   Name of the module to call, in the format expected by require().
-- @int sleep_seconds
--   Optional. Seconds to sleep between module invocations. If provided, must
--   be a positive integer or float.
local function main_loop(name, sleep_seconds)
  local sleep_milliseconds = math.floor(sleep_seconds * 1000)
  local module_pause_var = string.format([[%s_pause]], name)
  log("info", "Starting main loop for module '%s', sleeping %d seconds between invocations, pause module invocation with 'global_setvar %s=1'", name, sleep_seconds, module_pause_var)
  local M
  while true do
    if getvar(module_pause_var) then
      log("info", "Module '%s' has been paused, execute 'global_setvar %s=' to resume", name, module_pause_var)
    else
      M = require_module(name)
      if M and verify_module(name, M) then
        execute_module(name, M)
      end
    end
    unload_module(name)
    sleep(sleep_milliseconds)
  end
end

-- Make script arguments consistent.
local args = {}
if argv then
  args = argv
elseif arg then
  args = arg
end

local name = args[1]
local sleep_seconds = tonumber(args[2])

if not name then
  error("Module name is required, must be specified in the format needed by require()")
end
if not sleep_seconds or sleep_seconds == 0 then
  log("info", "No sleep_seconds argument provided, defaulting to %d seconds", DEFAULT_SLEEP_SECONDS)
  sleep_seconds = DEFAULT_SLEEP_SECONDS
end

main_loop(name, sleep_seconds)
