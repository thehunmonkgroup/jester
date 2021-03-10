--- Speech to text translation handler, Rev.ai API.
--
--  Uses Rev.ai's service. The service requires a valid developer
--  account and API key, see
--  [here](https://www.rev.ai/getting_started) for more information.
--
-- @module speech_to_text_rev_ai_handler
-- @author Chad Phillips
-- @copyright 2021 Chad Phillips

--- Parameters used to configure the speech to text request.
--
-- These are specific to the Rev.ai handler, see @{speech_to_text.params} for
-- general parameters.
--
-- @table params
--
-- @field api_key
--   Developer API key as obtained from the service credentials.
-- @field service_uri
--   Service URL as obtained from the service credentials.
-- @field query_parameters
--   Table of query parameters to pass to the API call.

local core = require "jester.core"
require "jester.support.table"
local mp = require "jester.support.multipart-post"
require "jester.modules.speech_to_text.support"

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
local function parse_response(response)
  core.log.debug("Parsing response: %s", response)
  local data = cjson.decode(response)
  return data
end

local function process_response(response, status_code, status_description)
  if status_code == 200 then
    response_string = table.concat(response)
    core.log.debug("JSON response string '%s'", response_string)
    return true, response_string
  else
    core.log.err("Request failed, status %s: '%s'", status_code, status_description)
    return false, status_description
  end
end

local function request_new_job(url, api_key, options, params, attributes)
  local request_handler = params.request_handler or https
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
  rq.headers.authorization = string.format([[Bearer %s]], api_key)
  rq.sink = ltn12.sink.table(response)
  --local body, status_code, headers, status_description = http.request(rq)
  local body, status_code, headers, status_description = request_handler.request(rq)
  return process_response(response, status_code, status_description)
end

local function request_job_status(url, api_key, params, count)
  local request_handler = params.request_handler or https
  local count = count or 1
  local response = {}
  --local body, status_code, headers, status_description = http.request({
  local body, status_code, headers, status_description = request_handler.request({
    method = "GET",
    headers = {
      ["authorization"] = string.format([[Bearer %s]], api_key),
      ["accept"] = "application/json",
    },
    url = string.format([[%s/%s]], url, params.job_id),
    sink = ltn12.sink.table(response),
  })
  core.log.debug("Job status request %d", count)
  local success, response = process_response(response, status_code, status_description)
  if success then
    success, data = pcall(parse_response, response)
    if success then
      if data.status == "failed" then
        return false, string.format([[API transcription failed: %s]], data.failure)
      elseif data.status == "transcribed" then
        core.log.debug("Transcription success")
        return success, data
      else
        if params.end_timestamp and os.time() > params.end_timestamp then
          core.log.err("Job status request timed out")
          return false, format_timeout_message(params.end_timestamp)
        else
          core.log.debug("Still waiting on transcription, sleeping %d seconds", JOB_STATUS_RETRY_SECONDS)
          socket.sleep(JOB_STATUS_RETRY_SECONDS)
          count = count + 1
          return request_job_status(url, api_key, params, count)
        end
      end
    else
      core.log.err("Parsing job status response failed: %s", data)
    end
  end
end

local function request_job_transcript(url, api_key, params)
  local request_handler = params.request_handler or https
  local response = {}
  --local body, status_code, headers, status_description = http.request({
  local body, status_code, headers, status_description = request_handler.request({
    method = "GET",
    headers = {
      ["authorization"] = string.format([[Bearer %s]], api_key),
      ["accept"] = "application/vnd.rev.transcript.v1.0+json",
    },
    url = string.format([[%s/%s/transcript]], url, params.job_id),
    sink = ltn12.sink.table(response),
  })
  core.log.debug("Job transcript request")
  return process_response(response, status_code, status_description)
end

local function request(url, api_key, options, params, attributes)
  success, response = request_new_job(url, api_key, options, params, attributes)
  if success then
    core.log.debug("New job submitted successfully")
    success, data = pcall(parse_response, response)
    if success then
      params.job_id = data.id
      core.log.debug("Requesting job status")
      success, response = request_job_status(url, api_key, params)
      if success then
        core.log.debug("Requesting job transcript")
        success, response = request_job_transcript(url, api_key, params)
        if not success then
          core.log.err("Requesting job transcript failed: %s", response)
        end
      end
    else
      core.log.err("Parsing new job response failed: %s", data)
    end
  end
  return success, response
end

local function parse_transcriptions(response)
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

local function check_params(params)
  if params.api_key then
    if params.filepath or params.options and params.options.media_url then
      params = set_start_end_timestamps(params)
      return true, params
    else
      return false, "ERROR: options.media_url or filepath required"
    end
  else
    return false, "ERROR: Missing API key"
  end
end

local function assemble_elements(elements_confidence_sum, elements_confidence_count, element_parts, elements, next_element)
  local i, element = next(elements, next_element)
  if i then
    if element.confidence then
      elements_confidence_count = elements_confidence_count + 1
      elements_confidence_sum = elements_confidence_sum + element.confidence
    end
    table.insert(element_parts, element.text)
    return assemble_elements(elements_confidence_sum, elements_confidence_count, element_parts, elements, i)
  else
    local text = table.concat(element_parts)
    return elements_confidence_sum, elements_confidence_count, text
  end
end

local function assemble_transcriptions_to_text(confidence_sum, confidence_count, text_parts, data, next_i)
  local i, monologue = next(data, next_i)
  if i then
    local element_parts = {}
    local elements_confidence_sum, elements_confidence_count, elements_text = assemble_elements(0, 0, element_parts, monologue)
    confidence_sum = confidence_sum + elements_confidence_sum
    confidence_count = confidence_count + elements_confidence_count
    table.insert(text_parts, elements_text)
    return assemble_transcriptions_to_text(confidence_sum, confidence_count, text_parts, data, i)
  else
    local confidence = confidence_sum == 0 and 0 or (confidence_sum / confidence_count * 100)
    local text = table.concat(text_parts, "\n\n")
    return confidence, text
  end
end

--- Format transcription data to plain text.
--
-- @tab data
--   A table of transcription data as returned by @{parse_transcriptions}.
-- @treturn number confidence
--   Number from zero to one hundred, representing the average confidence of all
--   translated parts.
-- @treturn string text
--   Concatenated transcription.
-- @usage
--   confidence, text = transcriptions_to_text(data)
function _M.transcriptions_to_text(data)
  local confidence_sum = 0
  local confidence_count = 0
  local text_parts = {}
  local confidence, text = assemble_transcriptions_to_text(confidence_sum, confidence_count, text_parts, data)
  core.log.debug("Confidence in transcription: %.2f%%\n", confidence)
  core.log.debug("TEXT: \n\n%s", text)
  return confidence, text
end

--- Parse a response from a successful API call.
--
-- @string response
--   The response from the API call.
-- @treturn bool success
--   Indicates if operation succeeded.
-- @return data
--   Table of transcriptions on success, error message on fail.
-- @usage
--   success, data = parse_transcriptions(response)
function _M.parse_transcriptions(response)
  success, data = pcall(parse_transcriptions, response)
  if not success then
    core.log.err("Error parsing transcription: %s", data)
  end
  return success, data
end

--- Make a request to the Watson Speech to Text API to transcribe an audio file.
--
-- @tab params
--   Method params, see @{speech_to_text.params} and @{params}.
-- @tab attributes
--   Method attributes, see @{speech_to_text.attributes}.
-- @treturn bool success
--   Indicates if operation succeeded.
-- @treturn string response
--   Contents of response on success, error message on fail.
-- @usage
--   success, response = make_request(params, attributes)
function _M.make_request(params, attributes)
  local success, response = check_params(params)
  if success then
    params = response
    local url = string.format("%s/jobs", BASE_URL)
    local options = params.options or DEFAULT_OPTIONS
    core.log.info("Got request to translate file '%s', using request URI '%s'", params.filepath, url)
    success, response = request(url, params.api_key, options, params, attributes)
  end
  return success, response
end

return _M
