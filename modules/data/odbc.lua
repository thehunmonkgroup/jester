local core = require "jester.core"

local _M = {}

local escape

--[[
  Escapes special characters for the MySQL database.
]]
local function mysql_escape(string)
  -- Single quote, double quote, backspace.
  string = string.gsub(string, "(['\"\\])", function(x) return "\\" .. x end)
  -- Null byte.
  string = string.gsub(string, "%z", "\\0")
  return string
end

--[[
  Escapes special characters for the Postgres database.
]]
local function pgsql_escape(string)
  -- Single quote.
  string = string.gsub(string, "'", "''")
  -- Null byte.
  string = string.gsub(string, "%z", "")
  return string
end

--[[
  Escapes special characters for the SQLite database.
]]
local function sqlite_escape(string)
  -- Single quote.
  string = string.gsub(string, "'", "''")
  -- Null byte.
  string = string.gsub(string, "%z", "")
  return string
end

--[[
  Sets the escape function based on the database type.
]]
local function set_escape(db_type)
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
  Connect to a database.
]]
local function connect(action)
  local dbh
  local conf = action.config
  -- Check for valid database configuration.
  if conf and conf.database_type and conf.database and conf.table then
    -- Based on the database type, set up the escape sequence for
    -- string input.
    set_escape(conf.database_type)
    dbh = assert(freeswitch.Dbh("odbc://" .. conf.database))
    return dbh, conf
  else
    error("Database connection misconfigured")
  end
end

--[[
  Figure out the field type based on how the field is formatted -- fields
  prefixed with double underscores are treated as integers, and have the
  underscores stripped prior to building the query.

  Both the properly formatted field and the field type are returned.
]]
local function field_type(field)
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
local function build_field_value(k, v)
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
local function build_expressions(f)
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
local function build_load_fields(f)
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
local function build_insert(filters, fields)
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
local function build_where(f)
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
local function build_update_fields(f)
  local fields = build_expressions(f)
  return table.concat(fields, ", ")
end

--[[
  Build ORDER BY statement.
]]
local function build_sort(sort, sort_order)
  if sort_order == "desc" or sort_order == "DESC" then
    sort_order = " DESC"
  else
    sort_order = ""
  end
  return " ORDER BY " .. sort .. sort_order
end

--[[
  Load data from a database into storage.
]]
function _M.load_data(action)
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
    core.log.debug("Executing query: %s", sql)
    local count, suffix = 0, ""
    -- Clean out storage area before loading in new data.
    core.clear_storage(area)
    -- Loop through the returned rows.
    assert(dbh:query(sql, function(row)
      count = count + 1
      for col, val in pairs(row) do
        -- Multi-row results get a row suffix.
        if multiple then
          suffix = "_" .. count
        end
        core.set_storage(area, col .. suffix, val)
      end
    end))
    dbh:release()
    -- Multi-row results get a special count key.
    if multiple then
      core.log.debug("Query rows returned: %d", count)
      core.set_storage(area, "__count", tonumber(count))
    end
  end
end

--[[
  Load data row counts from a database into storage.
]]
function _M.load_data_count(action)
  local count_field = action.count_field
  local filters = action.filters or {}
  local area = action.storage_area or "data"
  local key = action.storage_key or "count"
  if count_field then
    local dbh, conf = connect(action)
    -- Build the query.
    local sql = "SELECT COUNT(" .. count_field .. ") AS count FROM " .. conf.table .. build_where(filters)
    core.log.debug("Executing query: %s", sql)
    local count
    -- Loop through the returned rows.
    assert(dbh:query(sql, function(row) count = tonumber(row.count) end))
    dbh:release()
    core.set_storage(area, key, count)
  end
end

--[[
  Update data in a database.
]]
function _M.update_data(action)
  local fields = action.fields
  local filters = action.filters or {}
  local update_type = action.update_type
  if fields then
    local dbh, conf = connect(action)
    local where = build_where(filters)
    local count = 0
    local message
    -- No type specified, or update forced, so try an update first.
    if not update_type or update_type == "update" then
      sql = "UPDATE " .. conf.table .. " SET " .. build_update_fields(fields) .. where
      core.log.debug("Executing query: %s", sql)
      assert(dbh:query(sql))
      message = "updated"
      count = dbh:affected_rows()
    end
    -- Insert forced, or no rows updated and update is not forced, so insert.
    if update_type == "insert" or (count == 0 and update_type ~= "update") then
      local insert_fields, values = build_insert(filters, fields)
      sql = "INSERT INTO " .. conf.table .. " (" .. insert_fields .. ") VALUES (" .. values .. ")"
      core.log.debug("Executing query: %s", sql)
      assert(dbh:query(sql))
      message = "inserted"
      count = 1
    end
    dbh:release()
    core.log.debug("Rows %s: %d", message, count)
  end
end

--[[
  Delete data from a database.
]]
function _M.delete_data(action)
  local filters = action.filters or {}
  local dbh, conf = connect(action)
  local sql = "DELETE FROM " .. conf.table .. build_where(filters)
  core.log.debug("Executing query: %s", sql)
  assert(dbh:query(sql))
  dbh:release()
end

--[[
  Execute custom queries on a database, optionally returning data.
]]
function _M.query_data(action)
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
  core.log.debug("Executing query: %s", sql)
  if return_fields then
    local count = 0
    -- Clean out storage area before loading in new data.
    core.clear_storage(area)
    -- Loop through the returned rows.
    assert(dbh:query(sql, function(row)
      count = count + 1
      for col, val in pairs(row) do
        core.set_storage(area, col .. "_" .. count, val)
      end
    end))
    dbh:release()
    core.log.debug("Query rows returned: %d", count)
    core.set_storage(area, "__count", tonumber(count))
  else
    assert(dbh:query(sql))
  end
  dbh:release()
end

return _M
