--[[
  Support functions for tables.
]]

local url = require("socket.url")

--[[
  Given an associative array table, returns a new table with an ordered
  list of the values of the passed table.
]]
function table.orderkeys(t)
  local list = {}
  for k, _ in pairs(t) do
    table.insert(list, k)
  end
  table.sort(list)
  return list
end

--[[
  Given an associative array table, returns a new table with an ordered
  list of the keys of the passed table.
]]
function table.ordervalues(t)
  local list = {}
  for _, v in pairs(t) do
    table.insert(list, v)
  end
  table.sort(list)
  return list
end

function table.stringify(params, sep, eq)
  if not sep then sep = '&' end
  if not eq then eq = '=' end
  if type(params) == "table" then
    local fields = {}
    for key,value in pairs(params) do
      local keyString = url.escape(tostring(key)) .. eq
      if type(value) == "table" then
        for _, v in ipairs(value) do
          table.insert(fields, keyString .. url.escape(tostring(v)))
        end
      else
        table.insert(fields, keyString .. url.escape(tostring(value)))
      end
    end
    return table.concat(fields, sep)
  end
  return ''
end
