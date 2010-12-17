jester.help.data = {}
jester.help.data.description_short = [[Handle outside data.]]
jester.help.data.description_long = [[This module provides actions that deal with reading and writing of external data into Jester.]]
jester.help.data.handlers = {} 
jester.help.data.handlers.odbc = [[The default handler for the data module.  The 'config' parameter for all actions using it under this handler is a table with the following key/value pairs:
  
  database_type:
    The type of database being accessed.  Valid values are 'mysql', 'pgsql', and 'sqlite'.
  database:
    The name of the ODBC datasource to access.
  table:
    The table in the database to operate on.
]]

jester.help.data.actions = {}

jester.help.data.actions.data_load = {}
jester.help.data.actions.data_load.description_short = [[Load outside data into Jester storage.]]
jester.help.data.actions.data_load.description_long = [[Allows loading of data from outside sources.

Important note: core handlers for the data_load action clear all data from the specified storage area before they load new data into it -- if you need something preserved across mulitple loads, put it in a different storage area!]]
jester.help.data.actions.data_load.params = {
  config = [[A table of information to pass which describes where to find the data.  Check handlers to see the fields for this table.]],
  filters = [[A table of filters to apply when loading the data.  This restricts what is loaded to the filtered values.  Filters are cumulative (AND logic).  The key is the name of the filter, and the value is the value to filter on.  Filter values are interpreted as strings by default -- if a filter value is a number, prefix the filter key with double underscores.  eg. 'filters = { context = "default", __mailbox = 1234 }]],
  fields = [[A table of fields to load.  Include only the field names as values, no keys.  Field types are interpreted as strings by default -- if a field type is numeric, prefix the field name with double underscores, eg. 'fields = { "__mailbox", "context", "password", "email" }]],
  multiple = [[Boolean indicating whether to load multiple sets of data.  True loads all data that passes through the filters, false only loads the first set of data.  Default is false.  Note that multiple results are suffixed with the result set number before being put in the data storage area, eg. if you loaded multiple result sets of a field named 'number', the first set would be stored as 'number_1', the second as 'number_2' and so on...
Note that if this parameter is set, in addition to storing the data that is loaded, a special key '__count' is added, which holds the number of rows returned.]],
  sort = [[A field to sort the data by before loading.  This is only used with the 'mulitple' parameter.  Eg. 'sort = "timestamp"']],
  sort_order = [[The sorting order.  Only used with the 'sort' and 'multiple' parameters.  Valid values are 'asc' and 'desc', the default is 'asc'.]], 
  storage_area = [[(Optional) The storage area to store the data in after loading.  Defaults to 'data'.  Eg. Setting 'storage_area = "mailbox_settings"' would store the data in the 'mailbox_settings' storage area.]],
}

jester.help.data.actions.data_update = {}
jester.help.data.actions.data_update.description_short = [[Update outside data.]]
jester.help.data.actions.data_update.description_long = [[Allows updating/insertion of data to outside sources (currently ODBC data sources only).]]
jester.help.data.actions.data_update.params = {
  config = [[A table of information to pass which describes where to find the data.  Check handlers to see the fields for this table.]],
  filters = [[A table of filters to apply when loading the data.  This restricts what is loaded to the filtered values.  Filters are cumulative (AND logic).  The key is the name of the filter, and the value is the value to filter on.  Filter values are interpreted as strings by default -- if a filter value is a number, prefix the filter key with double underscores.  eg. 'filters = { context = "default", __mailbox = 1234 }]],
  fields = [[A table of fields to load.  Keys are the field names to update, values are the values to update to.  Field types are interpreted as strings by default -- if a field type is numeric, prefix the field name with double underscores, eg. 'fields = { __mailbox = 1234, context = "default"}'.]],
  update_type = [[(Optional) If this parameter is not provided, the default behavior is to first attempt an update, and if no rows were updated, then perform an insert.  To force either an update or insert, set this to 'update' or 'insert' respectively.]],
}


jester.help.data.actions.data_delete = {}
jester.help.data.actions.data_delete.description_short = [[Delete outside data.]]
jester.help.data.actions.data_delete.description_long = [[Allows deletion of data from outside sources (currently ODBC data sources only).]]
jester.help.data.actions.data_update.params = {
  config = [[A table of information to pass which describes where to find the data.  Check handlers to see the fields for this table.]],
  filters = [[A table of filters to apply when loading the data.  This restricts what is loaded to the filtered values.  Filters are cumulative (AND logic).  The key is the name of the filter, and the value is the value to filter on.  Filter values are interpreted as strings by default -- if a filter value is a number, prefix the filter key with double underscores.  eg. 'filters = { context = "default", __mailbox = 1234 }]],
}
