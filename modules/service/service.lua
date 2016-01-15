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
  core.debug_log("HTTP request, URL: %s", url)

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
            core.debug_log("ERROR: Returned data is not a Lua table.")
          end
        else
          core.debug_log("ERROR: Failed to parse response body as Lua code.")
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
  core.debug_log("HTTP response, Code: %s, Description: %s, Data: %s", code, description, data)
end

return _M
