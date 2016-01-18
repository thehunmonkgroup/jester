local json = require "cjson"
return {
  filter = function (t)
    local data = {}
    for _, mod in ipairs(t) do
      for _, item in ipairs(mod.items) do
        if item.type == 'action' then
          local action = item.name
          data[action] = {}
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
              data[action][param] = item.modifiers.param[param].type
            end
          end
        end
      end
    end
    local encoded = json.encode(data)
    print(encoded)
  end
}
