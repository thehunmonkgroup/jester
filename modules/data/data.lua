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
