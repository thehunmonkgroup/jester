module(..., package.seeall)

local io = require("io")
local lfs = require("lfs")
require "jester.support.file"

local google = require("jester.modules.speech_to_text.google")
local att = require("jester.modules.speech_to_text.att")

--[[
  Speech to text using Google's API.
]]
function speech_to_text_from_file_google(action)
  speech_to_text_from_file(action, google.speech_to_text_from_file)
end

--[[
  Speech to text using AT&T's API.
]]
function speech_to_text_from_file_att(action)
  speech_to_text_from_file(action, att.speech_to_text_from_file)
end

--[[
  Speech to text base function.

  This function wraps the handler's specific functionaliy.
]]
function speech_to_text_from_file(action, handler)
  local filepath = action.filepath
  local area = action.storage_area or "speech_to_text"

  if filepath then
    -- Verify file exists.
    local success, file_error = lfs.attributes(filepath, "mode")
    if success then
      local file = io.open(filepath, "rb")
      local filesize = (filesize(file))
      local attributes = {
        file = file,
        filesize = filesize,
      }
      status, translations = handler(action, attributes)
      jester.set_storage(area, "status", status)
      for k, translation in ipairs(translations) do
        jester.set_storage(area, "translation_" .. k, translation.text)
        jester.set_storage(area, "confidence_" .. k, translation.confidence)
      end
    else
      jester.debug_log("ERROR: File %s does not exist", filepath)
    end
  end
end

