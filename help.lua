module(..., package.seeall)

require "jester.support.string"
require "jester.support.table"

local script_path, is_freeswitch = "", false
if jester.is_freeswitch then
  local api = freeswitch.API()
  local base_dir = api:executeString("global_getvar base_dir")
  script_path = base_dir .. "/scripts/"
end

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

function get_help(...)
  local output = ""
  local help_path, output
  local arguments = {...}
  local arg_string = table.concat(arguments, " ")

  if arguments[1] == "modules" or arguments[1] == "module" or arguments[1] == "actions" or arguments[1] == "action" then
    init_module_help()
    local help_type = "action"
    if arguments[1] == "modules" or arguments[1] == "module" then
      help_type = "module"
      if arguments[2] then
        output = module_help_detail(arguments[2])
      else
        output = module_help()
      end
    else
      if arguments[2] then
        output =  action_help_detail(arguments[2])
      else
        output = action_help()
      end
    end
    if not output then
      output = string.format("No %s help available for '%s'", help_type, arg_string)
    end
  else
    jester.help = {}
    require "lfs"
    local error_message = {}
    local path = script_path .. jester.conf.help_path
    local dir = lfs.dir(path)
    local file_list = {}
    for file in dir do
      if file ~= "." and file ~= ".." then
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
      help_path = jester.help
      if #arguments > 0 then
        for a = 1, #arguments do
          help_path = help_path[arguments[a]]
          if not help_path then break end
        end
      end
      if #arguments == 0 then
        output = topic_help(jester.help, true)
      elseif help_path then
        output = topic_help(help_path)
      else
        output = string.format("No help available for '%s'", arg_string)
      end
    else
      output = string.format("Error loading help files: %s", table.concat(error_message, "; "))
    end
  end
  help_output(output)
end

function help_output(help)
  if jester.is_freeswitch then
    freeswitch.consoleLog("info", "\n" .. tostring(help) .. "\n")
  else
    print("\n" .. help .. "\n")
  end
end

function topic_help(topic, main)
  local output = {}
  local description
  if main then
    description = welcome()
  else
    description = topic.description_long or topic.description_short
  end
  if description then
    table.insert(output, description:wrap(79))
  end
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

function module_help()
  local module_list = {}
  local help, description
  for _, name in ipairs(table.ordervalues(jester.conf.modules)) do
    help = jester.help[name]
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

function module_help_detail(module_name)
  local description, actions
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
  if description then
    local list = {}
    module_data = jester.help_map[module_name]
    action_data = jester.help_map[module_name].actions
    table.insert(list, description)
    if action_data then
      table.insert(list, "\nACTIONS:")
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
    if module_data.handlers then
      list = build_handlers(module_data, list)
    end
    return table.concat(list, "\n")
  end
end

function build_handlers(module_data, list)
  local handlers = module_data.handlers
  table.insert(list, "\nHANDLERS:")
  for _, handler in ipairs(table.orderkeys(handlers)) do
    table.insert(list,  "  " .. handler .. ":")
    table.insert(list, handlers[handler]:wrap(79, "    "))
  end
  return list
end

function welcome()
  return [[Welcome to Jester help!

Here you'll find extensive information on all the important areas of Jester.  Start by reviewing the topic list below for an area of interest.  The general format for accessing help is 'help [sub-topic] [sub-sub-topic] [...]', and this is how you'll see it referenced internally.

The exact way help is called depends on where you're calling it from.  'help module data' would be called in the following ways depending on where/how you're accessing help:
  From the command line:
    cd /path/to/freeswitch/scripts
    lua jester.lua help module data
  From the FreeSWITCH console:
    luarun jester.lua help module data
  Using the jhelp script (find this in the jester/scripts directory):
    jhelp module data]]
end

function action_help()
  local action_list = {}
  local actions, description
  for _, module_name in ipairs(table.ordervalues(jester.conf.modules)) do
    actions = jester.help[module_name].actions
    table.insert(action_list, "\nModule: " .. module_name)
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

function action_help_detail(action)
  for _, module_data in pairs(jester.help_map) do
    for action_to_check, action_data in pairs(module_data.actions) do
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
        local params = action_data.params
        if params then
          table.insert(list, "\nPARAMETERS:")
          for _, param in ipairs(table.orderkeys(params)) do
            table.insert(list,  "  " .. param .. ":")
            table.insert(list, params[param]:wrap(79, "    "))
          end
        end
        if module_data.handlers then
          list = build_handlers(module_data, list)
        end
        return table.concat(list, "\n")
      end
    end
  end
end

