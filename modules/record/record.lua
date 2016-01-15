--- Record sound from a channel.
--
-- This module provides actions which deal with recording sound from a channel.
--
-- @module record
-- @author Chad Phillips
-- @copyright 2011-2015 Chad Phillips


--- Last recording storage.
--
-- The following variables/values related to the recording are put into the
-- Jester 'record' storage area upon completion of the recording. The fields
-- described are the storage keys.
--
-- @table last_recording
--
-- @field last_recording_name
--   The name of the recording.
-- @field last_recording_path
--   A full path to the recording.
-- @field last_recording_timestamp
--   The UNIX timestamp of the recording (when it began).
-- @field last_recording_duration
--   The duration of the recording in seconds.


--- Record sound from a channel.
--
-- The recording is in .wav format.
--
-- @action record
-- @string action
--   record
-- @bool append
--   (Optional) Append the recording to an existing file. Requires that the
--   'filename' parameter be set. If the named file does not exist, then it
--   will be created. Default is false.
-- @string filename
--   (Optional) The name of the recorded file. Defaults to
--   '<code>%Y-%m-%d_%H:%M:%S-${uuid}.wav</code>'.
-- @tab keys
--   (Optional) See @{03-Sequences.md.Capturing_user_key_input}.
-- @string location
--   (Optional) Where to store the file. Default is '/tmp'.
-- @int max_length
--   (Optional) Maximum allowed length of the recording in seconds. Default is
--   180.
-- @int pre_record_delay
--   (Optional) Set to the number of milliseconds to delay just prior to
--   beginning the recording. This happens after the 'pre\_record\_sound' is
--   played. This can be useful to tweak if trailing channel sounds are being
--   recording at the beginning of the recording. Set to 0 for no delay.
--   Default is 200 milliseconds.
-- @string pre_record_sound
--   (Optional) Set to a file or phrase to play prior to beginning the
--   recording, or to 'tone' to play a typical 'wait for the beep' tone.
--   Default is to do nothing.
-- @int silence_secs
--   (Optional) The number of consecutive seconds of silence to wait before
--   considering the recording finished. Default is 5.
-- @todo: Need to find doc on this setting.
-- @int silence_threshold
--   (Optional) A number indicating the threshhold for what is considered
--   silence. Higher numbers mean more noise will be tolerated. Default is 20.
-- @string storage_area
--   (Optional) If set the @{last_recording} storage values are also stored in
--   this storage area with the 'last\_recording\_' prefix stripped, eg.
--   '<code>storage_area = "message"</code>' would store 'name' in the 'message'
--   storage area with the same value as 'last\_recording\_name'.
-- @usage
--   {
--     action = "record",
--     append = false,
--     filename = greeting .. ".tmp.wav",
--     keys = {
--       ["#"] = ":break",
--     },
--     location = "/tmp",
--     max_length = profile.max_greeting_length,
--     pre_record_delay = 200,
--     pre_record_sound = "phrase:beep",
--     silence_secs = profile.recording_silence_end,
--     silence_threshold = profile.recording_silence_threshold,
--     storage_area = "record_greeting",
--   }


--- Merge two recordings.
--
-- This action merges two recorded files into one. The merge file may be
-- appended or prepended to the base file.
--
-- @action record_merge
-- @string action
--   record_merge
-- @string base_file
--   Full path to the base file for the merge. The will be the file that
--   remains after the merge.
-- @string merge_file
--   Full path to the merge file for the merge. This file will not longer exist
--   after the merge.
-- @string merge_type
--   (Optional) The type of merge to perform, valid values are 'append' and
--   'prepend'. Default is 'append'.
-- @usage
--   {
--     action = "record_merge",
--     base_file = "storage/greeting.wav",
--     merge_file = "/tmp/preroll.wav",
--     merge_type = "prepend",
--   }


local core = require "jester.core"

local _M = {}

--[[
  Records a caller's message to a file.
]]
function _M.record_file(action)
  local dir = action.location or "/tmp"
  local timestamp = os.time()
  local filename = action.filename
  local append = action.append and action.filename
  local pre_record_sound = action.pre_record_sound
  local pre_record_delay = action.pre_record_delay and tonumber(action.pre_record_delay) or 200
  local max_length = action.max_length and tonumber(action.max_length) or 180
  local silence_threshold = action.silence_threshold and tonumber(action.silence_threshold) or 20
  local silence_secs = action.silence_secs and tonumber(action.silence_secs) or 5
  local area = action.storage_area

  -- Default filename, formatted date and channel uuid.
  if not filename then
    filename = os.date("%Y-%m-%d_%H:%M:%S") .. "-" .. core.channel.uuid .. ".wav"
  end
  local filepath = dir .. "/" .. filename
  core.clear_storage("record")
  core.set_storage("record", "last_recording_name", filename)
  core.set_storage("record", "last_recording_path", filepath)
  core.set_storage("record", "last_recording_timestamp", timestamp)

  local record_append
  -- If the append param was set, activate record appending on the channel.
  -- Default filenames have the timestamp, so only set appending if a filename
  -- was specified.
  if append then
    -- Save the current state of the variable so it can be restored.
    record_append = core.get_variable("record_append")
    core.set_variable("record_append", "true")
  end

  if pre_record_sound then
    if pre_record_sound == "tone" then
      session:execute("playback", "tone_stream://%(1000, 0, 640)")
    else
      session:streamFile(pre_record_sound)
    end
  end

  if pre_record_delay > 0 then
    session:execute("sleep", pre_record_delay)
  end

  core.debug_log("Recording file to location: %s", filepath)
  -- Capture recording duration by getting timestamps immediately before and
  -- after the recording.
  local startstamp = os.time()
  local recorded = session:recordFile(filepath, max_length, silence_threshold, silence_secs)
  local endstamp = os.time()

  if append then
    -- Restore the record_append variable.
    core.set_variable("record_append", record_append)
  end

  if recorded then
    core.set_storage("record", "last_recording_duration", endstamp - startstamp)
    -- Store the recording settings in a custom set of keys if given.
    if area then
      core.set_storage(area, "name", filename)
      core.set_storage(area, "path", filepath)
      core.set_storage(area, "timestamp", timestamp)
      core.set_storage(area, "duration", endstamp - startstamp)
    end
  end
end

--[[
  Merge two recorded files.
]]
function _M.record_file_merge(action)
  local base_file = action.base_file
  local merge_file = action.merge_file
  local merge_type = action.merge_type or "append"
  local success, file_error
  if base_file and merge_file then
    require "lfs"
    -- If we can pull the file attributes, then the file exists.
    success, file_error = lfs.attributes(base_file, "mode")
    if success then
      success, file_error = lfs.attributes(merge_file, "mode")
      if success then
        if merge_type == "prepend" then
          session:insertFile(base_file, merge_file, 0)
          -- Clean up the merge file.
          os.remove(merge_file)
        else
          -- Appending is just prepending in reverse order. Moving the merge
          -- file to the base file cleans up the extra file and puts the
          -- correct file as the base file in one step.
          session:insertFile(merge_file, base_file, 0)
          os.rename(merge_file, base_file)
        end
        core.debug_log("Merged file '%s' with '%s'", base_file, merge_file)
      else
        core.debug_log("Merge file '%s' does not exist!: %s", merge_file, file_error)
      end
    else
      core.debug_log("Base file '%s' does not exist!: %s", base_file, file_error)
    end
  end
end

return _M
