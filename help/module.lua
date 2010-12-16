local module_name = ...
jester.help.init_module_help()

local function module_help_detail(module_data, action_data)
  local list = {}
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

  return table.concat(list, "\n"), true
end

if module_name then
  local description, actions
  local action_list = {}
  for name_to_check, data in pairs(jester.help_map) do
    if name_to_check == module_name then
      description = data.description_long:wrap(79) or data.description_short:wrap(79) or ""
      break
    end
  end
  if description then
    return module_help_detail(jester.help_map[module_name], jester.help_map[module_name].actions)
  end
else
  local module_list = {}
  for _, name in ipairs(jester.conf.modules) do
    table.insert(module_list, name .. ":")
    table.insert(module_list, jester.help_map[name].description_short:wrap(79, "  ") or "")
  end
  return string.format("Run 'help module [name]' to get more help on a specific module.\n\nCurrently installed modules:\n\n%s", table.concat(module_list, "\n"))
end

