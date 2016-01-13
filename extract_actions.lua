return {
   filter = function (t)
      for _, mod in ipairs(t) do
         for _, item in ipairs(mod.items) do
            if item.type == 'action' then
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
               print(item.name)
               for _, name in ipairs(item.params) do
                 if name ~= "handler" then
                   if item.modifiers.param and item.modifiers.param[name] and item.modifiers.param[name].type then
                     name = name .. " (" .. item.modifiers.param[name].type .. ")"
                   end
                   print("  " .. name)
                 end
               end
            end
         end
      end
   end
}
