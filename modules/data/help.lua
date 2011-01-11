jester.help_map.data = {}
jester.help_map.data.description_short = [[Handle outside data.]]
jester.help_map.data.description_long = [[This module provides actions that deal with reading and writing of external data into Jester.]]
jester.help_map.data.handlers = {}
jester.help_map.data.handlers.odbc = [[The default handler for the data module.  The 'config' parameter for all actions using it under this handler is a table with the following key/value pairs:

  database_type:
    The type of database being accessed.  Valid values are 'mysql', 'pgsql', and 'sqlite'.
  database:
    The name of the ODBC datasource to access.
  table:
    The table in the database to operate on.

Note that in order for this handler to work properly, you'll need to have ODBC installed, the correct ODBC driver for your database type installed, and an ODBC resource set up to access your database.  If you don't know how, there's a nice tutorial here (for CentOS): http://bit.ly/b6d0Wm

For now you'll need to include your username/password in the odbc.ini file, future versions will probably support passing that at connect time also.]]

jester.help_map.data.actions = {}

jester.help_map.data.actions.data_load = {}
jester.help_map.data.actions.data_load.description_short = [[Load outside data into Jester storage.]]
jester.help_map.data.actions.data_load.description_long = [[Allows loading of data from outside sources.

Important note: core handlers for the data_load action clear all data from the specified storage area before they load new data into it -- if you need something preserved across mulitple loads, put it in a different storage area!]]
jester.help_map.data.actions.data_load.params = {
  config = [[A table of information to pass which describes where to find the data.  Check handlers to see the fields for this table.]],
  filters = [[(Optional) A table of filters to apply when loading the data.  This restricts what is loaded to the filtered values.  Filters are cumulative (AND logic).  The key is the name of the filter, and the value is the value to filter on.  Filter values are interpreted as strings by default -- if a filter value is a number, prefix the filter key with double underscores.  eg. 'filters = { context = "default", __mailbox = 1234 }  WARNING: if you exclude this field, all rows will be loaded!]],
  fields = [[A table of fields to load.  Include only the field names as values, no keys.  Field types are interpreted as strings by default -- if a field type is numeric, prefix the field name with double underscores, eg. 'fields = { "__mailbox", "context", "password", "email" }]],
  multiple = [[(Optional) Boolean indicating whether to load multiple sets of data.  True loads all data that passes through the filters, false only loads the first set of data.  Default is false.  Note that multiple results are suffixed with the result set number before being put in the data storage area, eg. if you loaded multiple result sets of a field named 'number', the first set would be stored as 'number_1', the second as 'number_2' and so on...
Note that if this parameter is set, in addition to storing the data that is loaded, a special key '__count' is added, which holds an integer of the number of rows returned.]],
  sort = [[(Optional) A field to sort the data by before loading.  This is only used with the 'mulitple' parameter.  Eg. 'sort = "timestamp"']],
  sort_order = [[(Optional) The sorting order.  Only used with the 'sort' and 'multiple' parameters.  Valid values are 'asc' and 'desc', the default is 'asc'.]],
  storage_area = [[(Optional) The storage area to store the data in after loading.  Defaults to 'data'.  Eg. Setting 'storage_area = "mailbox_settings"' would store the data in the 'mailbox_settings' storage area.]],
}

jester.help_map.data.actions.data_load_count = {}
jester.help_map.data.actions.data_load_count.description_short = [[Retrieves a count of outside data into Jester storage.]]
jester.help_map.data.actions.data_load_count.description_long = [[Allows loading of data counts from outside sources.  If you only need to know the number of rows of data, this is more efficient than the data_load action.

The result is stored in the 'data' storage area.]]
jester.help_map.data.actions.data_load_count.params = {
  count_field = [[The field to use for counting.]],
  config = [[A table of information to pass which describes where to find the data.  Check handlers to see the fields for this table.]],
  filters = [[(Optional) A table of filters to apply when loading the data count.  This restricts what results are counted to the filtered values.  Filters are cumulative (AND logic).  The key is the name of the filter, and the value is the value to filter on.  Filter values are interpreted as strings by default -- if a filter value is a number, prefix the filter key with double underscores.  eg. 'filters = { context = "default", __mailbox = 1234 }  WARNING: if you exclude this field, all rows will be counted!]],
  storage_key = [[(Optional) The key to store the count under in the 'data' storage area.  Default is 'count'.]],
}


jester.help_map.data.actions.data_update = {}
jester.help_map.data.actions.data_update.description_short = [[Update outside data.]]
jester.help_map.data.actions.data_update.description_long = [[Allows updating/insertion of data to outside sources (currently ODBC data sources only).]]
jester.help_map.data.actions.data_update.params = {
  config = [[A table of information to pass which describes where to find the data.  Check handlers to see the fields for this table.]],
  filters = [[(Optional) A table of filters to apply when loading the data.  This restricts what is loaded to the filtered values.  Filters are cumulative (AND logic).  The key is the name of the filter, and the value is the value to filter on.  Filter values are interpreted as strings by default -- if a filter value is a number, prefix the filter key with double underscores.  eg. 'filters = { context = "default", __mailbox = 1234 }  WARNING: if you exclude this field, all rows will be updated!]],
  fields = [[A table of fields to load.  Keys are the field names to update, values are the values to update to.  Field types are interpreted as strings by default -- if a field type is numeric, prefix the field name with double underscores, eg. 'fields = { __mailbox = 1234, context = "default"}'.]],
  update_type = [[(Optional) If this parameter is not provided, the default behavior is to first attempt an update, and if no rows were updated, then perform an insert.  To force either an update or insert, set this to 'update' or 'insert' respectively.]],
}


jester.help_map.data.actions.data_delete = {}
jester.help_map.data.actions.data_delete.description_short = [[Delete outside data.]]
jester.help_map.data.actions.data_delete.description_long = [[Allows deletion of data from outside sources (currently ODBC data sources only).]]
jester.help_map.data.actions.data_delete.params = {
  config = [[A table of information to pass which describes where to find the data.  Check handlers to see the fields for this table.]],
  filters = [[(Optional) A table of filters to apply when loading the data.  This restricts what is loaded to the filtered values.  Filters are cumulative (AND logic).  The key is the name of the filter, and the value is the value to filter on.  Filter values are interpreted as strings by default -- if a filter value is a number, prefix the filter key with double underscores.  eg. 'filters = { context = "default", __mailbox = 1234 }  WARNING: if you exclude this field, all rows will be deleted!]],
}

jester.help_map.data.actions.data_query = {}
jester.help_map.data.actions.data_query.description_short = [[Executes a custom query against a data source.]]
jester.help_map.data.actions.data_query.description_long = [[Allows running custom queries on outside data sources.  Row data can be optionally loaded into a storage area.

This action should only be used if regular data actions will not suffice -- its use is discouraged as it may not be portable across handlers/databases.  If table joins are needed, it is suggested you handle that at the database layer (eg, by creating a view in MySQL).

Important note: core handlers for the data_query action clear all data from the specified storage area before they load new data into it -- if you need something preserved across mulitple loads, put it in a different storage area!]]
jester.help_map.data.actions.data_query.params = {
  config = [[A table of information to pass which describes where to find the data.  Check handlers to see the fields for this table.  Note that for this action, any table information is provided by the query parameter.]],
  query = [[The custom query to execute.  Tokens are replaced prior to running the query.]],
  tokens = [[(Optional) A table of token replacements to apply, key = token name, value = token replacement, eg. 'tokens = {foo = "bar"}' would replace the token ':foo' with 'bar'.  Note that for security reasons, all token values will be run through an escaping function prior to token replacement if appropriate/available.]],
  return_fields = [[(Optional) If set to true, field data from the query will be returned to the specified storage area, and the number of returned rows will be placed in the '__count' key.  Default is false.]],
  storage_area = [[(Optional) The storage area to store the data in after loading.  Defaults to 'data'.  Eg. Setting 'storage_area = "mailbox_settings"' would store the data in the 'mailbox_settings' storage area.]],
}

