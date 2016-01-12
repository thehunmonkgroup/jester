--- Handle outside data.
--
-- This module provides actions that deal with reading and writing of external
-- data into Jester.
--
-- @module data
-- @author Chad Phillips
-- @copyright 2011-2015 Chad Phillips

--- The ODBC handler (default).
--
--  The 'config' parameter for all actions using this handler is a table with
--  the parameters listed below.
--
-- Note that in order for this handler to work properly, you'll need to have
-- ODBC installed, the correct ODBC driver for your database type installed,
-- and an ODBC resource set up to access your database.  If you don't know
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
--   The type of database being accessed.  Valid values are 'mysql',
--   'pgsql', and 'sqlite'.
-- @param config.database
--   The name of the ODBC datasource to access.
-- @param config.table
--   The table in the database to operate on.


--- Delete outside data.
--
-- Allows deletion of data from outside sources (currently ODBC data sources
-- only).
--
-- @action data_delete
-- @param action
--   Required, value: data_delete
-- @param config
--   A table of information to pass which describes where to find the data.
--   Check handlers to see the fields for this table.
-- @param filters
--   (Optional) A table of filters to apply when loading the data.  This
--   restricts what is loaded to the filtered values.  Filters are cumulative
--   (AND logic).  The key is the name of the filter, and the value is the value
--   to filter on.  Filter values are interpreted as strings by default -- if a
--   filter value is a number, prefix the filter key with double underscores.
--   eg. <code>'filters = { context = "default", __mailbox = 1234 }</code>
--   **WARNING:** If you exclude this field, all rows will be deleted!


--- Load outside data into Jester storage.
--
-- Allows loading of data from outside sources.
--
-- Important note: core handlers for the data_load action clear all data from
-- the specified storage area before they load new data into it -- if you need
-- something preserved across mulitple loads, put it in a different storage
-- area!
--
-- @action data_load
-- @param action
--   Required, value: data_load
-- @param config
--   A table of information to pass which describes where to find the data.
--   Check handlers to see the fields for this table.
-- @param fields
--   A table of fields to load.  Include only the field names as values, no
--   keys.  Field types are interpreted as strings by default -- if a field type
--   is numeric, prefix the field name with double underscores, eg. 'fields = {
--   "__mailbox", "context", "password", "email" }
-- @param filters
--   (Optional) A table of filters to apply when loading the data.  This
--   restricts what is loaded to the filtered values.  Filters are cumulative
--   (AND logic).  The key is the name of the filter, and the value is the value
--   to filter on.  Filter values are interpreted as strings by default -- if a
--   filter value is a number, prefix the filter key with double underscores.
--   eg. 'filters = { context = "default", __mailbox = 1234 }  WARNING: if you
--   exclude this field, all rows will be loaded!
-- @param multiple
--   (Optional) Boolean indicating whether to load multiple sets of data.  True
--   loads all data that passes through the filters, false only loads the first
--   set of data.  Default is false.  Note that multiple results are suffixed
--   with the result set number before being put in the data storage area, eg.
--   if you loaded multiple result sets of a field named 'number', the first set
--   would be stored as 'number_1', the second as 'number_2' and so on...
--   Note that if this parameter is set, in addition to storing the data that is
--   loaded, a special key '__count' is added, which holds an integer of the
--   number of rows returned.
-- @param sort
--   (Optional) A field to sort the data by before loading.  This is only used
--   with the 'mulitple' parameter.  Eg. 'sort = "timestamp"'
-- @param sort_order
--   (Optional) The sorting order.  Only used with the 'sort' and 'multiple'
--   parameters.  Valid values are 'asc' and 'desc', the default is 'asc'.
-- @param storage_area
--   (Optional) The storage area to store the data in after loading.  Defaults
--   to 'data'.  Eg. Setting 'storage_area = "mailbox_settings"' would store the
--   data in the 'mailbox_settings' storage area.


--- Retrieves a count of outside data into Jester storage.
--
-- Allows loading of data counts from outside sources.  If you only need to know
-- the number of rows of data, this is more efficient than the data_load action.
--
-- The result is stored in the 'data' storage area.
--
-- @action data_load_count
-- @param action
--   Required, value: data_load_count
-- @param config
--   A table of information to pass which describes where to find the data.
--   Check handlers to see the fields for this table.
-- @param count_field
--   The field to use for counting.
-- @param filters
--   (Optional) A table of filters to apply when loading the data count.  This
--   restricts what results are counted to the filtered values.  Filters are
--   cumulative (AND logic).  The key is the name of the filter, and the value
--   is the value to filter on.  Filter values are interpreted as strings by
--   default -- if a filter value is a number, prefix the filter key with double
--   underscores.  eg. 'filters = { context = "default", __mailbox = 1234 }
--   WARNING: if you exclude this field, all rows will be counted!
-- @param storage_key
--   (Optional) The key to store the count under in the 'data' storage area.
--   Default is 'count'.


--- Executes a custom query against a data source.
--
-- Allows running custom queries on outside data sources.  Row data can be
-- optionally loaded into a storage area.
--
-- This action should only be used if regular data actions will not suffice --
-- its use is discouraged as it may not be portable across handlers/databases.
-- If table joins are needed, it is suggested you handle that at the database
-- layer (eg, by creating a view in MySQL).
--
-- Important note: core handlers for the data_query action clear all data from
-- the specified storage area before they load new data into it -- if you need
-- something preserved across mulitple loads, put it in a different storage
-- area!
--
-- @action data_query
-- @param action
--   Required, value: data_query
-- @param config
--   A table of information to pass which describes where to find the data.
--   Check handlers to see the fields for this table.  Note that for this
--   action, any table information is provided by the query parameter.
-- @param query
--   The custom query to execute.  Tokens are replaced prior to running the
--   query.
-- @param return_fields
--   (Optional) If set to true, field data from the query will be returned to
--   the specified storage area, and the number of returned rows will be placed
--   in the '__count' key.  Default is false.
-- @param storage_area
--   (Optional) The storage area to store the data in after loading.  Defaults
--   to 'data'.  Eg. Setting 'storage_area = "mailbox_settings"' would store the
--   data in the 'mailbox_settings' storage area.
-- @param tokens
--   (Optional) A table of token replacements to apply, key = token name, value
--   = token replacement, eg. 'tokens = {foo = "bar"}' would replace the token
--   ':foo' with 'bar'.  Note that for security reasons, all token values will
--   be run through an escaping function prior to token replacement if
--   appropriate/available.


--- Update outside data.
--
-- Allows updating/insertion of data to outside sources (currently ODBC data
-- sources only).
--
-- @action data_update
-- @param action
--   Required, value: data_update
-- @param config
--   A table of information to pass which describes where to find the data.
--   Check handlers to see the fields for this table.
-- @param fields
--   A table of fields to load.  Keys are the field names to update, values are
--   the values to update to.  Field types are interpreted as strings by default
--   -- if a field type is numeric, prefix the field name with double
--   underscores, eg. 'fields = { __mailbox = 1234, context = "default"}'.
-- @param filters
--   (Optional) A table of filters to apply when loading the data.  This
--   restricts what is loaded to the filtered values.  Filters are cumulative
--   (AND logic).  The key is the name of the filter, and the value is the value
--   to filter on.  Filter values are interpreted as strings by default -- if a
--   filter value is a number, prefix the filter key with double underscores.
--   eg. 'filters = { context = "default", __mailbox = 1234 }  WARNING: if you
--   exclude this field, all rows will be updated!
-- @param update_type
--   (Optional) If this parameter is not provided, the default behavior is to
--   first attempt an update, and if no rows were updated, then perform an
--   insert.  To force either an update or insert, set this to 'update' or
--   'insert' respectively.

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
