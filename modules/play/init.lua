--- Play sounds on a channel.
--
-- This module provides actions for playing various sounds on a channel.
--
-- @module play
-- @author Chad Phillips
-- @copyright 2011-2015 Chad Phillips


--- The file handler (default).
--
--  The default handler for the play module, operates on files on the local
--  filesystem.
--
-- @handler file
-- @usage
--   {
--     action = "play",
--     handler = "file",
--     -- other params...
--   }


--- Play something on the channel.
--
-- @action play
-- @string action
--   play
-- @tab file
--   The name of the resource to play. It should be:
--     1. A full file path
--     2. A relative file path from the FreeSWITCH 'sounds' directory
--     3. A phrase prefixed with 'phrase:'
--
--   To play a single file, a string can be passed. To play several files
--   together in a group, pass a table of names instead.
--
--   Jester uses an ampersand (&) as the default delimiter for playback of
--   mulitple files; to override this, set the '<code>playback_delimiter</code>'
--   variable in either the global or profile configuration file.
-- @tab keys
--   (Optional) See @{03-Sequences.md.Capturing_user_key_input}.
-- @int repetitions
--   (Optional) How many times to repeat the file(s). Default is 1.
-- @int wait
--   (Optional) How long to wait between repetitions, in milliseconds. Default
--   is no wait.
-- @string handler
--   The handler to use, see [handlers](#Handlers). If not specified, defaults
--   to the default handler for the module.
-- @usage
--   {
--     action = "play",
--     file = {
--       "/tmp/foo.wav",
--       "bar.wav",
--       "phrase:goodbye",
--     },
--     keys = profile.play_keys,
--     repititions = 3,
--     wait = 2000,
--   }


--- Play a series of key press choices on the channel.
--
-- This action allows you to map key press choices to announcements about what
-- each key press will do, and play these announcements in a set order on the
-- channel.
--
-- Keys are mapped both to actions, and to phrases in the FreeSWITCH phrase
-- engine. The phrases receive the mapped key as an argument.
--
-- You use this alongside of the standard 'keys' parameter to provide 'Press 1
-- for this, press 2 for that' menu selections.
--
-- The order that the announcements are made can be customized.
--
-- @action play_keys
-- @string action
--   play_keys
-- @tab key_announcements
--   A table similar to the 'keys' table, with the value for each key being
--   the name of a FreeSWITCH phrase macro to play for the key announcement.
-- @tab keys
--   (Optional) See @{03-Sequences.md.Capturing_user_key_input}.
-- @tab order
--   (Optional) A list of keys representing the order to play the announcements
--   in. If not provided, then the default order from the profile or from the
--   global configuration is used.
-- @int repetitions
--   (Optional) How many times to repeat the file(s). Default is 1.
-- @int wait
--   (Optional) How long to wait between repetitions, in milliseconds. Default
--   is no wait.
-- @usage
--   {
--     action = "play_keys",
--     key_announcements = {
--       ["4"] = "play_previous",
--       ["6"] = "play_next",
--       ["#"] = "exit",
--     },
--     keys = {
--       ["4"] = "previous_sequence",
--       ["6"] = "next_sequence",
--       ["#"] = "exit_sequence",
--     },
--     order = {"6", "4", "#"}
--     repititions = 3,
--     wait = 2000,
--   }


--- Play a phrase macro.
--
-- This action plays a FreeSWITCH phrase macro on the channel.
--
-- @action play_phrase
-- @string action
--   play_phrase
-- @tab keys
--   (Optional) See @{03-Sequences.md.Capturing_user_key_input}.
-- @string language
--   (Optional) Language to play the phrase in. Defaults to the language set on
--   the channel or the default global language.
-- @string phrase
--   The name of the phrase macro to play.
-- @string phrase_arguments
--   (Optional) Arguments to pass to the phrase macro, if any.
-- @int repetitions
--   (Optional) How many times to repeat the file(s). Default is 1.
-- @int wait
--   (Optional) How long to wait between repetitions, in milliseconds. Default
--   is no wait.
-- @usage
--   {
--     action = "play",
--     keys = profile.play_keys,
--     language = "en",
--     phrase = "some_phrase",
--     phrase_arguments = "arg1,arg2,arg3",
--     repititions = 3,
--     wait = 2000,
--   }


--- From a list of files, play the first valid file found.
--
-- This action checks a list of files in order, and plays the first valid file
-- it finds from the list. Useful for playing a custom file, but falling back
-- to default file. Note that for speed, only basic file existence is checked
-- -- the file must be readable by the FreeSWITCH user.
--
-- @action play_valid_file
-- @string action
--   play\_valid\_file
-- @tab files
--   A table of resources to check for possible playback on the channel. Values
--   in the table should be:
--     1. Full file paths
--     2. Relative file paths from the FreeSWITCH 'sounds' directory
--     3. A phrase prefixed with 'phrase:' (note that this will always be
--        considered a valid file)
--
--   List the files in the order you would prefer them to be searched.
-- @tab keys
--   (Optional) See @{03-Sequences.md.Capturing_user_key_input}.
-- @int repetitions
--   (Optional) How many times to repeat the file(s). Default is 1.
-- @int wait
--   (Optional) How long to wait between repetitions, in milliseconds. Default
--   is no wait.
-- @string handler
--   The handler to use, see [handlers](#Handlers). If not specified, defaults
--   to the default handler for the module.
-- @usage
--   {
--     action = "play_valid_file",
--     files = {
--       "/tmp/customgreeting.wav",
--       "standardgreeting.wav",
--       "phrase:invalid_entry",
--     },
--     keys = profile.play_keys,
--     repititions = 3,
--     wait = 2000,
--   }


local core = require "jester.core"

local _M = {}

--[[
  Wait a specified time.
]]
local function wait(action)
  -- Don't wait if the call is hung up, or if a key was pressed.
  if action.wait and not core.actionable_key() and core.ready() then
    core.wait(action.wait)
  end
end

--[[
  Calculate the number of repetitions.
]]
local function reps(action)
  return action.repetitions and tonumber(action.repetitions) or 1
end

--[[
  Play one or more files.
]]
function _M.play_file(action)
  if action.file then
    -- A list of files was passed, join them in order.
    if type(action.file) == "table" then
      local delimiter = core.conf.playback_delimiter or "&"
      -- Ensure this channel variable is properly set, or playback of multiple
      -- files will not work.
      core.set_variable("playback_delimiter", delimiter)
      action.file = table.concat(action.file, delimiter)
    end
    local rep = reps(action)
    for i = 1, rep do
      core.debug_log("Streaming file '%s'", action.file)
      -- Break out of the loop if an actionable key was pressed.
      if not core.ready() or core.actionable_key() then return end
      session:streamFile(action.file)
      wait(action)
    end
  end
end

--[[
  Play the first valid file in a list of files.
]]
function _M.play_valid_file(action)
  local files = action.files
  if type(files) == "table" then
    require "lfs"
    local success, file_error, filepath
    for _, file in ipairs(files) do
      if file:sub(1, 1) ~= "/" then
        -- Look for phrases and handle them properly.
        if file:sub(1, 7) == "phrase:" then
          filepath = file
          success = true
        -- Relative path, appends the sounds_dir value.
        else
          filepath = core.conf.sounds_dir .. "/" .. file
        end
      else
        -- Absolute path.
        filepath = file
      end
      -- Check for file existence.
      if not success then
        success, file_error = lfs.attributes(filepath, "mode")
      end
      -- Play the file if it exists.
      if success then
        core.debug_log("Found valid file to play: %s", file)
        -- Store the name of the valid file found.
        core.set_storage("play", "valid_file_played", file)
        action.file = file
        return _M.play_file(action)
      end
    end
  end
  -- No valid file found, make sure to clear out this value from any previous
  -- attempts.
  core.debug_log("No valid file found to play.")
  core.set_storage("play", "valid_file_played", "")
end

--[[
  Play a phrase macro.
]]
function _M.play_phrase_macro(action)
  if action.phrase then
    local phrase_arguments = action.phrase_arguments or ""
    local rep = reps(action)
    for i = 1, rep do
      core.debug_log("Playing phrase '%s' with arguments '%s', language: %s", action.phrase, phrase_arguments, tostring(action.language))
      -- Break out of the loop if an actionable key was pressed.
      if not core.ready() or core.actionable_key() then return end
      if action.language then
        session:sayPhrase(action.phrase, phrase_arguments, action.language)
      else
        session:sayPhrase(action.phrase, phrase_arguments)
      end
      wait(action)
    end
  end
end

--[[
  Play a series of phrase macros that are mapped to keys.
]]
function _M.play_key_macros(action)
  local macros = action.key_announcements
  if macros then
    -- Allow the action to override the default key order.
    local order = action.order or core.conf.key_order
    local language = action.language or "en"
    local rep = reps(action)
    for i = 1, rep do
      core.debug_log("Announcing keys, repetition %d", i)
      for _, key in ipairs(order) do
        -- Break out of the loop if an actionable key was pressed.
        if not core.ready() or core.actionable_key() then return end
        if macros[key] then
          core.debug_log("Playing key phrase '%s' with key '%s'", macros[key], key)
          session:sayPhrase(macros[key], key, language)
        end
      end
      wait(action)
    end
  end
end

return _M
