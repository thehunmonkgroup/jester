module(..., package.seeall)

local escape

--[[
  Connect to a database.
]]
function connect(action)
  local dbh
  local conf = action.config
  -- Check for valid database configuration.
  if conf and conf.database_type and conf.database and conf.table then
    -- Based on the database type, set up the escape sequence for
    -- string input.
    set_escape(conf.database_type)
    dbh = assert(freeswitch.Dbh(conf.database))
    return dbh, conf
  else
    error("Database connection misconfigured")
  end
end

--[[
  Load data from a database into storage.
]]
function load_data(action)
  local fields = action.fields
  local filters = action.filters or {}
  local multiple = action.multiple
  local sort = action.sort
  local sort_order = action.sort_order
  local area = action.storage_area or "data"
  if fields then
    local dbh, conf = connect(action)
    local limit = multiple and "" or " LIMIT 1"
    -- Optional sort.
    local load_sort = sort and build_sort(sort, sort_order) or ""
    -- Build the query.
    local sql = "SELECT " .. build_load_fields(fields) .. " FROM " .. conf.table .. build_where(filters) .. load_sort .. limit
    jester.debug_log("Executing query: %s", sql)
    local count, suffix = 0, ""
    -- Clean out storage area before loading in new data.
    jester.clear_storage(area)
    -- Loop through the returned rows.
    assert(dbh:query(sql, function(row)
      count = count + 1
      for col, val in pairs(row) do
        -- Multi-row results get a row suffix.
        if multiple then
          suffix = "_" .. count
        end
        jester.set_storage(area, col .. suffix, val)
      end
    end))
    dbh:release()
    -- Multi-row results get a special count key.
    if multiple then
      jester.debug_log("Query rows returned: %d", count)
      jester.set_storage(area, "__count", tonumber(count))
    end
  end
end

--[[
  Load data row counts from a database into storage.
]]
function load_data_count(action)
  local count_field = action.count_field
  local filters = action.filters or {}
  local key = action.storage_key or "count"
  if count_field then
    local dbh, conf = connect(action)
    -- Build the query.
    local sql = "SELECT COUNT(" .. count_field .. ") AS count FROM " .. conf.table .. build_where(filters)
    jester.debug_log("Executing query: %s", sql)
    local count
    -- Loop through the returned rows.
    assert(dbh:query(sql, function(row) count = tonumber(row.count) end))
    dbh:release()
    jester.set_storage("data", key, count)
  end
end

--[[
  Update data in a database.
]]
function update_data(action)
  local fields = action.fields
  local filters = action.filters or {}
  local update_type = action.update_type
  if fields then
    local dbh, conf = connect(action)
    local where = build_where(filters)
    local count = 1
    -- Check how many rows will be updated first, unless it's an insert.
    if update_type ~= "insert" then
      local sql = "SELECT COUNT(*) AS count FROM " .. conf.table .. where
      assert(dbh:query(sql, function(row) count = tonumber(row.count) end))
    end
    -- Insert forced, or no rows would be updated and update is not forced,
    -- so insert.
    if update_type == "insert" or (count == 0 and update_type ~= "update") then
      local insert_fields, values = build_insert(filters, fields)
      sql = "INSERT INTO " .. conf.table .. " (" .. insert_fields .. ") VALUES (" .. values .. ")"
      count = 1
    -- Rows would be updated, and update is either not specified or it's
    -- forced, so update.
    elseif count > 0 and (not update_type or update_type == "update") then
      sql = "UPDATE " .. conf.table .. " SET " .. build_update_fields(fields) .. where
    end
    jester.debug_log("Executing query: %s", sql)
    assert(dbh:query(sql))
    dbh:release()
    jester.debug_log("Rows updated: %d", count)
  end
end

--[[
  Delete data from a database.
]]
function delete_data(action)
  local filters = action.filters or {}
  local dbh, conf = connect(action)
  local sql = "DELETE FROM " .. conf.table .. build_where(filters)
  jester.debug_log("Executing query: %s", sql)
  assert(dbh:query(sql))
  dbh:release()
end

--[[
  Execute custom queries on a database, optionally returning data.
]]
function query_data(action)
  local query = action.query
  local return_fields = action.return_fields
  local area = action.storage_area or "data"
  local tokens = action.tokens
  local dbh, conf = connect(action)
  local sql

  -- Token replacements.
  if tokens then
    require "jester.support.string"
    for k,v in pairs(tokens) do
      tokens[k] = escape(v)
    end
    sql = string.token_replace(query, tokens)
  else
    sql = query
  end
  jester.debug_log("Executing query: %s", sql)
  if return_fields then
    local count = 0
    -- Clean out storage area before loading in new data.
    jester.clear_storage(area)
    -- Loop through the returned rows.
    assert(dbh:query(sql, function(row)
      count = count + 1
      for col, val in pairs(row) do
        jester.set_storage(area, col .. "_" .. count, val)
      end
    end))
    dbh:release()
    jester.debug_log("Query rows returned: %d", count)
    jester.set_storage(area, "__count", tonumber(count))
  else
    assert(dbh:query(sql))
  end
  dbh:release()
end

--[[
  Figure out the field type based on how the field is formatted -- fields
  prefixed with double underscores are treated as integers, and have the
  underscores stripped prior to building the query.

  Both the properly formatted field and the field type are returned.
]]
function field_type(field)
  if string.sub(field, 1, 2) == "__" then
    return string.sub(field, 3), "int"
  else
    return field, "string"
  end
end

--[[
  Build field values, properly escaping and quoting as necessary depending on
  the field type.
]]
function build_field_value(k, v)
  local value
  local field, f_type = field_type(k)
  if f_type == "int" then
    value = string.format("%d", v)
  else
    value = "'" .. escape(v) .. "'"
  end
  return field, value
end


--[[
  Builds key = value expressions, properly formatting and escaping depending
  on the field type.
]]
function build_expressions(f)
  local expressions = {}
  local field, value
  for k, v in pairs(f) do
    field, value = build_field_value(k, v)
    expressions[#expressions+1] = field .. " = " .. value
  end
  return expressions
end

--[[
  Builds the comma separated list of fields used in SELECT queries, properly
  formatting and escaping depending on field type.
]]
function build_load_fields(f)
  local fields = {}
  for k, v in ipairs(f) do
    fields[k] = field_type(v)
  end
  return table.concat(fields, ", ")
end

--[[
  Builds the columns and values used in INSERT statements, properly formatting
  and escaping depending on field type.
]]
function build_insert(filters, fields)
  local columns, values = {}, {}
  local field, value
  for k, v in pairs(filters) do
    field, value = build_field_value(k, v)
    columns[#columns+1] = field
    values[#values+1] = value
  end
  for k, v in pairs(fields) do
    field, value = build_field_value(k, v)
    columns[#columns+1] = field
    values[#values+1] = value
  end
  return table.concat(columns, ", "), table.concat(values, ", ")
end

--[[
  Build WHERE clauses.
]]
function build_where(f)
  local filters = build_expressions(f)
  if #filters > 0 then
    return " WHERE " .. table.concat(filters, " AND ")
  else
    return ""
  end
end

--[[
  Builds the columns and values used in INSERT statements, properly formatting
  and escaping depending on field type.
]]
function build_update_fields(f)
  local fields = build_expressions(f)
  return table.concat(fields, ", ")
end

--[[
  Build ORDER BY statement.
]]
function build_sort(sort, sort_order)
  if sort_order == "desc" or sort_order == "DESC" then
    sort_order = " DESC"
  else
    sort_order = ""
  end
  return " ORDER BY " .. sort .. sort_order
end

--[[
  Sets the escape function based on the database type.
]]
function set_escape(db_type)
  if db_type == "mysql" then
    escape = mysql_escape
  elseif db_type == "pgsql" then
    escape = pgsql_escape
  elseif db_type == "sqlite" then
    escape = sqlite_escape
  else
    error(string.format([[Unsupported database type %s]], db_type))
  end
end

--[[
  Escapes special characters for the MySQL database.
]]
function mysql_escape(string)
  -- Single quote, double quote, backspace.
  string = string.gsub(string, "(['\"\\])", function(x) return "\\" .. x end)
  -- Null byte.
  string = string.gsub(string, "%z", "\\0")
  return string
end

--[[
  Escapes special characters for the Postgres database.
]]
function pgsql_escape(string)
  -- Single quote.
  string = string.gsub(string, "'", "''")
  -- Null byte.
  string = string.gsub(string, "%z", "")
  return string
end

--[[
  Escapes special characters for the SQLite database.
]]
function sqlite_escape(string)
  -- Single quote.
  string = string.gsub(string, "'", "''")
  -- Null byte.
  string = string.gsub(string, "%z", "")
  return string
end

