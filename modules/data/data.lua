--- Handle external data.
--
-- This module provides actions that deal with reading and writing of external
-- data in Jester.
--
-- @module data
-- @author Chad Phillips
-- @copyright 2011-2015 Chad Phillips

--- The ODBC handler (default).
--
-- The 'config' parameter for all actions using this handler is a table with
-- the parameters listed below.
--
-- Note that in order for this handler to work properly, you'll need to have
-- ODBC installed, the correct ODBC driver for your database type installed,
-- and an ODBC resource set up to access your database. If you don't know
-- how, there's a nice tutorial [here](http://bit.ly/b6d0Wm) (for CentOS).
--
-- For now you'll need to include your username/password in the odbc.ini
-- file, future versions will probably support passing that at connect time
-- also.
--
-- @handler odbc
-- @param config
--   Table of connection parameters
-- @param config.database_type
--   The type of database being accessed. Valid values are 'mysql',
--   'pgsql', and 'sqlite'
-- @param config.database
--   The name of the ODBC datasource to access
-- @param config.table
--   The table in the database to operate on
-- @usage
--   {
--     action = "data_load",
--     config = {
--       database_type = "sqlite",
--       database = "/tmp/test.db",
--       table = "test",
--     },
--     -- other params...
--   }


--- Delete data.
--
-- Allows deletion of data from external sources.
--
-- @action data_delete
-- @param action
--   data_delete
-- @param config
--   A table of information to pass which describes where to find the data.
--   Check [handlers](#Handlers) to see the fields for this table.
-- @param filters
--   (Optional) A table of filters to apply when loading the data. This
--   restricts what is loaded to the filtered values. Filters are cumulative
--   (AND logic). The key is the name of the filter, and the value is the value
--   to filter on. Filter values are interpreted as strings by default -- if a
--   filter value is a number, prefix the filter key with double underscores.
--   **WARNING:** If you exclude this field, all rows will be deleted!
-- @param handler
--   The handler to use, see [handlers](#Handlers). If not specified, defaults
--   to the default handler for the module.
-- @usage
--   {
--     action = "data_delete",
--     config = profile.db_config,
--     filters = {
--       context = "default",
--       __mailbox = 1234,
--     },
--   }


--- Load data into Jester storage.
--
-- Allows loading of data from external sources.
--
-- **IMPORTANT NOTE:** core handlers for the data_load action clear all data
-- from the specified storage area before they load new data into it -- if you
-- need something preserved across mulitple loads, put it in a different
-- storage area!
--
-- @action data_load
-- @param action
--   data_load
-- @param config
--   A table of information to pass which describes where to find the data.
--   Check [handlers](#Handlers) to see the fields for this table.
-- @param fields
--   A table of fields to load. Include only the field names as values, no
--   keys. Field types are interpreted as strings by default -- if a field type
--   is numeric, prefix the field name with double underscores.
-- @param filters
--   (Optional) A table of filters to apply when loading the data. This
--   restricts what is loaded to the filtered values. Filters are cumulative
--   (AND logic). The key is the name of the filter, and the value is the value
--   to filter on. Filter values are interpreted as strings by default -- if a
--   filter value is a number, prefix the filter key with double underscores.
--   **WARNING:** if you exclude this field, all rows will be loaded!
-- @param multiple
--   (Optional) Boolean indicating whether to load multiple sets of data. True
--   loads all data that passes through the filters, false only loads the first
--   set of data. Default is false. Note that multiple results are suffixed
--   with the result set number before being put in the data storage area, eg.
--   if you loaded multiple result sets of a field named <code>number</code>,
--   the first set would be stored as <code>number_1</code>, the second as
--   <code>number_2</code> and so on... Note that if this parameter is set, in
--   addition to storing the data that is loaded, a special key
--   <code>__count</code> is added, which holds an integer of the number of
--   rows returned.
-- @param sort
--   (Optional) A field to sort the data by before loading. This is only used
--   with the 'mulitple' parameter.
-- @param sort_order
--   (Optional) The sorting order. Only used with the 'sort' and 'multiple'
--   parameters. Valid values are 'asc' and 'desc', the default is 'asc'.
-- @param storage_area
--   (Optional) The storage area to store the data in after loading. Defaults
--   to 'data'.
-- @param handler
--   The handler to use, see [handlers](#Handlers). If not specified, defaults
--   to the default handler for the module.
-- @usage
--   {
--     action = "data_load",
--     config = profile.db_config,
--     fields = {
--       "__mailbox",
--       "context",
--       "password",
--       "email",
--     },
--     filters = {
--       context = "default",
--       __mailbox = 1234,
--     },
--     multiple = true,
--     sort = "mailbox",
--     sort_order = "asc",
--     storage_area = "mailbox_settings",
--   }


--- Retrieves a count of data into Jester storage.
--
-- Allows loading of data counts from external sources. If you only need to know
-- the number of rows of data, this is more efficient than the data_load action.
--
-- @action data_load_count
-- @param action
--   data\_load\_count
-- @param config
--   A table of information to pass which describes where to find the data.
--   Check [handlers](#Handlers) to see the fields for this table.
-- @param count_field
--   The field to use for counting.
-- @param filters
--   (Optional) A table of filters to apply when loading the data count. This
--   restricts what results are counted to the filtered values. Filters are
--   cumulative (AND logic). The key is the name of the filter, and the value
--   is the value to filter on. Filter values are interpreted as strings by
--   default -- if a filter value is a number, prefix the filter key with double
--   underscores.
--   **WARNING:** if you exclude this field, all rows will be counted!
-- @param storage_area
--   (Optional) The storage area to store the data in after loading. Defaults
--   to 'data'.
-- @param storage_key
--   (Optional) The key to store the count under in the 'data' storage area.
--   Default is 'count'.
-- @param handler
--   The handler to use, see [handlers](#Handlers). If not specified, defaults
--   to the default handler for the module.
-- @usage
--   {
--     action = "data_load_count",
--     config = profile.db_config,
--     count_field = "messages",
--     filters = {
--       context = "default",
--       __mailbox = 1234,
--     },
--     storage_area = "mailbox",
--     storage_key = "number_of_messages",
--   }

--- Executes a custom query against a data source.
--
-- Allows running custom queries on external data sources. Row data can be
-- optionally loaded into a storage area.
--
-- This action should only be used if regular data actions will not suffice --
-- its use is discouraged as it may not be portable across handlers/databases.
-- If table joins are needed, it is suggested you handle that at the database
-- layer (eg, by creating a view in MySQL).
--
-- **Important note:** core handlers for the data_query action clear all data
-- from the specified storage area before they load new data into it -- if you
-- need something preserved across mulitple loads, put it in a different
-- storage area!
--
-- @action data_query
-- @param action
--   data_query
-- @param config
--   A table of information to pass which describes where to find the data.
--   Check [handlers](#Handlers) to see the fields for this table. Note that
--   for this action, any table information is provided by the query parameter.
-- @param query
--   The custom query to execute. Tokens are replaced prior to running the
--   query.
-- @param return_fields
--   (Optional) If set to true, field data from the query will be returned to
--   the specified storage area, and the number of returned rows will be placed
--   in the '__count' key. Default is false.
-- @param storage_area
--   (Optional) The storage area to store the data in after loading. Defaults
--   to 'data'.
-- @param tokens
--   (Optional) A table of token replacements to apply to the query,
--   key = token name, value = token replacement. Tokens are prefixed with a
--   colon. Note that for security reasons, all token values will be run
--   through an escaping function prior to token replacement if
--   appropriate/available.
-- @param handler
--   The handler to use, see [handlers](#Handlers). If not specified, defaults
--   to the default handler for the module.
-- @usage
--   {
--     action = "data_query",
--     config = profile.db_config,
--     query = "SELECT mailbox, SUM(messages) AS count FROM messages WHERE context = ':context' GROUP BY mailbox",
--     return_fields = true,
--     storage_area = "message_counts",
--     tokens = {
--       context = "default",
--     },
--   }


--- Update data.
--
-- Allows updating/insertion of data to external sources.
--
-- @action data_update
-- @param action
--   data_update
-- @param config
--   A table of information to pass which describes where to find the data.
--   Check [handlers](#Handlers) to see the fields for this table.
-- @param fields
--   A table of fields to update. Keys are the field names to update, values are
--   the values to update to. Field types are interpreted as strings by default
--   -- if a field type is numeric, prefix the field name with double
--   underscores.
-- @param filters
--   (Optional) A table of filters to apply when loading the data. This
--   restricts what is loaded to the filtered values. Filters are cumulative
--   (AND logic). The key is the name of the filter, and the value is the value
--   to filter on. Filter values are interpreted as strings by default -- if a
--   filter value is a number, prefix the filter key with double underscores.
--   **WARNING:** if you exclude this field, all rows will be updated!
-- @param update_type
--   (Optional) If this parameter is not provided, the default behavior is to
--   first attempt an update, and if no rows were updated, then perform an
--   insert. To force either an update or insert, set this to 'update' or
--   'insert' respectively.
-- @param handler
--   The handler to use, see [handlers](#Handlers). If not specified, defaults
--   to the default handler for the module.
-- @usage
--   {
--     action = "data_update",
--     config = profile.db_config,
--     fields = {
--       __max_messages = 100,
--       password = "supersecret",
--     },
--     filters = {
--       context = "default",
--       __mailbox = 1234,
--     },
--     update_type = "update",
--   }

local core = require "jester.core"

local _M = {}

local function load_odbc()
  local odbc = require("jester.modules.data.odbc")
  return odbc
end

--[[
  ODBC action handlers.
]]
function _M.load_data_odbc(action)
  local odbc = load_odbc()
  odbc.load_data(action)
end

function _M.load_data_count_odbc(action)
  local odbc = load_odbc()
  odbc.load_data_count(action)
end

function _M.update_data_odbc(action)
  local odbc = load_odbc()
  odbc.update_data(action)
end

function _M.delete_data_odbc(action)
  local odbc = load_odbc()
  odbc.delete_data(action)
end

function _M.query_data_odbc(action)
  local odbc = load_odbc()
  odbc.query_data(action)
end

return _M
