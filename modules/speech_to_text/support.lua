--- Speech to text translation support functions.
--
-- This module provides support functions for speech to text translation.
--
-- @module speech_to_text_support
-- @author Chad Phillips
-- @copyright 2011-2021 Chad Phillips

--- Attributes calculated for @{load_file_attributes}.
--
-- @table file_attributes
--
-- @field file
--   The opened file object for the filepath being transcribed.
-- @field content_type_type
--   Mime type of the file, default "audio/wav".
-- @field content_length
--   File size in bytes.
-- @field dirname
--   Directory file is in.
-- @field basename
--   Base name of file.
-- @field ext
--   File extension.



require("jester.support.file")
require("jester.support.table")

local core = require("jester.core")
core.bootstrap()

local log = core.logger({prefix = "JESTER::MODULE::SPEECH_TO_TEXT::SUPPORT"})

function stt_set_start_end_timestamps(params)
  params.start_timestamp = params.start_timestamp and tonumber(params.start_timestamp) or os.time()
  if not params.end_timestamp and params.timeout_seconds then
    params.end_timestamp = params.start_timestamp + tonumber(params.timeout_seconds)
    log.debug("Set end_timestamp to: %d", params.end_timestamp)
  end
  return params
end

function stt_format_timeout_message(timestamp)
  return string.format([[Request timed out at: %s]], os.date("!%Y-%m-%dT%TZ", timestamp))
end

function stt_merge_params(...)
  return table.merge(...)
end

--- Load a file and calculate some file attributes.
--
-- @param file_params
--   Required. Table of file parameters.
-- @param file_params.path
--   Path to file.
-- @param file_params.content_type
--   Optional. Default "audio/wav".
-- @return
--   @{file_attributes} table.
-- @usage
--   local file_params = {
--     path = "/tmp/myfile.wav",
--     content_type = "audio/wav",
--   }
--   local attributes = load_file_attributes(file_params)
function load_file_attributes(file_params)
  local filepath = file_params.path
  if not filepath then
    return true
  end
  local content_type = file_params.content_type or DEFAULT_CONTENT_TYPE
  local content_length
  local file, data = load_file(filepath)
  if file then
    log.debug("Loaded file attributes from: %s", filepath)
    local dirname, basename, ext = filepath_elements(filepath)
    local attributes = {
      path = filepath,
      file = file,
      content_type = content_type,
      content_length = data.filesize,
      dirname = dirname,
      basename = basename,
      ext = ext,
    }
    return file, attributes
  else
    local message = string.format([[Could not open '%s': %s]], filepath, data)
    log.err(message)
    return false, message
  end
end
