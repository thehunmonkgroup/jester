--- Core functions.
--
-- This module provides the lower-level functionality for Jester.
--
-- Unless you're developing a module or doing something very advanced, you
-- probably don't need to be familiar with this functionality -- it just works.
--
-- The @{05-Developer.md|Developer} documentation has more information about
-- the core functionality, and how it pertains to writing modules.
--
-- @module core
-- @author Chad Phillips
-- @copyright 2011-2021 Chad Phillips

require "jester.support.table"

local _M = {}


--- Create a logging object.
--
-- The created logger will detect if it's running in a FreeSWITCH environment,
-- and if not, it will log to console.
--
-- Only messages at or above the configured log level will be logged.
--
-- @tab config
--   The log configuration.
-- @param config.level
--   The log level, one of debug, info, warn, error, crit.
--   Default: info
-- @param config.outfile
--   File to write log messages to.
--   Default: nil
-- @param config.prefix
--   Prefix for log messages.
--   Default: jester
-- @param config.use_color
--   Use color when logging to terminal.
--   Default: true
-- @param config.modes
--   Table configuring the available logging modes.
--   Default: See default_config.modes in logger method of @{core.lua}
-- @return The log object
--   The object has the following log modes by default:
--      debug
--      info
--      warning
--      err
--      crit
-- @usage
--   logger = core.logger({level = "warning"})
--   logger.warning("Some message")
--   -- By default, log methods wrap @{string.format}, so token replacement is
--   -- supported.
--   logger.err("Count: %d, type: %s", count, type)
--   -- For custom formatting, pass a function as the first argument, which will
--   -- be called with the additional arguments. The function should return the
--   -- output string.
--   logger.info(function(c) return "Count is: " .. c end, count)
function _M.logger(config)
  config = config or {}
  local default_config = {
    level = "info",
    outfile = nil,
    prefix = "jester",
    use_color = true,
    modes = {
      { name = "debug", color = "\27[36m", },
      { name = "info",  color = "\27[32m", },
      { name = "warning",  color = "\27[33m", },
      { name = "err", color = "\27[31m", },
      { name = "crit", color = "\27[31m", },
      --{ name = "crit", color = "\27[35m", },
    }
  }
  local log = table.merge(default_config, config, false)
  local levels = {}
  for i, v in ipairs(log.modes) do
    levels[v.name] = i
  end
  for i, x in ipairs(log.modes) do
    local name = x.name
    log[name] = function(msg, ...)
      assert(levels[log.level], string.format([[ERROR: missing log level '%s']], log.level))
      if i < levels[log.level] then
        return
      end
      local name_upper = name:upper()
      local prefix = log.prefix and string.format("[%s] ", log.prefix:upper()) or ""
      local output
      if type(msg) == "function" then
        output = msg(...)
      else
        output = string.format(msg, ...)
      end
      output = prefix .. output
      -- Output to log file
      if log.outfile then
        local fp = io.open(log.outfile, "a")
        local str = string.format("[%-6s%s] %s: %s\n",
                                  name_upper,
                                  os.date(),
                                  lineinfo,
                                  output)
        fp:write(str)
        fp:close()
      end
      if _M._TEST then
        return name, output
      elseif _M.is_freeswitch then
        freeswitch.consoleLog(name, output .. "\n")
      else
        local info = debug.getinfo(2, "Sl")
        local lineinfo = info.short_src .. ":" .. info.currentline
        -- Output to console
        print(string.format("%s[%-6s%s]%s %s: %s",
                            log.use_color and x.color or "",
                            name_upper,
                            os.date("%H:%M:%S"),
                            log.use_color and "\27[0m" or "",
                            lineinfo,
                            output))
      end
    end
  end
  return log
end

--- Bootstrap the Jester environment.
--
-- @tab config
--   Optional. Defaults to @{core.conf|global configuration}.
-- @usage
--   config = require "jester.conf"
--   core.bootstrap(config)
function _M.bootstrap(config)

  --- Global configuration table.
  --
  -- As configured in @{core.conf}.
  --
  -- @field conf
  _M.conf = config or require "jester.conf"

  --- Boolean indicating if the script was called from within FreeSWITCH.
  --
  -- @field is_freeswitch
  _M.is_freeswitch = freeswitch and freeswitch.consoleLog

  local log_config = {}
  if _M.conf.debug then
    log_config.level = "debug"
  end
  _M.log = _M.logger(log_config)
  _M.log.info("Bootstrapping Jester")

end

--- Bootstrap Jester for a testing environment.
--
-- @tab config
--   Optional. Defaults to @{core.conf|global configuration}.
-- @usage
--   config = require "jester.conf"
--   core.bootstrap_test(config)
function _M.bootstrap_test(config)

  _M.bootstrap(config)
  _M._TEST = true

end

--- Initialize modules.
--
-- Modules and custom scripts can call this function to load additional
-- modules.
--
-- @tab modules
--   List of module names to initialize.
-- @usage
--   core.init_modules({"foo_module", "bar_module"})
function _M.init_modules(modules)
  local config
  local conf_file
  --- Lightweight map of all actions that can be called.
  --
  -- @field action_map
  _M.action_map = _M.action_map or {}
  for _, mod in ipairs(modules) do
    conf_file = "jester.modules." .. mod .. ".conf"
    config = require(conf_file)
    if config then
      config.action_map = config.action_map or {}
      for action, data in pairs(config.action_map) do
        _M.action_map[action] = data
      end
      _M.log.debug("Loaded module configuration '%s'", conf_file)
    else
      _M.log.debug("Failed loading module configuration '%s'!", conf_file)
    end
  end
end

--- Initialize the specified profile.
--
-- Loads the provided profile as the current active profile in Jester core.
--
-- @string profile_name
--   The name of the profile to load, see @{02-Profiles.md|Profiles}.
-- @usage
--   core.init_profile("demo")
function _M.init_profile(profile_name)

  _M.log.debug("Loading profile '%s'", profile_name)
  --- Currently loaded profile.
  --
  -- Set up access to channel variables, storage, global configs, and initial
  -- arguments.
  --
  -- Listed fields are accessible as environment-level variables from within
  -- the profile.
  --
  -- @tab global
  --   Global configuration.
  -- @func args
  --   Access to arguments passed when Jester was invoked.
  -- @func storage
  --   Access to storage areas.
  -- @func variable
  --   Access to FreeSWITCH channel variables.
  -- @func debug_dump
  --   Access to the @{debug_dump} function.
  _M.profile = {
    global = _M.conf,
    args = function(i)
      local arg = _M.initial_args[tonumber(i)] or ""
      _M.log.debug("Got profile arg(%d): '%s'", i, arg)
      return arg
    end,
    storage = protected_get_storage,
    variable = protected_get_variable,
    debug_dump = _M.debug_dump,
  }
  local filepath = _M.conf.profile_path .. "/" .. profile_name .. "/conf.lua"
  -- Compat with 5.1, as the extra args to loadfile are ignored.
  local loaded_profile, err = assert(loadfile(filepath, "bt", _M.profile))
  if loaded_profile then
    if _VERSION == "Lua 5.1" then
      setfenv(loaded_profile, _M.profile)
    end
    loaded_profile()
  end

  -- Profile overrides -- these can optionally override settings in the global
  -- configuration file.
  local overrides = {
    "debug",
    "sequence_path",
    "modules",
    "key_order",
  }
  for _, override in ipairs(overrides) do
    if _M.profile[override] ~= nil then
      _M.log.debug("Overriding global config '%s' in profile '%s'", override, profile_name)
      _M.conf[override] = _M.profile[override]
    end
  end
end

--- Parse arguments.
--
-- @string args
--   Arguments.
--
-- @return
--   An ordered list of arguments.
-- @usage
--   core.parse_args("arg1,arg2")
function _M.parse_args(args)
  local result, from, i = {}, 1, 1
  if args ~= "" then
    local delim_from, delim_to = string.find(args, ",", from)
    while delim_from do
      result[i] = string.sub(args, from , delim_from - 1)
      from = delim_to + 1
      i = i + 1
      delim_from, delim_to = string.find(args, ",", from)
    end
    result[i] = string.sub(args, from)
  end
  return result
end

--- Sets the key map for the specified action/sequence combination.
--
-- @tab action
--   The action table.
-- @tab sequence
--   The sequence table.
-- @usage
--   core.set_keys(action, sequence)
function _M.set_keys(action, sequence)
  -- Clear any key press data from the previously run action.  This prevents
  -- false key press detections on the current action.
  _M.key_pressed = {}
  local message
  -- Key maps defined in the action take precedence.
  if type(action.keys) == "table" then
    _M.keys = action.keys
    message = "Set keys for action '%s'"
  -- Fall back to sequence-wide key map if present.
  elseif type(sequence.keys) == "table" then
    _M.keys = sequence.keys
    message = "Set default sequence keys for action '%s'"
  -- No key map.  Explicitely unset it here so that no action at all is taken
  -- by the input callback function during this action.
  else
    _M.keys = nil
    message = "No keys to set for action '%s'"
  end
  _M.log.debug(message, action.action)
end

--- Global key handler for all key press events in Jester.
--
-- @param session
--   The session object.
-- @string input_type
--   The type of input data.
-- @tab data
--   The input data.
function _M.key_handler(session, input_type, data)
  if _M.keys and input_type == "dtmf" then
    -- Make sure we get a single digit.
    _M.key_pressed.digit = string.sub(data["digit"], 1, 1)
    -- Pressed key is in the current key map, so it's valid.
    if _M.keys[_M.key_pressed.digit] then
      _M.key_pressed.valid = _M.key_pressed.digit
      _M.log.debug("Key pressed: %s, valid", _M.key_pressed.valid)
      -- Parse the key value.  Values prefixed with @ are ad hoc actions,
      -- values prefixed with : are playback commands to return to core
      -- for playback control (break, seek, etc).
      local marker, command = string.match(_M.keys[_M.key_pressed.digit], "^([:@]?)(.+)")
      if marker == ":" then
        return command
      elseif marker == "@" then
        local action = { action = command, ad_hoc = true }
        _M.run_action(action)
      else
        _M.queue_sequence(command)
      end
      return "break"
    -- Invalid key pressed.
    else
      -- Check to see if the key map wants us to take some action on the
      -- invalid key.
      if _M.keys.invalid or _M.keys.invalid_sound or _M.keys.invalid_sequence then
        _M.key_pressed.invalid = _M.key_pressed.digit
        _M.log.debug("Key pressed: %s, invalid!", _M.key_pressed.invalid)
        -- By default, replay the current action, but give the option
        -- to load a custom sequence instead.
        if _M.keys.invalid_sequence then
          _M.queue_sequence(_M.keys.invalid_sequence)
        else
          _M.channel.stack.sequence[_M.channel.stack.sequence_stack_position].replay_action = true
        end
        -- Play an invalid sound if specified.
        if _M.keys.invalid_sound then
          _M.log.debug("Playing invalid sound file: %s", _M.keys.invalid_sound)
          session:streamFile(_M.keys.invalid_sound)
        end
        return "break"
      end
    end
  end
end

--- Runs a loaded action.
--
-- If the action is not an ad hoc action, the global sequence stack is referenced.
--
-- @tab action
--   The action table.
-- @usage
--   core.run_action(action)
function _M.run_action(action)
  if _M.ready() and action.action then
    local stack = _M.channel.stack.sequence
    local p = _M.channel.stack.sequence_stack_position
    local mod_name
    -- Find the module that provides this action.
    if _M.action_map[action.action] then
      mod_name = _M.action_map[action.action].mod
    else
      error(string.format([[JESTER: No valid action '%s']], action.action))
    end
    -- Load the module.  Since Lua caches loaded modules, this is only an
    -- expensive operation the first time the module code is loaded.
    local mod = require("jester.modules." .. mod_name .. ".init")
    _M.log.debug("Loaded module '%s'", mod_name)
    -- Load the handler for the action.
    local func = _M.load_action_handler(action)
    action_func = mod[func]
    if type(action_func) == "function" then
      -- Actions can be called directly from a module or a key press.  These
      -- are not on the sequence stack, so check here if it's an ad hoc
      -- action.
      if action.ad_hoc then
        _M.log.debug("Running ad hoc action '%s'", action.action)
      else
        _M.log.debug("Running action %d (%s) from sequence '%s', function '%s'", stack[p].position, action.action, stack[p].name, func)
      end
      -- Set up key presses for this action -- ad hoc actions don't have key
      -- presses, and may be run when no valid sequence stack is present, so
      -- specifically check for that here to prevent it.
      if not action.ad_hoc then _M.set_keys(action, stack[p].sequence) end
      action_func(action)
    else
      _M.log.debug("Error executing action function '%s', does not exist!", func)
    end
  elseif not action.action then
    _M.log.debug("No valid action parameter, skipping")
  end
end

--- Loads the correct handler for the passed action.
--
-- The default handler is used if none is specified.
-- @tab action
--   The action table.
-- @usage
--   core.load_action_handler(action)
function _M.load_action_handler(action)
  local func
  local handlers = _M.action_map[action.action].handlers
  -- Does the action have handlers?
  if handlers then
    -- Look for a declared handler, fall back to default.
    if action.handler and handlers[action.handler] then
      func = handlers[action.handler]
    else
      func = handlers.default
    end
  else
    -- Use the function instead.
    func = _M.action_map[action.action].func
  end
  return func
end

--- Determines if Jester is still in a ready state.
--
-- Unlike session:ready(), this ready check returns true if Jester is in either
-- its exit or hungup states as well.
--
-- Do use this if you want to loop until Jester finishes, don't use this if you
-- want to loop until the call hangs up.
--
-- @usage
--   core.ready()
function _M.ready()
  -- No session means running from socket or luarun, always ready.
  if not session then
    return true
  else
    return session:ready() or _M.exiting or _M.hungup
  end
end

--- Determines if a key was pressed that will result in some action by core.
--
-- Modules can call this function to check for valid key presses, to break out
-- of loops, etc.
--
-- @usage
--   core.actionable_key()
function _M.actionable_key()
  return _M.key_pressed.valid or _M.key_pressed.invalid
end

--- Stream silence for a specified number of milliseconds.
--
-- @int milliseconds
--   Number of milliseconds to wait.
-- @usage
--   core.wait(1000)
function _M.wait(milliseconds)
  _M.log.debug("Waiting %d milliseconds", milliseconds)
  -- TODO: switch to socket.sleep
  session:streamFile("silence_stream://" .. milliseconds)
end

--- Wrapper to grab session variables.
--
-- @string chan_var
--   The name of the channel variable.
-- @param default
--   The default value for the variable if none is found on the channel.
-- @return
--   The value stored in the channel variable, or the default value if none is
--   found.
-- @usage
--   core.get_variable("some_channel_var", "default_value")
function _M.get_variable(chan_var, default)
  local value = session:getVariable(chan_var)
  if value then
    _M.log.debug("Got value %s: %s", chan_var, tostring(value))
  elseif default then
    value = default
    _M.log.debug("Variable %s returned default: %s", chan_var, tostring(default))
  else
    _M.log.debug("Variable %s: not set", chan_var)
  end

  return value
end

--- Wrapper to set session variables.
--
-- @string chan_var
--   The name of the channel variable.
-- @string value
--   The value of the channel variable.
-- @string default
--   The default value for the variable if none is provided by the value
--   argument.
-- @return
--   The value stored in the channel variable, or the default value if none is
--   found.
-- @usage
--   core.get_variable("some_channel_var", "some_value", "default_value")
function _M.set_variable(chan_var, value, default)
  local message
  if value then
    message = "Set value %s: %s"
  else
    value = default
    message = "Set value %s to default: %s"
  end
  session:setVariable(chan_var, value)
  _M.log.debug(message, chan_var, tostring(value))
end

--- Dumps values to console.
--
-- @param var
--   Variable to dump.
-- @bool recursive
--   Dump tables recursively. Default false.
-- @string prefix
--   Prefix dumped values with this string, default is no prefix.
-- @usage
--   core.debug_dump(profile, true, "PROFILE: ")
function _M.debug_dump(var, recursive, prefix)
  local key, value
  prefix = prefix or ""
  if type(var) == "table" then
    for k, v in pairs(var) do
      if type(v) == "string" or type(v) == "number" or type(v) == "boolean" then
        value = tostring(v)
      else
        value = type(v)
      end
      if type(k) == "string" or type(k) == "number" or type(k) == "boolean" then
        key = tostring(k)
      else
        key = type(k)
      end
      -- Exclude possibly infinitely recursive keys.
      if k ~= "_M" and k ~= "__index" then
        _M.log(string.format([[%s%s, value: %s]], prefix, key, value), "JESTER VAR DUMP")
        -- Tables get optional recursive treatment.
        if recursive and type(v) == "table" then
          _M.debug_dump(v, recursive, prefix .. "[" .. key .. "]")
        end
      end
    end
  elseif type(var) == "string" or type(var) == "number" or type(var) == "boolean" then
    _M.log(string.format([[value: %s]], tostring(var)), "JESTER VAR DUMP")
  else
    _M.log(string.format([[value: %s]], type(var)), "JESTER VAR DUMP")
  end
end
return _M
