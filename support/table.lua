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

