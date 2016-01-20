--- Access to dialplan applications.
--
-- This module provides access to various dialplan applications. An
-- understanding of how these applications are used in FreeSWITCH dialplans is
-- essential in order to properly use the actions in this module.
--
-- @module dialplan_tools
-- @author Chad Phillips
-- @copyright 2011-2015 Chad Phillips


--- Bridges the current Jester channel with another endpoint.
--
-- Note that many characteristics of the bridge can be controlled by setting
-- various channel variables prior to the bridge. Check the FreeSWITCH wiki for
-- more information on the available channel variables, and
-- @{core_actions.set_variable} for setting channel variables from Jester.
--
-- @action bridge
-- @string action
--   bridge
-- @string channel
--   The channel to use for the bridge. Can be a string (used for all
--   extensions), or optionally a table of multiple channels (used with the
--   matching extension in the extension table). Be sure to include everything
--   up to the actual extension, including trailing slash and any dial prefix.
-- @string extension
--   The extension to bridge to. Can be a string (used for all channels), or
--   optionally a table of multiple extensions (used with the matching channel
--   in the channel table).
-- @bool hangup_after_bridge
--   (Optional) If set to true, the call will be hungup after the bridge
--   completes. Note that all sequences registered for the exit and hangup
--   loops will still be run.
-- @string multichannel_type
--   (Optional) If multiple channels or extensions are specified, this setting
--   determines how they will be connected. 'first\_wins' rings all channels
--   until the first responds with media, then bridges that channel.
--   'sequential' rings each channel in succession, bridging the first one that
--   responds with media. Default is 'first\_wins'.
-- @tab variables
--   A table of channel variables to set for the bridge, key = variable name,
--   value = variable value. Can be a single table (used for all channels), or
--   optionally a table of variable tables (used with the matching channel in
--   the channel list).
-- @usage
--   {
--     action = "bridge",
--     channel = "sofia/internal/",
--     extension = {
--       "1005",
--       "1006",
--     },
--     hangup_after_bridge = true,
--     multichannel_type = "first_wins",
--     variables = {
--       foo = "bar",
--     },
--   }


--- Execute dialplan applications.
--
-- This action provides access to execute any dialplan application via Jester.
-- Note that key presses will not be recognized during the execute action, use
-- the various play and record actions to allow capturing of key presses.
--
-- @action execute
-- @string action
--   execute
-- @string application
--   The application to execute.
-- @string data
--   (Optional) Data to pass to the application.
-- @usage
--   {
--     action = "execute",
--     application = "execute_extension",
--     data = "set_up_call",
--   }


--- Transfer to another extension in the dialplan.
--
-- This action is used to transfer to another extension in the dialplan. Prior
-- to the transfer, the active sequence stack is cleared.
--
-- @action transfer
-- @string action
--   transfer
-- @string context
--   (Optional) The context to transfer to. Default is the current context.
-- @string dialplan
--   (Optional) The dialplan to transfer to. Default is 'XML'.
-- @string extension
--   The extension to transfer to.
-- @usage
--   {
--     action = "transfer",
--     context = "example",
--     dialplan = "XML",
--     extension = "101",
--   }


local core = require "jester.core"

local _M = {}

--[[
  Executes a dialplan application.
]]
function _M.execute(action)
  local application = action.application
  local data = action.data or ""
  if application then
    core.debug_log("Executing dialplan application '%s' with data: %s", application, data)
    session:execute(application, data)
  end
end

--[[
  Transfers the call to another extension.
]]
function _M.transfer(action)
  local extension = action.extension
  local dialplan = action.dialplan or "XML"
  local context = action.context or core.get_variable("context", "default")
  if extension then
    -- Kill all other sequences in the current stack.
    core.reset_stack("sequence")
    core.reset_stack("sequence_name")
    core.debug_log("Transferring to: %s %s %s", extension, dialplan, context)
    session:transfer(extension, dialplan, context)
  end
end

--[[
  Bridges the call to other endpoints.
]]
function _M.bridge(action)
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
    local hangup_var = core.get_variable("hangup_after_bridge", "true")
    core.set_variable("hangup_after_bridge", "false")
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
    core.debug_log("Bridging call to: %s", data)
    session:execute("bridge", data)
    -- Restore the original state of the variable.
    core.set_variable("hangup_after_bridge", hangup_var)
    if hangup_after_bridge then
      session:hangup()
    end
  end
end

--[[
  Given a table of variables, return a string.
]]
local function build_variables(variables, v_type)
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
local function build_channel(variables, channel, extension, multivars, k)
  if multivars and variables[k] then
    channel_vars = build_variables(variables[k])
  else
    channel_vars = ""
  end
  return channel_vars .. channel .. extension
end

return _M
