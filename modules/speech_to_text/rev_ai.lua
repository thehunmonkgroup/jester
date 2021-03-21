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

local function build_url(path)
  local url = string.format("%s/%s", BASE_URL, path)
  return url
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

local function request_new_job(self, options, attributes)
  local request_handler = self.params.request_handler or https
  local response = {}
  -- Metadata could be a simple string, if it's a table, assume it's JSON data
  -- that needs to be properly encoded.
  if options.metadata and type(options.metadata) == "table" then
    options.metadata = cjson.encode(options.metadata)
  end
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
  rq.url = build_url("jobs")
  rq.headers.authorization = string.format([[Bearer %s]], self.params.api_key)
  rq.sink = ltn12.sink.table(response)
  local body, status_code, headers, status_description = request_handler.request(rq)
  return process_response(self, response, status_code, status_description)
end

local function request_job_status(self, job_id, count)
  local count = count or 1
  self.log.debug("Job status request %d", count)
  local job_path = string.format([[jobs/%s]], job_id)
  local success, data = self:get(job_path)
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
        return request_job_status(self, job_id, count)
      end
    end
  else
    self.log.err("Fetching job status failed: %s", data)
  end
end

local function request_job_transcript(self, job_id)
  local headers = {
    ["accept"] = "application/vnd.rev.transcript.v1.0+json",
  }
  local path = string.format([[jobs/%s/transcript]], job_id)
  return self:get(path, {}, headers)
end

local function request_wait_for_transcript(self, job_id)
  self.log.debug("Requesting job status")
  local success, response = request_job_status(self, job_id)
  if success then
    self.log.debug("Requesting job transcript")
    success, response = request_job_transcript(self, job_id)
    if not success then
      self.log.err("Requesting job transcript failed: %s", response)
    end
  else
    self.log.err("Requesting job status failed: %s", response)
  end
  return success, response
end

local function request(self, options, attributes)
  local success, response = request_new_job(self, options, attributes)
  if success then
    self.log.debug("New job submitted successfully")
    success, response = pcall(parse_response, self, response)
    if success then
      if self.params.jobs_only then
        return success, response
      end
      success, response = request_wait_for_transcript(self, response.id)
    else
      self.log.err("Parsing new job response failed: %s", response)
    end
  end
  return success, response
end

local function build_and_execute_request(self, options, attributes)
  local to_transcribe = options.media_url or attributes.path
  self.log.info("Got request to transcribe file '%s', using request URI '%s'", to_transcribe, build_url("jobs"))
  return request(self, options, attributes)
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

local function find_next_talker(self, m_indexes)
  local next_talker, next_talk_time
  for m_index, data in ipairs(m_indexes) do
    local _, el = next(data.elements, data.el_idx)
    if el and el.ts then
      if not next_talk_time or el.ts < next_talk_time then
        next_talker = m_index
        next_talk_time = el.ts
      end
    end
  end
  return next_talker
end

local function recalculate_confidences(self, el, speaker, metadata)
  if el.confidence then
    speaker.word_count = speaker.word_count + 1
    speaker.confidence_sum = speaker.confidence_sum + el.confidence
    metadata.word_count = metadata.word_count + 1
    metadata.confidence_sum = metadata.confidence_sum + el.confidence
  end
  return speaker
end

local function add_next_talker_pieces(self, m_indexes, next_talker, metadata)
  local new_speaker = m_indexes[next_talker]
  local pieces = {}
  local el_idx, el, next_idx
  repeat
    el_idx, el = next(new_speaker.elements, new_speaker.el_idx)
    if el_idx then
      new_speaker.el_idx = el_idx
      table.insert(pieces, el.value)
      new_speaker = recalculate_confidences(self, el, new_speaker, metadata)
      next_idx, next_el = next(new_speaker.elements, el_idx)
    end
  until not next_idx or next_el.ts
  return new_speaker, pieces
end

local function add_speaking_to_conversation(self, conversation, new_speaker, pieces, active_talker, next_talker)
  if next_talker == active_talker then
    conversation[#conversation].pieces = table.join(conversation[#conversation].pieces, pieces)
  else
    table.insert(conversation, {
      speaker = new_speaker.speaker,
      pieces = pieces,
    })
  end
  return conversation
end

local function summate_confidences(self, m_indexes, metadata)
  local speaker_metadata
  for speaker_idx, speaker in ipairs(m_indexes) do
    metadata.speakers[speaker_idx].word_count = speaker.word_count
    metadata.speakers[speaker_idx].confidence_sum = speaker.confidence_sum
    metadata.speakers[speaker_idx].confidence_average = speaker.word_count > 0 and (speaker.confidence_sum / speaker.word_count) or 0
  end
  metadata.confidence_average = metadata.word_count > 0 and (metadata.confidence_sum / metadata.word_count) or 0
  self.log.debug("Summated confidences")
  return metadata
end

local function monologues_to_conversation(self, composition_data, conversation, active_talker)
  local m_indexes = composition_data.m_indexes
  local metadata = composition_data.metadata
  conversation = conversation and conversation or {}
  local next_talker = find_next_talker(self, m_indexes)
  if next_talker then
    local new_speaker, pieces = add_next_talker_pieces(self, m_indexes, next_talker, metadata)
    conversation = add_speaking_to_conversation(self, conversation, new_speaker, pieces, active_talker, next_talker)
    return monologues_to_conversation(self, composition_data, conversation, next_talker)
  else
    metadata = summate_confidences(self, m_indexes, metadata)
    self.log.debug("Returning monologues converted to conversation")
    return conversation, metadata
  end
end

function set_speaker_label(self, speaker_labels, speaker_index)
  local default_label = string.format([[Speaker %d]], speaker_index)
  if speaker_labels then
    if type(speaker_labels[speaker_index]) == "string" then
      return speaker_labels[speaker_index]
    elseif speaker_labels[speaker_index] == false then
      return false
    end
  end
  return default_label
end

function talk_stream_to_conversation(self, data, metadata, speaker_labels, accum, next_i)
  accum = accum and accum or {}
  next_i, section = next(data, next_i)
  if next_i then
    formatted_section = {
      text = table.concat(section.pieces),
    }
    speaker_label = speaker_labels and speaker_labels[section.speaker + 1]
    if speaker_label then
      formatted_section.speaker = speaker_label
    end
    table.insert(accum, formatted_section)
    return talk_stream_to_conversation(self, data, metadata, speaker_labels, accum, next_i)
  else
    self.log.debug("Returning talk stream converted to conversation")
    return accum
  end
end

function format_metadata_line(self, label, confidence_average)
  local percentage = string.format([[%.2f]], confidence_average)
  -- TODO: This is ugly, how to format 100% more elegantly?
  if percentage == "1.00" then
    percentage = "100"
  end
  return string.format([[%s: %s%%]], label, percentage)
end

function format_metadata(self, metadata, speaker_labels)
  local formatted_metadata = {
    format_metadata_line(self, "Total", metadata.confidence_average),
  }
  local speaker_label
  for _, speaker in ipairs(metadata.speakers) do
    if speaker.label then
      table.insert(formatted_metadata, format_metadata_line(self, speaker.label, speaker.confidence_average))
    end
  end
  self.log.debug("Returning formatted metadata")
  return table.concat(formatted_metadata, "\n")
end

function format_conversation(self, conversation, accum, next_i)
  accum = accum and accum or {}
  local formatted_section
  next_i, section = next(conversation, next_i)
  if next_i then
    formatted_section = section.speaker and string.format("%s:\n%s", section.speaker, section.text) or section.text
    table.insert(accum, formatted_section)
    return format_conversation(self, conversation, accum, next_i)
  else
    self.log.debug("Returning formatted conversation")
    return table.concat(accum, "\n\n")
  end
end

function parse_transcriptions(self, data, speaker_labels)
  -- This is kind of a hack, but it does allow the generic speech_to_text
  -- module to be used for jobs_only configuration.
  if self.params.jobs_only then
    return data
  end
  local m_indexes = {}
  local metadata = {
    word_count = 0,
    confidence_sum = 0,
    confidence_average = 0,
    speakers = {},
  }
  for m_index, monologue in ipairs(data.monologues) do
    m_indexes[m_index] = {
      elements = monologue.elements,
      speaker = monologue.speaker,
      word_count = 0,
      confidence_sum = 0,
      confidence_average = 0,
    }
    metadata.speakers[m_index] = {
      label = set_speaker_label(self, speaker_labels, m_index)
    }
  end
  local composition_data = {
    m_indexes = m_indexes,
    metadata = metadata,
  }
  self.log.debug("Parsing %d monologues into conversation", #m_indexes)
  local data, metadata = monologues_to_conversation(self, composition_data)
  local conversation = talk_stream_to_conversation(self, data, metadata, speaker_labels)
  return {
    conversation = conversation,
    metadata = metadata,
  }
end

--- Retrieves jobs.
--
-- @tab query_parameters
--   Optional. Table of query parameters to filter the list.
-- @treturn bool success
--   Indicates if operation succeeded.
-- @treturn data
--   Table of json data on success, error message on fail.
-- @usage
--   local query_parameters = { limit = 1000 }
--   success, data = handler:get_jobs(query_parameters)
function _M:get_jobs(query_parameters)
  return self:get("jobs", query_parameters)
end

--- Retrieves a job.
--
-- @string job_id
--   Required. Job ID.
-- @treturn bool success
--   Indicates if operation succeeded.
-- @treturn data
--   Table of json data on success, error message on fail.
-- @usage
--   success, data = handler:get_job("somejobid")
function _M:get_job(job_id)
  local path = string.format([[jobs/%s]], job_id)
  return self:get(path)
end

--- Retrieves a job transcript.
--
-- @string job_id
--   Required. Job ID.
-- @treturn bool success
--   Indicates if operation succeeded.
-- @treturn data
--   Table of json data on success, error message on fail.
-- @usage
--   success, data = handler:get_job_transcript("somejobid")
function _M:get_job_transcript(job_id)
  return request_job_transcript(self, job_id)
end

--- Deletes a job.
--
-- @string job_id
--   Required. Job ID.
-- @treturn bool success
--   Indicates if operation succeeded.
-- @treturn response
--   Response string on success, error message on fail.
-- @usage
--   success, response = handler:delete_job("somejobid")
function _M:delete_job(job_id)
  local path = string.format([[jobs/%s]], job_id)
  return self:delete(path)
end

--- Retrieves custom vocabularies.
--
-- @treturn bool success
--   Indicates if operation succeeded.
-- @treturn data
--   Table of json data on success, error message on fail.
-- @usage
--   success, data = handler:get_custom_vocabularies()
function _M:get_custom_vocabularies()
  return self:get("vocabularies")
end

--- Add a custom vocabulary.
--
-- @tab data
--   Table of data describing the vocabulary.
-- @treturn bool success
--   Indicates if operation succeeded.
-- @treturn data
--   Table of json data on success, error message on fail.
-- @usage
--   local data = {
--     "metadata": "foo",
--     "custom_vocabularies": [
--       {
--         "phrases": [
--           "bar",
--         ],
--       },
--     ],
--   }
--   success, data = handler:add_custom_vocabulary(data)
function _M:add_custom_vocabulary(data)
  return self:post_json("vocabularies", data)
end

--- Show a custom vocabulary.
--
-- @string id
--   Vocabulary ID.
-- @treturn bool success
--   Indicates if operation succeeded.
-- @treturn data
--   Table of json data on success, error message on fail.
-- @usage
--   success, data = handler:show_vocabulary()
function _M:show_vocabulary(id)
  return self:get(string.format([[vocabularies/%s]], id))
end

--- Remove a custom vocabulary.
--
-- @string id
--   Vocabulary ID.
-- @treturn bool success
--   Indicates if operation succeeded.
-- @treturn data
--   Response string on success, error message on fail.
-- @usage
--   success, data = handler:remove_vocabulary(id)
function _M:remove_vocabulary(id)
  return self:delete(string.format([[vocabularies/%s]], id))
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
  local url = build_url(path)
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
    success, response = pcall(parse_response, self, response)
    return success, response
  else
    self.log.err("POST request failed to: %s, %s", url, response)
    return success, response
  end
end

--- Make a generic GET request to the Rev.ai API.
--
-- @string path
--   Path to GET.
-- @tab query_parameters
--   Optional. Table of query parameters to pass to the request.
-- @tab headers
--   Optional. Table of headers to pass to the request, these will be merged
--   with the default headers.
-- @treturn bool success
--   Indicates if operation succeeded.
-- @treturn response
--   Table of json data on success, error message on fail.
-- @usage
--   success, response = handler:get("vocabularies")
function _M:get(path, query_parameters, headers)
  local request_handler = self.params.request_handler or https
  local query_string = table.stringify(query_parameters)
  local response = {}
  local default_headers = {
    ["authorization"] = string.format([[Bearer %s]], self.params.api_key),
    ["accept"] = "application/json",
  }
  local headers = table.merge(default_headers, headers or {})
  local url = string.format([[%s?%s]], build_url(path), query_string)
  self.log.debug("GET request to: %s", url)
  local body, status_code, headers, status_description = request_handler.request({
    method = "GET",
    headers = headers,
    url = url,
    sink = ltn12.sink.table(response),
  })
  local success, response = process_response(self, response, status_code, status_description)
  if success then
    self.log.debug("GET request success to: %s", url)
    success, response = pcall(parse_response, self, response)
    return success, response
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
--   Response string on success, error message on fail.
-- @usage
--   success, response = handler:delete("vocabularies")
function _M:delete(path)
  local request_handler = self.params.request_handler or https
  local response = {}
  local url = build_url(path)
  self.log.debug("DELETE request to: %s", url)
  local body, status_code, headers, status_description = request_handler.request({
    method = "DELETE",
    headers = {
      ["authorization"] = string.format([[Bearer %s]], self.params.api_key),
      ["accept"] = "application/json",
    },
    url = url,
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
-- @treturn string formatted_metadata
--   Text representation of the metadata, which includes total confidence, and
--   condifence per speaker.
-- @treturn string text
--   Concatenated transcription.
-- @usage
--   confidence, text = handler:transcriptions_to_text(data)
function _M:transcriptions_to_text(data)
  local formatted_metadata = format_metadata(self, data.metadata)
  local text = format_conversation(self, data.conversation)
  return formatted_metadata, text
end

--- Parse a transcription response from a successful API call.
--
-- @tab data
--   The JSON data from the API call.
-- @tab speaker_labels
--   Optional. List of speaker labels. If provided, they will be applied in
--   order of speaker to replace the generic speaker labels.
-- @treturn bool success
--   Indicates if operation succeeded.
-- @return data
--   Table of transcription data on success, error message on fail.
--   Transcription data has two keys: conversation, which contains the
--   conversation data, and metadata, which contains the metadata, such as
--   predicted accuracies.
-- @usage
--   success, data = handler:parse_transcriptions(data)
function _M:parse_transcriptions(data, speaker_labels)
  success, data = pcall(parse_transcriptions, self, data, speaker_labels)
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
