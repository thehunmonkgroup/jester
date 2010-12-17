module(..., package.seeall)

require "jester.support.string"

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
    local f, e
    for file in dir do
      if file ~= "." and file ~= ".." then
        f, e = loadfile(path .. "/" .. file)
        if f then
          f()
        else
          table.insert(error_message, e)
        end
      end
    end

    if #error_message == 0 then
      help_path = jester.help
      for a = 1, #arguments do
        help_path = help_path[arguments[a]]
        if not help_path then break end
      end
      if help_path then
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

function topic_help(topic)
  local output = {}
  local description = topic.description_long or topic.description_short
  if description then
    table.insert(output, description:wrap(79))
  end
  local subtopics = {}
  for sub, data in pairs(topic) do
    if type(data) == "table" then
      table.insert(subtopics, sub .. ":")
      table.insert(subtopics, data.description_short:wrap(79, "  ") or "")
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
  for _, name in ipairs(jester.conf.modules) do
    table.insert(module_list, name .. ":")
    table.insert(module_list, jester.help_map[name].description_short:wrap(79, "  ") or "")
  end
  return string.format("Run 'help module [name]' to get more help on a specific module.\n\nCurrently installed modules:\n\n%s", table.concat(module_list, "\n"))
end

function module_help_detail(module_name)
  local description, actions
  local action_list = {}
  for name_to_check, data in pairs(jester.help_map) do
    if name_to_check == module_name then
      description = data.description_long:wrap(79) or data.description_short:wrap(79) or ""
      break
    end
  end
  if description then
    local list = {}
    module_data = jester.help_map[module_name]
    action_data = jester.help_map[module_name].actions
    table.insert(list, module_data.description_long:wrap(79) or module_data.description_short:wrap(79) or "")
    if action_data then
      table.insert(list, "\nACTIONS:")
      for action, data in pairs(action_data) do
        table.insert(list, "  " .. action .. ":")
        table.insert(list, data.description_short:wrap(79, "    ") or "")
      end
    end
    if module_data.handlers then
      table.insert(list, "\nHANDLERS:")
      for handler, desc in pairs(module_data.handlers) do
        table.insert(list,  "  " .. handler .. ":")
        table.insert(list, desc:wrap(79, "    "))
      end
    end
    return table.concat(list, "\n")
  end
end

function action_help()
  local action_list = {}
  for _, module_name in ipairs(jester.conf.modules) do
    table.insert(action_list, "\nModule: " .. module_name)
    for action, data in pairs(jester.help_map[module_name].actions) do
      table.insert(action_list, "  " .. action .. ":")
      table.insert(action_list, data.description_short:wrap(79, "    ") or "")
    end
  end
  return string.format("Run 'help action [name]' to get more help on a specific action.\n\nCurrently installed actions:\n%s", table.concat(action_list, "\n"))
end

function action_help_detail(action)
  for _, module_data in pairs(jester.help_map) do
    for action_to_check, action_data in pairs(module_data.actions) do
      if action_to_check == action then
        local list = {}
        table.insert(list, action_data.description_long:wrap(79) or action_data.description_short:wrap(79) or "")
        if action_data.params then
          table.insert(list, "\nPARAMETERS:")
          for param, desc in pairs(action_data.params) do
            table.insert(list,  "  " .. param .. ":")
            table.insert(list, desc:wrap(79, "    "))
          end
        end
        if module_data.handlers then
          table.insert(list, "\nHANDLERS:")
          for handler, desc in pairs(module_data.handlers) do
            table.insert(list,  "  " .. handler .. ":")
            table.insert(list, desc:wrap(79, "    "))
          end
        end
        return table.concat(list, "\n")
      end
    end
  end
end

