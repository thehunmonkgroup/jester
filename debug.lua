--[[
  Dumps values to console, with recursive option for tables.
]]
function debug_dump(var, recursive, prefix)
  local key, value
  prefix = prefix or ""
  -- Make sure we still want to dump.
  if not jester.is_freeswitch or jester.ready() then
    if type(var) == "table" then
      for k, v in pairs(var) do
        if type(v) == "string" or type(v) == "number" or type(v) == "boolean" then
          value = tostring(v)
        else
          value = type(v)
        end
        if type(k) == "string" or type(k) == "number" or type(k) == "boolean" then
          key = tostring(k)
        else
          key = type(k)
        end
        -- Exclude possibly infinitely recursive keys.
        if k ~= "_M" and k ~= "__index" then
          jester.log(string.format([[%s%s, value: %s]], prefix, key, value), "JESTER VAR DUMP")
          -- Tables get optional recursive treatment.
          if recursive and type(v) == "table" then
            debug_dump(v, recursive, prefix .. "[" .. key .. "]")
          end
        end
      end
    elseif type(var) == "string" or type(var) == "number" or type(var) == "boolean" then
      jester.log(string.format([[value: %s]], tostring(var)), "JESTER VAR DUMP")
    else
      jester.log(string.format([[value: %s]], type(var)), "JESTER VAR DUMP")
    end
  end
end
