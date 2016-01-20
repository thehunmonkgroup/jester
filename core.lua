--- Core functions for Jester.
--
-- This module provides the lower-level functionality for Jester -- storage,
-- management of sequences, etc. Unless you're developing a module or doing
-- something very advanced, you probably don't need to be familiar with this
-- functionality -- it just works. :)
--
-- The @{05-Developer.md|Developer} documentation has more information about
-- the core functionality, and how it pertains to writing modules.
--
-- @module core
-- @author Chad Phillips
-- @copyright 2011-2015 Chad Phillips




local _M = {}

--- Bootstrap the Jester environment.
--
-- @tab config
--   The @{core.conf|global configuration}.
-- @tab profile
--   The profile configuration, see the {@02-Profiles.md|profile documentation}.
-- @string sequence
--   The sequence name to initialize with.
-- @string sequence_args
--   Arguments for the initial sequence.
-- @usage
--   core.bootstrap(conf, "someprofile", "somesequence", "arg1,arg2")
function _M.bootstrap(config, profile, sequence, sequence_args)

  -- Initialize the channel object.
  _M.init_channel()

  --- Global configuration table.
  --
  -- As configured in @{core.conf}.
  --
  -- @field conf
  _M.conf = config

  --- Boolean indicating if the script was called from within FreeSWITCH.
  --
  -- @field is_freeswitch
  _M.is_freeswitch = freeswitch and freeswitch.consoleLog

  -- Initialize sequence loop stacks.  Sequence stacks are initialized just
  -- prior to each sequence loop run.
  _M.init_stacks({"active", "exit", "hangup"})

  --- List of the initial arguments passed to Jester.
  --
  -- @field initial_args
  _M.initial_args = sequence_args and _M.parse_args(sequence_args) or {}

  -- Add profile configuration here so it can leverage access to channel
  -- variables.
  _M.init_profile(profile)

  -- Load modules.
  _M.init_modules(_M.conf.modules)

  -- Handle some session-based setup if we have a session.
  if session then
    _M.channel.uuid = _M.get_variable("uuid")
    _M.set_storage("channel", "uuid", _M.channel.uuid)

    -- Set up the global key handler.
    _G.key_handler = _M.key_handler
    session:setInputCallback("key_handler")

    -- Turn off autohangup.
    session:setAutoHangup(false)
  end

  -- Load initial sequence.
  local event = {
    event_type = "sequence",
    sequence = sequence .. " " .. (sequence_args or ""),
  }
  table.insert(_M.channel.stack.active, event)

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
      _M.debug_log("Loaded module configuration '%s'", conf_file)
    else
      _M.debug_log("Failed loading module configuration '%s'!", conf_file)
    end
  end
end

--- Initialize the channel namespace.
--
-- This holds all the stacks and storage for a Jester run.
--
-- @usage
--   core.init_channel()
function _M.init_channel()
  _M.debug_log("Creating channel table")

  --- Internal storage for channel data.
  --
  -- Stores various channel-specific data for the duration of a single call to
  -- the Jester core engine.
  --
  -- @tab stack
  --   Maintain the different stacks in Jester core.
  -- @tab storage
  --   Persistant storage areas.
  _M.channel = {
    stack = {},
    storage = {},
  }
end

--- Initialize the specified stacks.
--
-- Ensures passed stacks are in their proper initial state.
--
-- @tab stacks
--   List of stacks to init.
-- @usage
--   init_stacks({"run_actions", "executed_sequences"})
function _M.init_stacks(stacks)
  for _, name in ipairs(stacks) do
    _M.reset_stack(name)
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

  _M.debug_log("Loading profile '%s'", profile_name)
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
      _M.debug_log("Got profile arg(%d): '%s'", i, arg)
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
      _M.debug_log("Overriding global config '%s' in profile '%s'", override, profile_name)
      _M.conf[override] = _M.profile[override]
    end
  end
end

--- Initialize a storage area.
--
-- @string area
--   The name of the storage area.
-- @usage
--   core.init_storage("foo")
function _M.init_storage(area)
  if _M.channel and not _M.channel.storage[area] then
    _M.channel.storage[area] = {}
  end
end

--- Empties the specified stack.
--
-- Can also be used to initialize a stack.
--
-- @string name
--   The name of the stack.
-- @usage
--   core.reset_stack("sequence");
function _M.reset_stack(name)
  _M.debug_log("Reset stack '%s'", name)
  _M.channel.stack[name] = {}
end

--- Queues a sequence to be the next one run.
--
-- The sequence is queued in the current sequence loop, at the current sequence
-- stack position.
--
-- @string sequence
--   The full sequence name command, including arguments.
-- @usage
--   core.queue_sequence("sub:foo_sequence arg1,arg2")
function _M.queue_sequence(sequence)
  if _M.ready() and sequence then
    if _M.conf.debug then
      table.insert(_M.channel.stack.executed_sequences, #_M.channel.stack.executed_sequences + 1 .. ": " .. sequence)
    end
    local loaded_sequence, add_to_stack, remove_from_stack
    -- Parse out the sequence name and arguments.
    local s_type, sequence_name, sequence_args = _M.parse_sequence(sequence)
    _M.debug_log("%s called: %s, args: %s", s_type, sequence_name, sequence_args)
    local parsed_args = _M.parse_args(sequence_args)
    -- Check for stack operators, sub goes one level deeper, up goes one
    -- level up, top resets the stack.
    if s_type == "subsequence" then
      add_to_stack = true
    elseif s_type == "top_sequence" then
      -- Emptying the stack here will trigger putting the sequence on the top
      -- of a fresh stack.
      _M.reset_stack("sequence")
      _M.reset_stack("sequence_name")
    elseif s_type == "up_sequence" then
      remove_from_stack = true
    end
    local stack = _M.channel.stack.sequence
    -- Nothing on the current stack, add this sequence on the first stack.
    if #stack == 0 then
      add_to_stack = true
    end
    -- Load the sequence.
    loaded_sequence = _M.load_sequence(sequence_name, parsed_args)
    if loaded_sequence then
      _M.debug_log("Loaded sequence '%s'", sequence_name)
      if add_to_stack then
        -- Increment the action position of the currently running sequence, as
        -- if/when it resumes it's already run the action it was running when
        -- the subsequence was called.  Skip this if the stack is empty.
        if #stack > 0 then _M.channel.stack.sequence[#stack].position = stack[#stack].position + 1 end
        table.insert(_M.channel.stack.sequence, {})
        table.insert(_M.channel.stack.sequence_name, sequence)
      -- Remove the last item from the stack if there's more than 1.
      elseif remove_from_stack and #stack > 1 then
        table.remove(_M.channel.stack.sequence)
        table.remove(_M.channel.stack.sequence_name)
      end
      _M.debug_log("Current sequence stack: %s", table.concat(_M.channel.stack.sequence_name, " | "))
      _M.channel.stack.sequence_stack_position = #stack
      local p = _M.channel.stack.sequence_stack_position
      -- There might be data in here from before, so reset it.
      _M.channel.stack.sequence[p] = {}
      _M.channel.stack.sequence[p].file = loaded_sequence
      _M.channel.stack.sequence[p].sequence = loaded_sequence()
      _M.channel.stack.sequence[p].name = sequence_name
      _M.channel.stack.sequence[p].args = sequence_args
      _M.channel.stack.sequence[p].parsed_args = parsed_args
      _M.channel.stack.sequence[p].position = 1
    else
      _M.debug_log("Failed loading sequence '%s'!", sequence_name)
    end
  end
end

--- Loads the specified sequence into separate environment.
--
-- This allows special variables to be injected in the global namespace of the
-- sequence, as well as allowing control over which global Lua functionality is
-- exposed.
--
-- @string name
--   The sequence name.
-- @tab arguments
--   List of passed arguments.
-- @return
--   The loaded sequence function if it can be loaded, nil otherwise.
-- @usage
--   core.load_sequence("foo_sequence", {"arg1", "arg2" })
function _M.load_sequence(name, arguments)
  -- Set up access to channel variables, storage, global and profile configs,
  -- and sequence arguments.
  local env = {
    core = _M,
    global = _M.conf,
    profile = _M.profile,
    args = function(i)
      local arg = arguments[tonumber(i)] or ""
      _M.debug_log("Got sequence arg(%d): '%s'", i, arg)
      return arg
    end,
    storage = protected_get_storage,
    variable = protected_get_variable,
    -- Allow this function so the user can dump to see what's going on in case
    -- of problems.
    debug_dump = _M.debug_dump,

    -- This allows full(ish) access to the Lua API while inside a protected
    -- environment.
    _VERSION = _VERSION,
    assert = assert,
    bit32 = bit32,
    collectgarbage = collectgarbage,
    coroutine = coroutine,
    debug = debug,
    dofile = dofile,
    error = error,
    getmetatable = getmetatable,
    io = io,
    ipairs = ipairs,
    load = load,
    loadfile = loadfile,
    loadstring = loadstring,
    math = math,
    -- module = module,
    next = next,
    os = os,
    package = package,
    pairs = pairs,
    pcall = pcall,
    print = print,
    rawequal = rawequal,
    rawget = rawget,
    rawlen = rawlen,
    rawset = rawset,
    require = require,
    select = select,
    setmetatable = setmetatable,
    string = string,
    table = table,
    tonumber = tonumber,
    tostring = tostring,
    type = type,
    unpack = unpack,
    xpcall = xpcall,
  }
  local filepath = _M.conf.sequence_path .. "/" .. name .. ".lua"
  -- Compat with 5.1, as the extra args to loadfile are ignored.
  local sequence, err = assert(loadfile(filepath, "bt", env))
  if sequence then
    if _VERSION == "Lua 5.1" then
      setfenv(sequence, env)
    end
    return sequence
  end
end

--- Get the value for a key in a storage area.
--
-- This is the function that is exposed to sequences.
--
-- @string area
--   The storage area.
-- @string key
--   The storage key.
-- @return
--   The value stored in the key of the storage area, or an empty string if
--   none is found.
local function protected_get_storage(area, key)
  return _M.get_storage(area, key, "")
end

--- Get the value for a channel variable.
--
-- This is the function that is exposed to sequences.
--
-- @string var
--   The name of the channel variable.
-- @return
--   The value stored in the channel variable, or an empty string if none is
--   found.
local function protected_get_variable(var)
  return _M.get_variable(var, "")
end

--- Get the value for a key in a storage area.
--
-- @string area
--   The storage area.
-- @string key
--   The storage key.
-- @param default
--   The default value for the key if none is found in storage.
-- @return
--   The value stored in the key of the storage area, or the default value if
--   none is found.
-- @usage
--   core.get_storage("foo_area", "bar_key", "default_value")
function _M.get_storage(area, key, default)
  local value
  if _M.channel.storage[area] and _M.channel.storage[area][key] then
    value = _M.channel.storage[area][key]
  -- Fall back to a default if provided.
  elseif default then
    value = default
  end
  _M.debug_log("Getting storage: area '%s', key '%s', value '%s'", area, key, tostring(value))
  return value
end

--- Set a key/value pair in a storage area.
--
-- @string area
--   The storage area.
-- @string key
--   The storage key.
-- @param value
--   The storage value.
-- @usage
--   core.set_storage("foo_area", "bar_key", "baz_value")
function _M.set_storage(area, key, value)
  if area and key and value then
    -- Make sure the storage area exists.
    _M.init_storage(area)
    _M.channel.storage[area][key] = value
    _M.debug_log("Setting storage: area '%s', key '%s', value '%s'", area, key, tostring(value))
  end
end

--- Clear a key in a storage area, or the whole storage area.
--
-- @string area
--   The storage area.
-- @string key
--   The storage key. If not provided, the entire storage area is cleared.
-- @usage
--   core.clear_storage("foo_area", "bar_key")
function _M.clear_storage(area, key)
  if area and key then
    if _M.channel.storage[area] then
      _M.channel.storage[area][key] = nil
      _M.debug_log("Cleared storage: area '%s', key '%s'", area, key)
    end
  elseif area then
    _M.channel.storage[area] = nil
    _M.debug_log("Cleared storage: area '%s'", area)
  end
end

--- Parse a sequence.
--
-- @string sequence
--   The full sequence name command, including arguments.
-- @return sequence type,
--   one of "subsequence", "top\_sequence", "up\_sequence", "".
-- @return sequence name
-- @return arguments,
--   as a string
-- @usage
--   core.parse_sequence("sub:foo_sequence arg1,arg2")
function _M.parse_sequence(sequence)
  sequence = _M.trim(sequence)
  local s_type = "sequence"
  -- Check for stack operators.
  if sequence:sub(1, 4) == "sub:" then
    sequence = sequence:sub(5)
    s_type = "subsequence"
  elseif sequence:sub(1, 4) == "top:" then
    sequence = sequence:sub(5)
    s_type = "top_sequence"
  elseif sequence:sub(1, 3) == "up:" then
    sequence = sequence:sub(4)
    s_type = "up_sequence"
  end
  local sequence_name, sequence_args = string.match(sequence, "^([%w_/]+)%s+(%S+)$")
  if not sequence_name then
    sequence_name = sequence
    sequence_args = ""
  end
  return s_type, sequence_name, sequence_args
end

--- Parse sequence arguments.
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

--[[
  Main entry point for a call to Jester.
]]
function _M.main()
  if _M.conf.debug then
    _M.init_stacks({"run_actions", "executed_sequences"})
  end
  -- Sequences run during an active call.
  _M.run_sequence_loop("active")
  exiting = true
  -- Sequences run that were registered for the exit loop.
  _M.run_sequence_loop("exit")
  if session and not session:ready() then
    hungup = true
    -- Sequences run that were registered for the hangup loop.
    _M.run_sequence_loop("hangup")
  end
  if _M.conf.debug then
    if _M.conf.debug_output.jester_object then
      _M.debug_dump(jester, true)
    end
    if _M.conf.debug_output.executed_sequences then
      _M.debug_log("EXECUTED SEQUENCES:\n%s", table.concat(_M.channel.stack.executed_sequences, "\n"))
    end
    if _M.conf.debug_output.run_actions then
      _M.debug_log("RUN ACTIONS:\n%s", table.concat(_M.channel.stack.run_actions, "\n"))
    end
  end
end

--[[
  Runs the specified sequence loop.
]]
function _M.run_sequence_loop(loop_type)
  _M.debug_log("Executing sequence loop '%s'", loop_type)
  -- Clear the sequence stack prior to execution.
  _M.reset_stack("sequence")
  _M.reset_stack("sequence_name")
  -- Loop through the registered events.
  for _, event in ipairs(_M.channel.stack[loop_type]) do
    -- Fire up the sequence loop.
    if event.event_type == "sequence" then
      _M.queue_sequence(event.sequence)
      _M.execute_sequences()
    -- An ad hoc action was passed, call it directly.
    elseif event.event_type == "action" then
      -- These are always ad hoc actions, so automatically mark them as such.
      event.action.ad_hoc = true
      _M.run_action(event.action)
    end
  end
end

--[[
  Main loop for executing sequences until there are no more in the current
  loop.
]]
function _M.execute_sequences()
  local action, new_action

  -- For the initial call, pre-load the first action.
  action = _M.load_action()
  local clock = os.clock()

  -- Main loop.  This runs until there are no more sequences to run, or the
  -- caller hangs up.
  while _M.ready() and action do
    _M.run_action(action)
    if _M.conf.debug then
      local new_clock = os.clock()
      table.insert(_M.channel.stack.run_actions, #_M.channel.stack.run_actions + 1 .. ": " .. action.action .. ": " .. new_clock - clock)
      clock = new_clock
    end

    -- The action that just ran may have loaded a new sequence, so reload
    -- the current action and compare them.
    new_action = _M.load_action()
    if action == new_action then
      -- Same action that was originally called, move to the next action in
      -- the sequence unless a replay has been requested.
      if _M.channel.stack.sequence[_M.channel.stack.sequence_stack_position].replay_action then
        _M.debug_log("Action replay requested")
        _M.channel.stack.sequence[_M.channel.stack.sequence_stack_position].replay_action = nil
      else
        _M.channel.stack.sequence[_M.channel.stack.sequence_stack_position].position = _M.channel.stack.sequence[_M.channel.stack.sequence_stack_position].position + 1
      end
      _M.refresh_current_sequence()
      action = _M.load_action()
    else
      -- A new sequence was loaded, make it's first action the active action.
      action = _M.load_action()
      _M.debug_log("Action loaded a new sequence")
    end
    -- No more actions in current sequence, but there are more sequences on
    -- stack, pop the finished one and load the previously running sequence.
    if not action and #_M.channel.stack.sequence > 1 then
      local subsequence
      -- The previous stack position may have already finished running its
      -- actions, so keep popping the stack and checking for a valid action
      -- until we find one.
      while _M.ready() and not action and #_M.channel.stack.sequence > 1 do
        subsequence = table.remove(_M.channel.stack.sequence)
        table.remove(_M.channel.stack.sequence_name)
        _M.channel.stack.sequence_stack_position = #_M.channel.stack.sequence
        _M.debug_log("Returning from subsequence '%s', current sequence stack: %s", subsequence.name .. " " .. subsequence.args, table.concat(_M.channel.stack.sequence_name, " | "))
        _M.refresh_current_sequence()
        action = _M.load_action()
      end
    end
  end
  _M.debug_log("No more actions, exiting")
end

--[[
  Reloads the current sequence file, refreshing all variables.
]]
function _M.refresh_current_sequence()
  -- Only refresh if there's a valid action to be run.
  if _M.load_action() then
    _M.channel.stack.sequence[_M.channel.stack.sequence_stack_position].sequence = _M.channel.stack.sequence[_M.channel.stack.sequence_stack_position].file()
  end
end

--[[
  Loads the current action from the current sequence stack and position.
]]
function _M.load_action()
  local stack = _M.channel.stack.sequence
  local p = _M.channel.stack.sequence_stack_position
  if stack[p] then
    return stack[p].sequence[stack[p].position]
  end
end

--[[
  Sets the key map for the currently running action.
]]
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
  _M.debug_log(message, action.action)
end

--[[
  Global key handler for all key press events in Jester.
]]
function _M.key_handler(session, input_type, data)
  if _M.keys and input_type == "dtmf" then
    -- Make sure we get a single digit.
    _M.key_pressed.digit = string.sub(data["digit"], 1, 1)
    -- Pressed key is in the current key map, so it's valid.
    if _M.keys[_M.key_pressed.digit] then
      _M.key_pressed.valid = _M.key_pressed.digit
      _M.debug_log("Key pressed: %s, valid", _M.key_pressed.valid)
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
        _M.debug_log("Key pressed: %s, invalid!", _M.key_pressed.invalid)
        -- By default, replay the current action, but give the option
        -- to load a custom sequence instead.
        if _M.keys.invalid_sequence then
          _M.queue_sequence(_M.keys.invalid_sequence)
        else
          _M.channel.stack.sequence[_M.channel.stack.sequence_stack_position].replay_action = true
        end
        -- Play an invalid sound if specified.
        if _M.keys.invalid_sound then
          _M.debug_log("Playing invalid sound file: %s", _M.keys.invalid_sound)
          session:streamFile(_M.keys.invalid_sound)
        end
        return "break"
      end
    end
  end
end

--[[
  Runs a loaded action.
]]
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
    local mod = require("jester.modules." .. mod_name .. "." .. mod_name)
    _M.debug_log("Loaded module '%s'", mod_name)
    -- Load the handler for the action.
    local func = _M.load_action_handler(action)
    action_func = mod[func]
    if type(action_func) == "function" then
      -- Actions can be called directly from a module or a key press.  These
      -- are not on the sequence stack, so check here if it's an ad hoc
      -- action.
      if action.ad_hoc then
        _M.debug_log("Running ad hoc action '%s'", action.action)
      else
        _M.debug_log("Running action %d (%s) from sequence '%s', function '%s'", stack[p].position, action.action, stack[p].name, func)
      end
      -- Set up key presses for this action -- ad hoc actions don't have key
      -- presses, and may be run when no valid sequence stack is present, so
      -- specifically check for that here to prevent it.
      if not action.ad_hoc then _M.set_keys(action, stack[p].sequence) end
      action_func(action)
    else
      _M.debug_log("Error executing action function '%s', does not exist!", func)
    end
  elseif not action.action then
    _M.debug_log("No valid action parameter, skipping")
  end
end

--[[
  Loads the correct handler for the passed action, falling back to the default
  handler if none is specified.
]]
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

--[[
  Determines if Jester is still in a ready state.  Unlike session:ready(),
  this ready check returns true if Jester is in either its exit or hungup
  states as well.

  Do use this if you want to loop until Jester finishes, don't use this if
  you want to loop until the call hangs up.
]]
function _M.ready()
  -- No session means running from socket or luarun, always ready.
  if not session then
    return true
  else
    return session:ready() or exiting or hungup
  end
end

--[[
  Determines if a key was pressed that will result in some action by core.

  Modules can call this function to check for valid key presses, to break
  out of loops, etc.
]]
function _M.actionable_key()
  return _M.key_pressed.valid or _M.key_pressed.invalid
end

--[[
  Stream silence for a specified number of milliseconds.
]]
function _M.wait(milliseconds)
  _M.debug_log("Waiting %d milliseconds", milliseconds)
  session:streamFile("silence_stream://" .. milliseconds)
end

--[[
  Log to FreeSWITCH console or stdout depending on the environment.
]]
function _M.log(msg, prefix, level)
  if _M.is_freeswitch then
    prefix = prefix or "JESTER"
    level = level or "info"
    freeswitch.consoleLog(level, prefix .. ": " .. tostring(msg) .. "\n")
  else
    print(msg)
  end
end

--[[
  Conditional debug logger.
]]
function _M.debug_log(msg, ...)
  if _M.conf.debug and _M.conf.debug_output.log then
    _M.log(string.format(msg, ...), "JESTER DEBUG")
  end
end

--[[
  Trims whitespace from either end of a string.
]]
function _M.trim(s)
  return (string.gsub(s, "^%s*(.-)%s*$", "%1"))
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
    _M.debug_log("Got value %s: %s", chan_var, tostring(value))
  elseif default then
    value = default
    _M.debug_log("Variable %s returned default: %s", chan_var, tostring(default))
  else
    _M.debug_log("Variable %s: not set", chan_var)
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
  _M.debug_log(message, chan_var, tostring(value))
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
