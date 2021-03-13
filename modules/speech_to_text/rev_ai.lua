--- Speech to text transcription handler, Rev.ai API.
--
--  Uses Rev.ai's service. The service requires a valid developer
--  account and API key, see
--  [here](https://www.rev.ai/getting_started) for more information.
--
-- @module speech_to_text_rev_ai_handler
-- @author Chad Phillips
-- @copyright 2021 Chad Phillips

require "jester.support.table"
require "jester.modules.speech_to_text.support"
local mp = require "jester.support.multipart-post"
local core = require "jester.core"
core.bootstrap()

local LOG_PREFIX = "JESTER::MODULE::SPEECH_TO_TEXT::REV_AI"
local DEFAULT_PARAMS = {
  retries = 3,
  retry_wait_seconds = 60,
  options = {
  },
}

local _M = {}

local https = require 'ssl.https'
--local http = require 'socket.http'
local ltn12 = require("ltn12")
local cjson = require("cjson")
local socket = require("socket")

--local BASE_URL = "http://localhost:3000/v1"
local BASE_URL = "https://api.rev.ai/speechtotext/v1"
local JOB_STATUS_RETRY_SECONDS = 10
local DEFAULT_OPTIONS = {}

--- Parse a response from a successful API call.
local function parse_response(self, response)
  self.log.debug("Parsing response: %s", response)
  local data = cjson.decode(response)
  return data
end

local function process_response(self, response, status_code, status_description)
  local response_string = table.concat(response)
  if status_code == 200 then
    self.log.debug("JSON response string '%s'", response_string)
    return true, response_string
  else
    self.log.err("Request failed, status %s: description: %s, response: %s", status_code, status_description, response_string)
    return false, status_description
  end
end

local function request_new_job(self, url, options, attributes)
  local request_handler = self.params.request_handler or https
  local response = {}
  local options_string = cjson.encode(options)
  local rq
  -- media_url means JSON body with no local file.
  if options.media_url then
    rq = {
      method = "POST",
      headers = {
        ["content-length"] = string.len(options_string),
        ["content-type"] = "application/json",
      },
      source = ltn12.source.string(options_string),
    }
  else
    -- Otherwise local file upload via multipart form.
    rq = mp.gen_request({
      media = {
        filename = attributes.basename,
        data = attributes.file,
        len = attributes.content_length,
        content_type = attributes.file_type,
      },
      options = options_string,
    })
  end
  rq.url = url
  rq.headers.authorization = string.format([[Bearer %s]], self.params.api_key)
  rq.sink = ltn12.sink.table(response)
  local body, status_code, headers, status_description = request_handler.request(rq)
  return process_response(self, response, status_code, status_description)
end

local function request_job_status(self, url, count)
  local request_handler = self.params.request_handler or https
  local count = count or 1
  local response = {}
  local body, status_code, headers, status_description = request_handler.request({
    method = "GET",
    headers = {
      ["authorization"] = string.format([[Bearer %s]], self.params.api_key),
      ["accept"] = "application/json",
    },
    url = string.format([[%s/%s]], url, self.params.job_id),
    sink = ltn12.sink.table(response),
  })
  self.log.debug("Job status request %d", count)
  local success, response = process_response(self, response, status_code, status_description)
  if success then
    success, data = pcall(parse_response, self, response)
    if success then
      if data.status == "failed" then
        return false, string.format([[API transcription failed: %s]], data.failure)
      elseif data.status == "transcribed" then
        self.log.debug("Transcription success")
        return success, data
      else
        if self.params.end_timestamp and os.time() > self.params.end_timestamp then
          self.log.err("Job status request timed out")
          return false, stt_format_timeout_message(self.params.end_timestamp)
        else
          self.log.debug("Still waiting on transcription, sleeping %d seconds", JOB_STATUS_RETRY_SECONDS)
          socket.sleep(JOB_STATUS_RETRY_SECONDS)
          count = count + 1
          return request_job_status(self, url, count)
        end
      end
    else
      self.log.err("Parsing job status response failed: %s", data)
    end
  end
end

local function request_job_transcript(self, url)
  local request_handler = self.params.request_handler or https
  local response = {}
  local body, status_code, headers, status_description = request_handler.request({
    method = "GET",
    headers = {
      ["authorization"] = string.format([[Bearer %s]], self.params.api_key),
      ["accept"] = "application/vnd.rev.transcript.v1.0+json",
    },
    url = string.format([[%s/%s/transcript]], url, self.params.job_id),
    sink = ltn12.sink.table(response),
  })
  self.log.debug("Job transcript request")
  return process_response(self, response, status_code, status_description)
end

local function request(self, url, options, attributes)
  success, response = request_new_job(self, url, options, attributes)
  if success then
    self.log.debug("New job submitted successfully")
    success, data = pcall(parse_response, self, response)
    if success then
      self.params.job_id = data.id
      self.log.debug("Requesting job status")
      success, response = request_job_status(self, url)
      if success then
        self.log.debug("Requesting job transcript")
        success, response = request_job_transcript(self, url)
        if not success then
          self.log.err("Requesting job transcript failed: %s", response)
        end
      end
    else
      self.log.err("Parsing new job response failed: %s", data)
    end
  end
  return success, response
end

local function build_and_execute_request(self, options, attributes)
  local url = string.format("%s/jobs", BASE_URL)
  local to_transcribe = options.media_url or attributes.path
  self.log.info("Got request to transcribe file '%s', using request URI '%s'", to_transcribe, url)
  return request(self, url, options, attributes)
end

local function parse_transcriptions(self, response)
  local monologues = {}
  local data = cjson.decode(response)
  for mk, monologue in ipairs(data.monologues) do
    monologues[mk] = {}
    for tk, element in ipairs(monologue.elements) do
      monologues[mk][tk] = {}
      if element.type == "text" or element.type == "punct" then
        monologues[mk][tk].text = element.value
        if element.type == "text" then
          monologues[mk][tk].confidence = element.confidence
        end
      else
        monologues[mk][tk].text = "..."
        monologues[mk][tk].confidence = 0
      end
    end
  end
  return monologues
end

local function check_params(self, file_params, options)
  if self.params.api_key then
    if file_params and file_params.path or options and options.media_url then
      self.params = stt_set_start_end_timestamps(self.params)
      return true, self.params
    else
      return false, "options.media_url or filepath required"
    end
  else
    return false, "Missing API key"
  end
end

local function assemble_elements(self, elements_confidence_sum, elements_confidence_count, element_parts, elements, next_element)
  local i, element = next(elements, next_element)
  if i then
    if element.confidence then
      elements_confidence_count = elements_confidence_count + 1
      elements_confidence_sum = elements_confidence_sum + element.confidence
    end
    table.insert(element_parts, element.text)
    return assemble_elements(self, elements_confidence_sum, elements_confidence_count, element_parts, elements, i)
  else
    local text = table.concat(element_parts)
    return elements_confidence_sum, elements_confidence_count, text
  end
end

local function assemble_transcriptions_to_text(self, confidence_sum, confidence_count, text_parts, data, next_i)
  local i, monologue = next(data, next_i)
  if i then
    local element_parts = {}
    local elements_confidence_sum, elements_confidence_count, elements_text = assemble_elements(self, 0, 0, element_parts, monologue)
    confidence_sum = confidence_sum + elements_confidence_sum
    confidence_count = confidence_count + elements_confidence_count
    table.insert(text_parts, elements_text)
    return assemble_transcriptions_to_text(self, confidence_sum, confidence_count, text_parts, data, i)
  else
    local confidence = confidence_sum == 0 and 0 or (confidence_sum / confidence_count * 100)
    local text = table.concat(text_parts, "\n\n")
    return confidence, text
  end
end

--- Make a generic POST request to the Rev.ai API.
--
-- @string path
--   Path to POST to.
-- @tab json
--   Table of data to translate to JSON.
-- @treturn bool success
--   Indicates if operation succeeded.
-- @treturn response
--   Table of json data on success, error message on fail.
-- @usage
--   success, response = handler:post_json("vocabularies", json)
function _M:post_json(path, json)
  local request_handler = self.params.request_handler or https
  local response = {}
  local url = string.format("%s/%s", BASE_URL, path)
  local json_string = cjson.encode(json)
  self.log.debug("POST request to: %s", url)
  local body, status_code, headers, status_description = request_handler.request({
    method = "POST",
    url = url,
    headers = {
      ["content-length"] = string.len(json_string),
      ["authorization"] = string.format([[Bearer %s]], self.params.api_key),
      ["content-type"] = "application/json",
    },
    source = ltn12.source.string(json_string),
    sink = ltn12.sink.table(response),
  })
  local success, response = process_response(self, response, status_code, status_description)
  if success then
    self.log.debug("POST request success to: %s", url)
    success, data = pcall(parse_response, self, response)
    return success, data
  else
    self.log.err("POST request failed to: %s, %s", url, response)
    return success, response
  end
end

--- Make a generic GET request to the Rev.ai API.
--
-- @string path
--   Path to GET.
-- @treturn bool success
--   Indicates if operation succeeded.
-- @treturn response
--   Table of json data on success, error message on fail.
-- @usage
--   success, response = handler:get("vocabularies")
function _M:get(path)
  local request_handler = self.params.request_handler or https
  local response = {}
  self.log.debug("GET request to: %s", url)
  local body, status_code, headers, status_description = request_handler.request({
    method = "GET",
    headers = {
      ["authorization"] = string.format([[Bearer %s]], self.params.api_key),
      ["accept"] = "application/json",
    },
    url = string.format([[%s/%s]], BASE_URL, path),
    sink = ltn12.sink.table(response),
  })
  local success, response = process_response(self, response, status_code, status_description)
  if success then
    self.log.debug("GET request success to: %s", url)
    success, data = pcall(parse_response, self, response)
    return success, data
  else
    self.log.err("GET request failed to: %s, %s", url, response)
    return success, response
  end
end

--- Make a generic DELETE request to the Rev.ai API.
--
-- @string path
--   Path to DELETE.
-- @treturn bool success
--   Indicates if operation succeeded.
-- @treturn response
--   Table of json data on success, error message on fail.
-- @usage
--   success, response = handler:delete("vocabularies")
function _M:delete(path)
  local request_handler = self.params.request_handler or https
  local response = {}
  self.log.debug("DELETE request to: %s", url)
  local body, status_code, headers, status_description = request_handler.request({
    method = "DELETE",
    headers = {
      ["authorization"] = string.format([[Bearer %s]], self.params.api_key),
      ["accept"] = "application/json",
    },
    url = string.format([[%s/%s]], BASE_URL, path),
    sink = ltn12.sink.table(response),
  })
  local response_string = table.concat(response)
  if status_code == 204 then
    self.log.debug("DELETE request success to: %s", url)
    return true, response_string
  else
    self.log.err("DELETE request failed, status %s: description: %s, response: %s", status_code, status_description, response_string)
    return false, status_description
  end
end

--- Format transcription data to plain text.
--
-- @tab data
--   A table of transcription data as returned by @{parse_transcriptions}.
-- @treturn number confidence
--   Number from zero to one hundred, representing the average confidence of all
--   transcribed parts.
-- @treturn string text
--   Concatenated transcription.
-- @usage
--   confidence, text = handler:transcriptions_to_text(data)
function _M:transcriptions_to_text(data)
  local confidence_sum = 0
  local confidence_count = 0
  local text_parts = {}
  local confidence, text = assemble_transcriptions_to_text(self, confidence_sum, confidence_count, text_parts, data)
  self.log.debug("Confidence in transcription: %.2f%%\n", confidence)
  self.log.debug("TEXT: \n\n%s", text)
  return confidence, text
end

--- Parse a transcription response from a successful API call.
--
-- @string response
--   The response from the API call.
-- @treturn bool success
--   Indicates if operation succeeded.
-- @return data
--   Table of transcriptions on success, error message on fail.
-- @usage
--   success, data = handler:parse_transcriptions(response)
function _M:parse_transcriptions(response)
  success, data = pcall(parse_transcriptions, self, response)
  if not success then
    self.log.err("Error parsing transcription: %s", data)
  end
  return success, data
end

--- Make a request to the Rev.ai Speech to Text API to transcribe an audio file.
--
-- @param file_params
--   Optional. Table of file parameters, as passed to @{speech_to_text_support.load_file_attributes},
--   Required if options are not set.
-- @tab options
--   Optional. Options to pass to the API request.
--   Required if file_params are not set.
-- @treturn bool success
--   Indicates if operation succeeded.
-- @treturn string response
--   Contents of response on success, error message on fail.
-- @usage
--   local file_params = {
--     path = "/tmp/myfile.wav",
--     -- ...other options...
--   }
--   -- ...or...
--   local options = {
--     media_url = "http://example.com/myfile.wav",
--     -- ...other options...
--   }
--   success, response = handler:make_request(file_params, options)
function _M:make_request(file_params, options)
  options = options and options or {}
  options = table.merge(self.params.options, options)
  local success, response = check_params(self, file_params, options)
  if success then
    self.params = response
    if file_params then
      success, response = load_file_attributes(file_params)
    else
      response = {}
    end
    if success then
      return build_and_execute_request(self, options, response)
    end
  end
  return success, response
end

--- Create a new Rev.ai speech to text handler object.
--
-- @param self
-- @param params
--   Configuration parameters, see @{speech_to_text.new} for general parameters.
-- @param params.api_key
--   Developer API key as obtained from the service credentials.
-- @param params.options
--   Optional. Table of options to pass to the API call.
-- @return A Rev.ai speech to text handler object.
-- @usage
--   local rev_ai = require("jester.modules.speech_to_text.rev_ai")
--   local params = {
--     api_key = "some_api_key",
--     -- other params...
--   }
--   local handler = rev_ai:new(params)
function _M.new(self, params)
  local rev_ai = {}
  rev_ai.params = table.merge(DEFAULT_PARAMS, params or {})
  rev_ai.log = core.logger({prefix = LOG_PREFIX})
  setmetatable(rev_ai, self)
  self.__index = self
  rev_ai.log.debug("New Rev.ai speech to text handler object")
  return rev_ai
end

return _M
