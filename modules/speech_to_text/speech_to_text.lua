module(..., package.seeall)

local io = require("io")
local http = require("socket.http")
local ltn12 = require("ltn12")
require "jester.support.file"
local cjson = require("cjson")

--[[
  Speech to text using Google's API.
]]
function speech_to_text_from_file_google(action)
  require "lfs"

  local filepath = action.filepath
  local area = action.storage_area or "speech_to_text"

  if filepath then
    -- Verify file exists.
    local success, file_error = lfs.attributes(filepath, "mode")
    if success then
      local flac_file = os.tmpname()
      local command = string.format("flac -f --compression-level-0 --sample-rate=8000 -o %s %s", flac_file, filepath)
      local result = os.execute(command)
      jester.debug_log("Flac return code: %s", result)

      -- TODO: This call is sometimes returning -1, which is the C system()
      -- call error code for a failure, even though the file is converted
      -- successfully. This only seems to happen when flac is called from
      -- within FreeSWITCH, calling the exact same command from the shell
      -- returns 0, no idea why. Since flac error codes are always greater
      -- than 0, this is at least a workable approach to make things function
      -- until the real problem is uncovered.
      if result < 1 then
        local file = io.open(flac_file, "rb")
        local filesize = (filesize(file))

        local response = {}

        local body, status_code, headers, status_description = http.request({
          method = "POST",
          headers = {
            ["content-length"] = filesize,
            ["content-type"] = "audio/x-flac; rate=8000",
          },
          url = "http://www.google.com/speech-api/v1/recognize?xjerr=1&client=chromium&lang=en-US",
          sink = ltn12.sink.table(response),
          source = ltn12.source.file(file),
        })

        os.remove(flac_file)

        if status_code == 200 then
          local response_string = table.concat(response)
          jester.debug_log("Google API server response: %s", response_string)
          local data = cjson.decode(response_string)

          jester.set_storage(area, "status", data.status or 1)

          if data.status == 0 and data.hypotheses then
            for k, chunk in ipairs(data.hypotheses) do
              jester.set_storage(area, "translation_" .. k, chunk.utterance)
              jester.set_storage(area, "confidence_" .. k, chunk.confidence)
            end
          end
        else
          jester.debug_log("ERROR: Request to Google API server failed: %s", status_description)
          jester.set_storage(area, "status", 1)
        end
      else
        jester.debug_log("ERROR: Unable to convert file %s to FLAC format via flac executable", filepath)
      end
    else
      jester.debug_log("ERROR: File %s does not exist", filepath)
    end
  end
end

