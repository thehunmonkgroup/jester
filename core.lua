module("jester", package.seeall)

Channel = {}

function init_modules()
  local conf_file
  -- Create a lightweight map of all actions that can be called.
  action_map = {}
  for _, mod in ipairs(conf.modules) do
    conf_file = "jester.modules." .. mod .. ".conf"
    if require(conf_file) then
      debug_log("Loaded module configuration '%s'", conf_file)
    else
      debug_log("Failed loading module configuration '%s'!", conf_file)
    end
  end
end

function init_channel(o)
  debug_log("Creating channel table")
  channel = {}
  channel.stack = {}
  channel.storage = {}
  channel.uuid = get_variable("uuid")
  init_stacks()
end

function init_stacks()
  -- Set up initial stacks.
  local stacks = {"active", "exit", "hangup", "sequence", "sequence_name"}
  for _, name in ipairs(stacks) do
    reset_stack(name)
  end
end

function init_profile(profile_name)
  require("jester.profiles." .. profile_name .. ".conf")
  profile = profiles[profile_name].conf

  -- Profile overrides.
  local overrides = {
    "debug",
    "profile_path",
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

function init_storage(area)
  if channel and not channel.storage[area] then
    channel.storage[area] = {}
  end
end

function reset_stack(name)
  debug_log("Reset stack '%s'", name)
  channel.stack[name] = {}
end

function run_sequence(sequence)
  if ready() and sequence then
    local parsed_args, loaded_sequence, add_to_stack, remove_from_stack
    sequence = trim(sequence)
    local s_type = "Sequence"
    if sequence:sub(1, 4) == "sub:" then
      sequence = sequence:sub(5)
      add_to_stack = true
      s_type = "Subsequence"
    elseif sequence:sub(1, 4) == "top:" then
      sequence = sequence:sub(5)
      -- Emptying the stack here will trigger putting the sequence on the top
      -- of a fresh stack.
      reset_stack("sequence")
      reset_stack("sequence_name")
      s_type = "Top sequence"
    elseif sequence:sub(1, 3) == "up:" then
      sequence = sequence:sub(4)
      remove_from_stack = true
      s_type = "Up sequence"
    end
    local stack = channel.stack.sequence
    if #stack == 0 then
      add_to_stack = true
    end
    local sequence_name, sequence_args = string.match(sequence, "^([%w_]+)%s+([%w_,]+)$")
    if not sequence_name then
      sequence_name = sequence
      sequence_args = ""
    end
    debug_log("%s called: %s, args: %s", s_type, sequence_name, sequence_args)
    parsed_args = parse_args(sequence_args)
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

function load_sequence(name, arguments)
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
    debug_dump = debug_dump,
  }
  local sequence, err = assert(loadfile(conf.sequence_path .. "/" .. name .. ".lua"))
  if sequence then
    setfenv(sequence, env)
    return sequence
  end
end

function get_storage(area, key, default)
  local value
  if channel.storage[area] and channel.storage[area][key] then
    value = channel.storage[area][key]
  elseif default then
    value = default
  end
  debug_log("Getting storage: area '%s', key '%s', value '%s'", area, key, tostring(value))
  return value
end

function set_storage(area, key, value)
  if area and key and value then
    init_storage(area)
    channel.storage[area][key] = value
    debug_log("Setting storage: area '%s', key '%s', value '%s'", area, key, value)
  end
end

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

function main()
  run_sequence_loop("active")
  exiting = true
  run_sequence_loop("exit")
  if session and not session:ready() then
    hungup = true
    run_sequence_loop("hangup")
  end
end

function run_sequence_loop(loop_type)
  debug_log("Executing sequence loop '%s'", loop_type)
  reset_stack("sequence")
  reset_stack("sequence_name")
  for _, event in ipairs(channel.stack[loop_type]) do
    if event.event_type == "sequence" then 
      run_sequence(event.sequence)
      execute_sequences()
    elseif event.event_type == "action" then
      run_action(event)
    end
  end
end

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

function load_action()
  local stack = channel.stack.sequence
  local p = channel.stack.sequence_stack_position
  if stack[p] then
    return stack[p].sequence[stack[p].position]
  end
end

function set_keys(action, sequence)
  -- Clear any key press data from the previously run action.
  key_pressed = {}
  local message
  if type(action.keys) == "table" then
    keys = action.keys
    message = "Set keys for action '%s'"
  elseif type(sequence.keys) == "table" then
    keys = sequence.keys
    message = "Set default sequence keys for action '%s'"
  else
    keys = nil
    message = "No keys to set for action '%s'"
  end
  debug_log(message, action.action)
end

function key_handler(session, input_type, data)
  if keys and input_type == "dtmf" then
    -- Make sure we get a single digit.
    key_pressed.digit = string.sub(data["digit"], 1, 1)
    if keys[key_pressed.digit] then
      key_pressed.valid = key_pressed.digit
      debug_log("Key pressed: %s, valid", key_pressed.valid)
      local marker, command = string.match(keys[key_pressed.digit], "^([:@]?)(.+)")
      if marker == ":" then
        return command
      elseif marker == "@" then
        local action = { action = command, ad_hoc = true }
        run_action(action)
      else
        run_sequence(command)
      end
      return "break"
    else
      if keys.invalid or keys.invalid_sound then
        key_pressed.invalid = key_pressed.digit
        debug_log("Key pressed: %s, invalid!", key_pressed.invalid)
        -- By default, replay the current action, but give the option
        -- to load a custom sequence instead.
        if keys.invalid_sequence then
          run_sequence(keys.invalid_sequence)
        else
          channel.stack.sequence[channel.stack.sequence_stack_position].replay_action = true
        end
        if keys.invalid_sound then
          debug_log("Playing invalid sound file: %s", keys.invalid_sound)
          session:streamFile(keys.invalid_sound)
        end
        return "break"
      end
    end
  end
end

function run_action(action)
  if ready() and action.action then
    local stack = channel.stack.sequence
    local p = channel.stack.sequence_stack_position
    local mod
    if action_map[action.action] then
      mod = action_map[action.action].mod
    else
      error(string.format([[JESTER: No valid action '%s']], action.action))
    end
    require("jester.modules." .. mod .. "." .. mod)
    debug_log("Loaded module '%s'", mod)
    local func = load_action_handler(action)
    action_func = modules[mod][mod][func]
    if type(action_func) == "function" then
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

function ready()
  return session:ready() or exiting or hungup
end

function actionable_key()
  return jester.key_pressed.valid or jester.key_pressed.invalid
end

function wait(milliseconds)
  debug_log("Waiting %d milliseconds", milliseconds)
  session:streamFile("silence_stream://" .. milliseconds)
end

function log(msg, prefix, level)
  if jester.is_freeswitch then
    prefix = prefix or "JESTER"
    level = level or "info"
    freeswitch.consoleLog(level, prefix .. ": " .. tostring(msg) .. "\n")
  else
    print(msg)
  end
end

function debug_log(msg, ...)
  if jester.conf.debug then
    log(string.format(msg, ...), "JESTER DEBUG")
  end
end

--[[
  Trims whitespace from either end of a string.
]]
function trim (s)
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

