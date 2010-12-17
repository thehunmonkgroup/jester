function table.orderkeys(t)
  local list = {}
  for k, _ in pairs(t) do
    table.insert(list, k)
  end
  table.sort(list)
  return list
end

function table.ordervalues(t)
  local list = {}
  for _, v in pairs(t) do
    table.insert(list, v)
  end
  table.sort(list)
  return list
end

