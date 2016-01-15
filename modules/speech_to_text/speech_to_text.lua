local core = require "jester.core"

local io = require("io")
local lfs = require("lfs")
require "jester.support.file"

--local google = require("jester.modules.speech_to_text.google")
local att = require("jester.modules.speech_to_text.att")

local _M = {}

--[[
  Speech to text using Google's API.
]]
--function speech_to_text_from_file_google(action)
--  speech_to_text_from_file(action, google.speech_to_text_from_file)
--end

--[[
  Speech to text using AT&T's API.
]]
function _M.speech_to_text_from_file_att(action)
  speech_to_text_from_file(action, att.speech_to_text_from_file)
end

--[[
  Speech to text base function.

  This function wraps the handler's specific functionaliy.
]]
local function speech_to_text_from_file(action, handler)
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
      core.set_storage(area, "status", status)
      for k, translation in ipairs(translations) do
        core.set_storage(area, "translation_" .. k, translation.text)
        core.set_storage(area, "confidence_" .. k, translation.confidence)
      end
    else
      core.debug_log("ERROR: File %s does not exist", filepath)
    end
  end
end

return _M
