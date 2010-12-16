module(..., package.seeall)

--[[
  Records a caller's message to a file.
]]
function record_file(action)
  local dir = action.location or "/tmp"
  local timestamp = os.time()
  local filename = action.filename
  if not filename then
    filename = os.date("%Y-%m-%d_%H:%M:%S") .. "-" .. jester.channel.uuid .. ".wav"
  end
  local filepath = dir .. "/" .. filename
  local area = action.storage_area
  jester.set_storage("record", "last_recording_name", filename)
  jester.set_storage("record", "last_recording_path", filepath)
  jester.set_storage("record", "last_recording_timestamp", timestamp)

  local max_length = action.max_length and tonumber(action.max_length) or 180
  local silence_threshold = action.silence_threshold and tonumber(action.silence_threshold) or 20
  local silence_secs = action.silence_secs and tonumber(action.silence_secs) or 5

  local record_append
  if action.append and action.filename then
    -- Save the current state of the variable so it can be restored.
    record_append = jester.get_variable("record_append")
    jester.set_variable("record_append", "true")
  end

  if not action.skip_beep then
    -- The pauses around the tone stream makes timing flow better, and prevents
    -- the tone from being recorded.
    session:execute("sleep", "500")
    session:execute("playback", "tone_stream://%(1000, 0, 640)")
    session:execute("sleep", "200")
  end

  jester.debug_log("Recording file to location: %s", filepath)
  local startstamp = os.time()
  session:recordFile(filepath, max_length, silence_threshold, silence_secs)
  local endstamp = os.time() 

  if action.append and action.filename then
    -- Restore the record_append variable.
    jester.set_variable("record_append", record_append)
  end

  jester.set_storage("record", "last_recording_duration", endstamp - startstamp)
  -- Store the recording settings in a custom set of keys if given.
  if area then
    jester.set_storage(area, "name", filename)
    jester.set_storage(area, "path", filepath)
    jester.set_storage(area, "timestamp", timestamp)
    jester.set_storage(area, "duration", endstamp - startstamp)
  end

  -- if jester.ready() then session:execute("sleep", "1000") end
end
