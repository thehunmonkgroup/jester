module(..., package.seeall)

--[[
  Executes a dialplan application.
]]
function execute(action)
  local application = action.application
  local data = action.data or ""
  if application then
    jester.debug_log("Executing dialplan application '%s' with data: %s", application, data)
    session:execute(application, data)
  end
end

--[[
  Transfers the call to another extension.
]]
function transfer(action)
  local extension = action.extension
  local dialplan = action.dialplan or "XML"
  local context = action.context or jester.get_variable("context", "default")
  if extension then
    -- Kill all other sequences in the current stack.
    jester.reset_stack("sequence")
    jester.reset_stack("sequence_name")
    jester.debug_log("Transferring to: %s %s %s", extension, dialplan, context)
    session:transfer(extension, dialplan, context)
  end
end

--[[
  Bridges the call to other endpoints.
]]
function bridge(action)
  local channel = action.channel
  local extension = action.extension
  local variables = action.variables or {}
  local multichannel_type = action.multichannel_type or "first_wins"
  local hangup_after_bridge = action.hangup_after_bridge
  local data = ""
  local global_vars = ""
  local multivars, separator

  -- A numeric key means it's multiple variable tables.
  if variables[1] then
    multivars = true
  else
    global_vars = build_variables(variables, "global")
  end
  if channel and extension then
    -- Save the current state of the variable so it can be restored.
    local hangup_var = jester.get_variable("hangup_after_bridge", "true")
    jester.set_variable("hangup_after_bridge", "false")
    -- Complex dialstring.
    if type(channel) == "table" or type(extension) == "table" then
      local channel_pieces = {}
      -- Multiple channels and one extension.
      if type(channel) == "table" and type(extension) == "string" then
        for k, chan in ipairs(channel) do
          table.insert(channel_pieces, build_channel(variables, chan, extension, multivars, k))
        end
      -- Multiple extensions and one channel.
      elseif type(channel) == "string" and type(extension) == "table" then
        for k, exten in ipairs(extension) do
          table.insert(channel_pieces, build_channel(variables, channel, exten, multivars, k))
        end
      -- Multiple extensions and channels.
      else
        for k, chan in ipairs(channel) do
          table.insert(channel_pieces, build_channel(variables, chan, extension[k], multivars, k))
        end
      end
      if multichannel_type == "first_wins" then
        separator = ","
      elseif multichannel_type == "sequential" then
        separator = "|"
      end
      data = table.concat(channel_pieces, separator)
    -- Simple dialsting.
    else
      data = channel .. extension
    end
    data = global_vars .. data
    jester.debug_log("Bridging call to: %s", data)
    session:execute("bridge", data)
    -- Restore the original state of the variable.
    jester.set_variable("hangup_after_bridge", hangup_var)
    if hangup_after_bridge then
      session:hangup()
    end
  end
end

--[[
  Given a table of variables, return a string.
]]
function build_variables(variables, v_type)
  local output = ""
  local string_pieces = {}
  for k, v in pairs(variables) do
    table.insert(string_pieces, k .. "='" .. v .."'")
  end
  if #string_pieces > 0 then
    output = table.concat(string_pieces, ",")
    if v_type == "global" then
      output = "{" .. output .. "}"
    else
      output = "[" .. output .. "]"
    end
  end
  return output
end

--[[
  Given a the main variables table and location data, a channel and extension,
  return a fully constructed channel string for the channel.
]]
function build_channel(variables, channel, extension, multivars, k)
  if multivars and variables[k] then
    channel_vars = build_variables(variables[k])
  else
    channel_vars = ""
  end
  return channel_vars .. channel .. extension
end

