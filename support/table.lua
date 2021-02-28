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

--[[
  Given an associative array table, returns a properly escaped query string.
]]
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

--[[
  Clone tables, internal function.
]]
local function table_clone_internal(t, copies)
  if type(t) ~= "table" then return t end
  copies = copies or {}
  if copies[t] then return copies[t] end
  local copy = {}
  copies[t] = copy
  for k, v in pairs(t) do
    copy[table_clone_internal(k, copies)] = table_clone_internal(v, copies)
  end
  setmetatable(copy, table_clone_internal(getmetatable(t), copies))
  return copy
end

--[[
  Clone tables.
]]
function table.clone(t)
  -- We need to implement this with a helper function to make sure that
  -- user won't call this function with a second parameter as it can cause
  -- unexpected troubles
  return table_clone_internal(t)
end

--[[
  Clone tables.
]]
function table.merge(...)
  local tables_to_merge = {...}
  local recurse = true
  if type(tables_to_merge[#tables_to_merge]) == "boolean" then
    recurse = tables_to_merge[#tables_to_merge]
    table.remove(tables_to_merge, #tables_to_merge)
  end
  assert(#tables_to_merge > 1, "There should be at least two tables to merge them")
  for k, t in ipairs(tables_to_merge) do
    assert(type(t) == "table", string.format("Expected a table as function parameter %d", k))
  end
  local result = table.clone(tables_to_merge[1])
  for i = 2, #tables_to_merge do
    local from = tables_to_merge[i]
    for k, v in pairs(from) do
      if recurse and type(v) == "table" then
        result[k] = result[k] or {}
        assert(type(result[k]) == "table", string.format("Expected a table: '%s'", k))
        result[k] = table.merge(result[k], v)
      else
        result[k] = v
      end
    end
  end
  return result
end
