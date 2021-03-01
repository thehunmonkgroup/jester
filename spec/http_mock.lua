local ltn12 = require "ltn12"
local cjson = require "cjson"

local _M = {}

function _M.new(self, responses)
  local mock = {}
  mock.count = 0
  mock.responses = responses[1] and responses or {responses}
  setmetatable(mock, self)
  self.__index = self
  return mock
end

function _M:get_handler()
  return {
    request = function(data)
      if self.count < #self.responses then
        self.count = self.count + 1
      end
      local response = self.responses[self.count]
      local response_string = type(response.data) == "table" and cjson.encode(response.data) or response.data
      ltn12.pump.all(ltn12.source.string(response_string), data.sink)
      local body = response.body or ""
      local status_code = response.status_code or 200
      local headers = response.headers or {}
      local status_description = response.status_description or "OK"
      return body, status_code, headers, status_description
    end,
  }
end

return _M
