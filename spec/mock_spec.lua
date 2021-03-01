require "jester.support.file"
local cjson = require "cjson"
local ltn12 = require "ltn12"
local http_mock = require "jester.spec.http_mock"

local function request(url, params, attributes)
  local request_handler = params.request_handler or https
  local response = {}
  local body, status_code, headers, status_description = request_handler.request({
    method = "POST",
    headers = {
      ["content-length"] = attributes.content_length,
      ["content-type"] = attributes.file_type,
      ["accept"] = "application/json",
    },
    url = url,
    sink = ltn12.sink.table(response),
    source = ltn12.source.file(attributes.file),
  })
  return response, status_code, status_description
end

describe("HTTP mock", function()
  it("test mock", function()
    local mock1_data = {
      data = {hello = "world"}
    }
    local mock2_data = {
      data = {foo = "bar"}
    }
    local mock = http_mock:new({
      mock1_data,
      mock2_data,
    })
    local file, filedata = load_file("/vagrant/hello.wav")
    local url = "/"
    local params = {
      request_handler = mock:get_handler(),
    }
    local attributes = {
      file = file,
      file_type = "audio/wav",
      content_length = filedata.filesize,
    }
    local response, status_code, status_description = request(url, params, attributes)
    assert.is.equal(status_code, 200)
    assert.is.equal(status_description, "OK")
    assert.is.equal(cjson.encode(mock1_data.data), table.concat(response))
    local response, status_code, status_description = request(url, params, attributes)
    assert.is.equal(status_code, 200)
    assert.is.equal(status_description, "OK")
    assert.is.equal(cjson.encode(mock2_data.data), table.concat(response))
    local response, status_code, status_description = request(url, params, attributes)
    assert.is.equal(status_code, 200)
    assert.is.equal(status_description, "OK")
    assert.is.equal(cjson.encode(mock2_data.data), table.concat(response))
  end)
end)
