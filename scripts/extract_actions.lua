local filename = "action_map.lua"

local output = [[
--- This module represents Jester actions as extracted from Jester using ldoc.
--
-- It is a simple map of all actions, their parameters, and what value type
-- the parameter accepts.
--
-- @module action_map
-- @author Chad Phillips
-- @copyright 2011-2015 Chad Phillips

return {
]]

return {
  filter = function (t)
    local data = {}
    for _, mod in ipairs(t) do
      for _, item in ipairs(mod.items) do
        if item.type == 'action' then
          local action = item.name
          output = output .. "  " .. action .. " = {\n"
          --[[
          print("------------")
          for k, v in pairs(item) do
           print(k, v)
          end
          print("------------")
          for k, v in pairs(item.modifiers.param.action) do
           print(k, v)
          end
          print("------------")
          ]]
          for _, param in ipairs(item.params) do
            if param ~= "handler" then
              output = output .. "    " .. param .. ' = "' .. item.modifiers.param[param].type .. '"' .. ",\n"
            end
          end
          output = output .. "  },\n"
        end
      end
    end
    output = output .. "}"
    local file, err = io.open(filename, "wb")
    if err then print(err) end
    file:write(output)
    file:close()
    print ("actions extracted to " .. filename);
  end
}
