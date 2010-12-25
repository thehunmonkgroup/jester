module("jester", package.seeall)

--[[
  Initialize the specified modules.
]]
function init_modules(modules)
  local conf_file
  -- Create a lightweight map of all actions that can be called.
  -- Modules and custom scripts can call this function to load
  -- additional modules, so make sure that any existing action_map
  -- is preserved.
  action_map = action_map or {}
  for _, mod in ipairs(modules) do
    conf_file = "jester.modules." .. mod .. ".conf"
    if require(conf_file) then
      debug_log("Loaded module configuration '%s'", conf_file)
    else
      debug_log("Failed loading module configuration '%s'!", conf_file)
    end
  end
end

--[[
  Initialize the channel namespace.  This holds all the stacks and storage
  for a Jester run.
]]
function init_channel(o)
  debug_log("Creating channel table")
  channel = {}
  channel.stack = {}
  channel.storage = {}
  channel.uuid = get_variable("uuid")
end

--[[
  Initialize the specified stacks.
]]
function init_stacks(stacks)
  for _, name in ipairs(stacks) do
    reset_stack(name)
  end
end

--[[
  Initialize the specified profile.
]]
function init_profile(profile_name)
  -- Load the profile configuration, and set up the profile namespace.
  require("jester.profiles." .. profile_name .. ".conf")
  profile = profiles[profile_name].conf

  -- Profile overrides -- these can optionally override settings in the global
  -- configuration file.
  local overrides = {
    "debug",
    "sequence_path",
    "modules",
    "key_order",
  }
  for _, override in ipairs(overrides) do
    if profile[override] then
      conf[override] = profile[override]
    end
  end
end

--[[
  Initialize a storage area.
]]
function init_storage(area)
  if channel and not channel.storage[area] then
    channel.storage[area] = {}
  end
end

--[[
  Empties the specified stack.  Can also be used to initialize a stack.
]]
function reset_stack(name)
  debug_log("Reset stack '%s'", name)
  channel.stack[name] = {}
end

--[[
  Queues the sequence to be the next one run in the current sequence loop,
  at the current sequence stack position.
]]
function queue_sequence(sequence)
  if ready() and sequence then
    local loaded_sequence, add_to_stack, remove_from_stack
    -- Parse out the sequence name and arguments.
    local s_type, sequence_name, sequence_args = parse_sequence(sequence)
    debug_log("%s called: %s, args: %s", s_type, sequence_name, sequence_args)
    local parsed_args = parse_args(sequence_args)
    -- Check for stack operators, sub goes one level deeper, up goes one
    -- level up, top resets the stack.
    if s_type == "subsequence" then
      add_to_stack = true
    elseif s_type == "top_sequence" then
      -- Emptying the stack here will trigger putting the sequence on the top
      -- of a fresh stack.
      reset_stack("sequence")
      reset_stack("sequence_name")
    elseif s_type == "up_sequence" then
      remove_from_stack = true
    end
    local stack = channel.stack.sequence
    -- Nothing on the current stack, add this sequence on the first stack.
    if #stack == 0 then
      add_to_stack = true
    end
    -- Load the sequence.
    loaded_sequence = load_sequence(sequence_name, parsed_args)
    if loaded_sequence then
      debug_log("Loaded sequence '%s'", sequence_name)
      if add_to_stack then
        -- Increment the action position of the currently running sequence, as
        -- if/when it resumes it's already run the action it was running when
        -- the subsequence was called.  Skip this if the stack is empty.
        if #stack > 0 then channel.stack.sequence[#stack].position = stack[#stack].position + 1 end
        table.insert(channel.stack.sequence, {})
        table.insert(channel.stack.sequence_name, sequence)
      -- Remove the last item from the stack if there's more than 1.
      elseif remove_from_stack and #stack > 1 then
        table.remove(channel.stack.sequence)
        table.remove(channel.stack.sequence_name)
      end
      debug_log("Current sequence stack: %s", table.concat(channel.stack.sequence_name, " | "))
      channel.stack.sequence_stack_position = #stack
      local p = channel.stack.sequence_stack_position
      -- There might be data in here from before, so reset it.
      channel.stack.sequence[p] = {}
      channel.stack.sequence[p].file = loaded_sequence
      channel.stack.sequence[p].sequence = loaded_sequence()
      channel.stack.sequence[p].name = sequence_name
      channel.stack.sequence[p].args = sequence_args
      channel.stack.sequence[p].parsed_args = parsed_args
      channel.stack.sequence[p].position = 1
    else
      debug_log("Failed loading sequence '%s'!", sequence_name)
    end
  end
end

--[[
  Loads the specified sequence into a protected function environment.
]]
function load_sequence(name, arguments)
  -- Set up access to channel variables, storage, global and profile configs,
  -- and sequence arguments.
  local env = {
    global = conf,
    profile = profile,
    args = function(i)
      return arguments[tonumber(i)] or ""
    end,
    storage = function (area, key)
      return get_storage(area, key, "")
    end,
    variable = function (var)
      return get_variable(var, "")
    end,
    -- Allow this function so the user can dump to see what's going on in case
    -- of problems.
    debug_dump = debug_dump,
  }
  local sequence, err = assert(loadfile(conf.sequence_path .. "/" .. name .. ".lua"))
  if sequence then
    -- Lock out access to the rest of the Lua environment.
    setfenv(sequence, env)
    return sequence
  end
end

--[[
  Get the value for a key in a storage area.
]]
function get_storage(area, key, default)
  local value
  if channel.storage[area] and channel.storage[area][key] then
    value = channel.storage[area][key]
  -- Fall back to a default if provided.
  elseif default then
    value = default
  end
  debug_log("Getting storage: area '%s', key '%s', value '%s'", area, key, tostring(value))
  return value
end

--[[
  Set a key/value pair in a storage area.
]]
function set_storage(area, key, value)
  if area and key and value then
    -- Make sure the storage area exists.
    init_storage(area)
    channel.storage[area][key] = value
    debug_log("Setting storage: area '%s', key '%s', value '%s'", area, key, value)
  end
end

--[[
  Clear a key in a storage area, or the whole storage area.
]]
function clear_storage(area, key)
  if area and key then
    if channel.storage[area] then
      channel.storage[area][key] = nil
      debug_log("Cleared storage: area '%s', key '%s'", area, key)
    end
  elseif area then
    channel.storage[area] = nil
    debug_log("Cleared storage: area '%s'", area)
  end
end

--[[
  Parse sequence, return the sequence name and sequence args.
]]
function parse_sequence(sequence)
  sequence = trim(sequence)
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
  local sequence_name, sequence_args = string.match(sequence, "^([%w_]+)%s+([%w_,]+)$")
  if not sequence_name then
    sequence_name = sequence
    sequence_args = ""
  end
  return s_type, sequence_name, sequence_args
end

--[[
  Parse sequence arguments, and return them as an ordered list.
]]
function parse_args(args)
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
function main()
  run_sequence_loop("active")
  exiting = true
  run_sequence_loop("exit")
  if session and not session:ready() then
    hungup = true
    run_sequence_loop("hangup")
  end
  if debug then
    debug_dump(jester, true)
  end
end

--[[
  Runs the specified sequence loop.
]]
function run_sequence_loop(loop_type)
  debug_log("Executing sequence loop '%s'", loop_type)
  -- Clear the sequence stack prior to execution.
  reset_stack("sequence")
  reset_stack("sequence_name")
  -- Loop through the registered events.
  for _, event in ipairs(channel.stack[loop_type]) do
    -- Fire up the sequence loop.
    if event.event_type == "sequence" then
      queue_sequence(event.sequence)
      execute_sequences()
    -- An ad hoc action was passed, call it directly.
    elseif event.event_type == "action" then
      -- These are always ad hoc actions, so automatically mark them as such.
      event.action.ad_hoc = true
      run_action(event.action)
    end
  end
end

--[[
  Main loop for executing sequences until there are no more in the current
  loop.
]]
function execute_sequences()
  local action, new_action

  -- For the initial call, pre-load the first action.
  action = load_action()

  -- Main loop.  This runs until there are no more sequences to run, or the
  -- caller hangs up.
  while ready() and action do
    run_action(action)
    -- The action that just ran may have loaded a new sequence, so reload
    -- the current action and compare them.
    new_action = load_action()
    if action == new_action then
      -- Same action that was originally called, move to the next action in
      -- the sequence unless a replay has been requested.
      if channel.stack.sequence[channel.stack.sequence_stack_position].replay_action then
        debug_log("Action replay requested")
        channel.stack.sequence[channel.stack.sequence_stack_position].replay_action = nil
      else
        channel.stack.sequence[channel.stack.sequence_stack_position].position = channel.stack.sequence[channel.stack.sequence_stack_position].position + 1
      end
      -- Reload the sequence file, so variables will be refreshed.
      channel.stack.sequence[channel.stack.sequence_stack_position].sequence = channel.stack.sequence[channel.stack.sequence_stack_position].file()
      action = load_action()
    else
      -- A new sequence was loaded, make it's first action the active action.
      action = load_action()
      debug_log("Action loaded a new sequence")
    end
    -- No more actions in current sequence, but there are more sequences on
    -- stack, pop the finished one and load the previously running sequence.
    if not action and #channel.stack.sequence > 1 then
      local subsequence = table.remove(channel.stack.sequence)
      table.remove(channel.stack.sequence_name)
      channel.stack.sequence_stack_position = #channel.stack.sequence
      debug_log("Returning from subsequence '%s', current sequence stack: %s", subsequence.name .. " " .. subsequence.args, table.concat(channel.stack.sequence_name, " | "))
      action = load_action()
    end
  end
  debug_log("No more actions, exiting")
end

--[[
  Loads the current action from the current sequence stack and position.
]]
function load_action()
  local stack = channel.stack.sequence
  local p = channel.stack.sequence_stack_position
  if stack[p] then
    return stack[p].sequence[stack[p].position]
  end
end

--[[
  Sets the key map for the currently running action.
]]
function set_keys(action, sequence)
  -- Clear any key press data from the previously run action.  This prevents
  -- false key press detections on the current action.
  key_pressed = {}
  local message
  -- Key maps defined in the action take precedence.
  if type(action.keys) == "table" then
    keys = action.keys
    message = "Set keys for action '%s'"
  -- Fall back to sequence-wide key map if present.
  elseif type(sequence.keys) == "table" then
    keys = sequence.keys
    message = "Set default sequence keys for action '%s'"
  -- No key map.  Explicitely unset it here so that no action at all is taken
  -- by the input callback function during this action.
  else
    keys = nil
    message = "No keys to set for action '%s'"
  end
  debug_log(message, action.action)
end

--[[
  Global key handler for all key press events in Jester.
]]
function key_handler(session, input_type, data)
  if keys and input_type == "dtmf" then
    -- Make sure we get a single digit.
    key_pressed.digit = string.sub(data["digit"], 1, 1)
    -- Pressed key is in the current key map, so it's valid.
    if keys[key_pressed.digit] then
      key_pressed.valid = key_pressed.digit
      debug_log("Key pressed: %s, valid", key_pressed.valid)
      -- Parse the key value.  Values prefixed with @ are ad hoc actions,
      -- values prefixed with : are playback commands to return to core
      -- for playback control (break, seek, etc).
      local marker, command = string.match(keys[key_pressed.digit], "^([:@]?)(.+)")
      if marker == ":" then
        return command
      elseif marker == "@" then
        local action = { action = command, ad_hoc = true }
        run_action(action)
      else
        queue_sequence(command)
      end
      return "break"
    -- Invalid key pressed.
    else
      -- Check to see if the key map wants us to take some action on the
      -- invalid key.
      if keys.invalid or keys.invalid_sound or keys.invalid_sequence then
        key_pressed.invalid = key_pressed.digit
        debug_log("Key pressed: %s, invalid!", key_pressed.invalid)
        -- By default, replay the current action, but give the option
        -- to load a custom sequence instead.
        if keys.invalid_sequence then
          queue_sequence(keys.invalid_sequence)
        else
          channel.stack.sequence[channel.stack.sequence_stack_position].replay_action = true
        end
        -- Play an invalid sound if specified.
        if keys.invalid_sound then
          debug_log("Playing invalid sound file: %s", keys.invalid_sound)
          session:streamFile(keys.invalid_sound)
        end
        return "break"
      end
    end
  end
end

--[[
  Runs a loaded action.
]]
function run_action(action)
  if ready() and action.action then
    local stack = channel.stack.sequence
    local p = channel.stack.sequence_stack_position
    local mod
    -- Find the module that provides this action.
    if action_map[action.action] then
      mod = action_map[action.action].mod
    else
      error(string.format([[JESTER: No valid action '%s']], action.action))
    end
    -- Load the module.  Since Lua caches loaded modules, this is only an
    -- expensive operation the first time the module code is loaded.
    require("jester.modules." .. mod .. "." .. mod)
    debug_log("Loaded module '%s'", mod)
    -- Load the handler for the action.
    local func = load_action_handler(action)
    action_func = modules[mod][mod][func]
    if type(action_func) == "function" then
      -- Actions can be called directly from a module or a key press.  These
      -- are not on the sequence stack, so check here if it's an ad hoc
      -- action.
      if action.ad_hoc then
        debug_log("Running ad hoc action '%s'", action.action)
      else
        debug_log("Running action %d (%s) from sequence '%s', function '%s'", stack[p].position, action.action, stack[p].name, func)
      end
      -- Set up key presses for this action -- ad hoc actions don't have key
      -- presses, and may be run when no valid sequence stack is present, so
      -- specifically check for that here to prevent it.
      if not action.ad_hoc then set_keys(action, stack[p].sequence) end
      action_func(action)
    else
      debug_log("Error executing action function '%s', does not exist!", func)
    end
  elseif not action.action then
    debug_log("No valid action parameter, skipping")
  end
end

--[[
  Loads the correct handler for the passed action, falling back to the default
  handler if none is specified.
]]
function load_action_handler(action)
  local func
  local handlers = action_map[action.action].handlers
  if handlers then
    if action.handler and handlers[action.handler] then
      func = handlers[action.handler]
    else
      func = handlers.default
    end
  else
    func = action_map[action.action].func
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
function ready()
  return session:ready() or exiting or hungup
end

--[[
  Determines if a key was pressed that will result in some action by core.

  Modules can call this function to check for valid key presses, to break
  out of loops, etc.
]]
function actionable_key()
  return jester.key_pressed.valid or jester.key_pressed.invalid
end

--[[
  Stream silence for a specified number of milliseconds.
]]
function wait(milliseconds)
  debug_log("Waiting %d milliseconds", milliseconds)
  session:streamFile("silence_stream://" .. milliseconds)
end

--[[
  Log to FreeSWITCH console or stdout depending on the environment.
]]
function log(msg, prefix, level)
  if jester.is_freeswitch then
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
function debug_log(msg, ...)
  if jester.conf.debug then
    log(string.format(msg, ...), "JESTER DEBUG")
  end
end

--[[
  Trims whitespace from either end of a string.
]]
function trim(s)
  return (string.gsub(s, "^%s*(.-)%s*$", "%1"))
end

--[[
  Wrapper to grab session variables.
]]
function get_variable(call_var, default)
  local value = session:getVariable(call_var)
  if value then
    debug_log("Got value %s: %s", call_var, tostring(value))
  elseif default then
    value = default
    debug_log("Variable %s returned default: %s", call_var, tostring(default))
  else
    debug_log("Variable %s: not set", call_var)
  end

  return value
end

--[[
  Wrapper to set session variables.
]]
function set_variable(call_var, value, default)
  local message
  if value then
    message = "Set value %s: %s"
  else
    value = default
    message = "Set value %s to default: %s"
  end
  session:setVariable(call_var, value)
  debug_log(message, call_var, tostring(value))
end

