local action = ...
jester.help.init_module_help()

local function action_help_detail(module_data, action_data)
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

  return table.concat(list, "\n"), true
end

if action then
  for _, module_data in pairs(jester.help_map) do
    for action_to_check, action_data in pairs(module_data.actions) do
      if action_to_check == action then
        return action_help_detail(module_data, action_data)
      end
    end
  end
else
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

