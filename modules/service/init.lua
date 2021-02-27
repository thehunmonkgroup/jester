--- Access external services.
--
-- This module provides actions for accessing external services, such as
-- webservices.
--
-- @module service
-- @author Chad Phillips
-- @copyright 2011-2015 Chad Phillips

--- Last HTTP request storage.
--
-- The resulting status of the last request is stored in the
-- 'last\_http\_request' storage area, with the following keys:
--
-- @table last_http_request
--
-- @field code
--   An HTTP/1.1 return code, or 'error' if the request fails.
-- @field description
--   A human-readable description of the code.


--- Make an HTTP request to a external server.
--
-- Only the http:// protocol is supported.
--
-- The status of the completed request is stored in the @{last_http_request}
-- storage area.
--
-- If the request returns a '200' status code, then the body of the response
-- will be stored according to the parameter settings.
--
-- @action http_request
-- @string action
--   http_request
-- @string fragment
--   (Optional) A fragment to append to the URL. It will be properly escaped
--   before sending.
-- @string password
--   (Optional) A password to use for basic authentication. 'user' parameter
--   must also be provided.
-- @string path
--   (Optional) The server path to send the request to, no leading or trailing
--   slash.
-- @int port
--   (Optional) The port to send the request to. Default is 80.
-- @tab query
--   (Optional) A table of query parameters to append to the URL. Keys must be
--   only numbers, letters, and underscores, values can be any string and will
--   be properly URL escaped before sending.
-- @string response
--   (Optional) The format to expect the response in:
--     lua:
--       A string that represents a Lua table, of the following format:
--         return {
--           foo = 'bar',
--         }
--         The table data will be loaded into the specified storage area. Table
--         values cannot contain a table.
--     raw:
--       A string of raw data. This will be stored in the specified storage
--       area under the 'raw' storage key.
--   Default is 'raw'.
-- @string server
--   (Optional) The server to send the request to. Default is 'localhost'.
-- @string storage_area
--   (Optional) The storage area to store the response in. Defaults to
--   'service'.
-- @string user
--   (Optional) A user name to use for basic authentication.
-- @usage
--   {
--     action = "http_request",
--     fragment = "some fragment",
--     password = "secret",
--     path = "path/to/resource",
--     port = 80,
--     query = {
--       foo = "bar",
--       baz = "two words"
--     },
--     response = "raw",
--     server = "www.example.com",
--     storage_area = "my_http_request",
--     user = "bob",
--   }


local core = require "jester.core"

local _M = {}

--[[
  Log to the console.
]]
function _M.http_request(action)
  local server = action.server or "localhost"
  local port = action.port and tostring(action.port) or "80"
  local path = action.path or "/"
  local query = action.query
  local fragment = action.fragment or ""
  local user = action.user
  local password = action.password
  local response = action.response or "raw"
  local area = action.storage_area or "service"
  local query_string = ""
  local user_string = ""

  local http = require("socket.http")
  local url = require("socket.url")

  -- Transform the query params into a query string.
  if path ~= "/" then
    path = "/" .. path .. "/"
  end
  if query then
    local query_parts = {}
    for k, v in pairs(query) do
      -- Escape values but not keys.
      query_parts[#query_parts + 1] = k .. "=" .. url.escape(v)
    end
    query_string = "?" .. table.concat(query_parts, "&")
  end
  if fragment ~= "" then
    fragment = "#" .. fragment
  end
  if user then
    user_string = user
    if password then
      user_string = user_string .. ":" .. password
    end
    user_string = user_string .. "@"
  end
  url = "http://" .. user_string .. server .. ":" .. port .. path .. query_string .. fragment
  core.log.debug("HTTP request, URL: %s", url)

  local code, description, data
  -- Send the request.
  local body, status_code, headers, status_description = http.request(url)
  -- Request succeeded.
  if body then
    data = body
    code = status_code
    description = status_description
    -- Only store response data if we get a 200 OK code.
    if code == 200 then
      -- Store raw data.
      if response == "raw" then
        core.set_storage(area, "raw", data)
      -- Data is a Lua table.
      elseif response == "lua" then
        -- Load the data string as Lua code.
        local func = loadstring(data)
        if func then
          -- Sandbox the function to protect against malicious code.
          setfenv(func, {})
          local table_data = func()
          -- Make sure a table was returned.
          if type(table_data) == "table" then
            for k, v in pairs(table_data) do
              core.set_storage(area, k, v)
            end
          else
            core.log.debug("ERROR: Returned data is not a Lua table.")
          end
        else
          core.log.debug("ERROR: Failed to parse response body as Lua code.")
        end
      end
    end
  -- Request failed.
  else
    code = "error"
    description = status_code
    data = ""
  end
  core.set_storage("last_http_request", "code", code)
  core.set_storage("last_http_request", "description", description)
  core.log.debug("HTTP response, Code: %s, Description: %s, Data: %s", code, description, data)
end

return _M
