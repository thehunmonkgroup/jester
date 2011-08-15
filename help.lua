module(..., package.seeall)

jester.conf.debug = false

require "jester.support.string"
require "jester.support.table"

-- The CLI version assumes it's being run from the FreeSWITCH scripts
-- directory, but when run from FreeSWITCH the full path must be specified.
local script_path = "./"
if jester.is_freeswitch then
  script_path = jester.conf.scripts_dir .. "/"
end

--[[
  Initialize the help system.
]]
function init_module_help()
  local help_file
  -- Create a map of all module help that can be called.
  jester.help_map = {}
  for _, mod in ipairs(jester.conf.modules) do
    help_file = "jester.modules." .. mod .. ".help"
    if require(help_file) then
      jester.debug_log("Loaded module help '%s'", help_file)
    else
      jester.debug_log("Failed loading module help '%s'!", help_file)
    end
  end
end

--[[
  Get help for the passed subtopics.
]]
function get_help(...)
  local output = ""
  local help_path, output
  local arguments = {...}
  local arg_string = table.concat(arguments, " ")

  -- Check for special topics first.
  if arguments[1] == "modules" or arguments[1] == "module" or arguments[1] == "actions" or arguments[1] == "action" then
    init_module_help()
    local help_type = "action"
    -- Module help.
    if arguments[1] == "modules" or arguments[1] == "module" then
      help_type = "module"
      if arguments[2] then
        output = module_help_detail(arguments[2])
      else
        output = module_help()
      end
    -- Action help.
    else
      if arguments[2] then
        output =  action_help_detail(arguments[2])
      else
        output = action_help()
      end
    end
    -- Module and action details might return nothing if the arguments were
    -- bad, catch that here.
    if not output then
      output = string.format("No %s help available for '%s'", help_type, arg_string)
    end
  -- General topic help.
  else
    -- Initialize the map.
    jester.help_map = {}
    -- Load all general topics.
    require "lfs"
    local error_message = {}
    local path = script_path .. jester.conf.help_path
    local file_list = {}
    for file in lfs.dir(path) do
      -- Exclude directory references and hidden files.
      if not string.match(file, "^%..*") then
        table.insert(file_list, file)
      end
    end
    -- Since help files are nested tables, we want to enforce an alphabetical
    -- loading order so that help topics nested more deeply can be loaded
    -- after higher topics.
    table.sort(file_list)
    local f, e
    for _, file in ipairs(file_list) do
      f, e = loadfile(path .. "/" .. file)
      if f then
        jester.debug_log("Loaded help file '%s'", file)
        f()
      else
        table.insert(error_message, e)
      end
    end

    if #error_message == 0 then
      -- Navigate into the help tree, and see if the requested subtopic is
      -- available.
      help_path = jester.help_map
      if #arguments > 0 then
        for a = 1, #arguments do
          help_path = help_path[arguments[a]]
          if not help_path then break end
        end
      end
      -- No subtopics passed, start at main help.
      if #arguments == 0 then
        output = topic_help(jester.help_map, true)
      -- Subtopic help found.
      elseif help_path then
        output = topic_help(help_path)
      -- Help subtopic not found.
      else
        output = string.format("No help available for '%s'", arg_string)
      end
    else
      output = string.format("Error loading help files: %s", table.concat(error_message, "; "))
    end
  end
  help_output(output)
end

--[[
  Output help to the appropriate location.
]]
function help_output(help)
  if jester.is_freeswitch then
    stream:write("\n" .. tostring(help) .. "\n")
  else
    print("\n" .. help .. "\n")
  end
end

--[[
  Build topical help.
]]
function topic_help(topic, main)
  local output = {}
  local description
  -- Main help page must be caught and generated specially.
  if main then
    description = welcome()
  else
    description = topic.description_long or topic.description_short
  end
  if description then
    table.insert(output, description:wrap(79))
  end
  -- Grab subtopics for the topic requested.
  local subtopics = {}
  for _, sub in ipairs(table.orderkeys(topic)) do
    if type(topic[sub]) == "table" then
      table.insert(subtopics, sub .. ":")
      if topic[sub].description_short then
        description = topic[sub].description_short:wrap(79, "  ")
      else
        description = ""
      end
      table.insert(subtopics, description)
    end
  end
  if #subtopics > 0 then
    subtopic_list = string.format("SUBTOPICS:\n\n%s", table.concat(subtopics, "\n"))
    table.insert(output, subtopic_list)
  end
  return table.concat(output, "\n\n")
end

--[[
  Main help page text.
]]
function welcome()
  return [[Welcome to Jester help!

Here you'll find extensive information on all the important areas of Jester.  Start by reviewing the topic list below for an area of interest.  The general format for accessing help is 'help [sub-topic] [sub-sub-topic] [...]', and this is how you'll see it referenced internally.]]
end

--[[
  Get a list of all modules in the help system.
]]
function get_modules()
  local module_list = {}
  for _, module_name in ipairs(table.ordervalues(jester.conf.modules)) do
    module_list[module_name] = jester.help_map[module_name]
  end
  return module_list
end

--[[
  Build summary help for all modules.
]]
function module_help()
  local module_list = {}
  local help, description
  -- Build an alphabetical summary of all modules enabled in the global config.
  for _, name in ipairs(table.ordervalues(jester.conf.modules)) do
    help = jester.help_map[name]
    table.insert(module_list, name .. ":")
    if help.description_short then
      description = help.description_short:wrap(79, "  ")
    else
      description = ""
    end
    table.insert(module_list, description)
  end
  return string.format("Run 'help module [name]' to get more help on a specific module.\n\nCurrently installed modules:\n\n%s", table.concat(module_list, "\n"))
end

--[[
  Build detailed help for a module.
]]
function module_help_detail(module_name)
  local description, actions
  -- Loop through all modules looking for the passed one.
  for name_to_check, data in pairs(jester.help_map) do
    if name_to_check == module_name then
      if data.description_long then
        description = data.description_long:wrap(79)
      elseif data.description_short then
        description = data.description_short:wrap(79)
      end
      break
    end
  end
  -- Found the module.
  if description then
    local list = {}
    module_data = jester.help_map[module_name]
    action_data = jester.help_map[module_name].actions
    table.insert(list, description)
    -- Found actions for the module.
    if action_data then
      table.insert(list, "\nACTIONS:")
      -- Build an ordered list of actions.
      for _, action in ipairs(table.orderkeys(action_data)) do
        table.insert(list, "  " .. action .. ":")
        if action_data[action].description_short then
          description = action_data[action].description_short:wrap(79, "    ")
        else
          description = ""
        end
        table.insert(list, description)
      end
    end
    -- Display all handlers for the module.
    if module_data.handlers then
      list = build_handlers(module_data, list)
    end
    return table.concat(list, "\n")
  end
end

--[[
  Build handler help.
]]
function build_handlers(module_data, list)
  local handlers = module_data.handlers
  table.insert(list, "\nHANDLERS:")
  for _, handler in ipairs(table.orderkeys(handlers)) do
    table.insert(list,  "  " .. handler .. ":")
    table.insert(list, handlers[handler]:wrap(79, "    "))
  end
  return list
end

--[[
  Get a list of all actions in the help system.
]]
function get_actions()
  local action_list = {}
  local actions
  for _, module_name in ipairs(table.ordervalues(jester.conf.modules)) do
    actions = jester.help_map[module_name].actions
    for action, data in pairs(actions) do
      action_list[action] = data
    end
  end
  return action_list
end

--[[
  Build summary help for all actions.
]]
function action_help()
  local action_list = {}
  local actions, description
  -- Loop through an alphabetically ordered list of modules.
  for _, module_name in ipairs(table.ordervalues(jester.conf.modules)) do
    actions = jester.help_map[module_name].actions
    table.insert(action_list, "\nModule: " .. module_name)
    -- Build and alphabetical list of actions for the module.
    for _, action in ipairs(table.orderkeys(actions)) do
      table.insert(action_list, "  " .. action .. ":")
      if actions[action].description_short then
        description = actions[action].description_short:wrap(79, "    ")
      else
        description = ""
      end
      table.insert(action_list, description)
    end
  end
  return string.format("Run 'help action [name]' to get more help on a specific action.\n\nCurrently installed actions:\n%s", table.concat(action_list, "\n"))
end

--[[
  Build detailed help for an action.
]]
function action_help_detail(action)
  -- Loop through the modules looking for the passed action.
  for _, module_data in pairs(jester.help_map) do
    for action_to_check, action_data in pairs(module_data.actions) do
      -- Found the action.
      if action_to_check == action then
        local list = {}
        local description
        if action_data.description_long then
          description = action_data.description_long:wrap(79)
        elseif action_data.description_short then
          description = action_data.description_short:wrap(79)
        else
          description = ""
        end
        table.insert(list, description)
        -- Look for parameters for the action.
        local params = action_data.params
        if params then
          table.insert(list, "\nPARAMETERS:")
          -- Build an ordered list of parameters.
          for _, param in ipairs(table.orderkeys(params)) do
            table.insert(list,  "  " .. param .. ":")
            table.insert(list, params[param]:wrap(79, "    "))
          end
        end
        -- Display available handlers for the action.
        if module_data.handlers then
          list = build_handlers(module_data, list)
        end
        return table.concat(list, "\n")
      end
    end
  end
end

