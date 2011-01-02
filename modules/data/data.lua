module(..., package.seeall)

local data = jester.modules.data

function load_data_odbc(action)
  require("jester.modules.data.odbc")
  data.odbc.load_data(action)
end

function load_data_odbc_count(action)
  require("jester.modules.data.odbc")
  data.odbc.load_data_count(action)
end

function update_data_odbc(action)
  require("jester.modules.data.odbc")
  data.odbc.update_data(action)
end

function delete_data_odbc(action)
  require("jester.modules.data.odbc")
  data.odbc.delete_data(action)
end

