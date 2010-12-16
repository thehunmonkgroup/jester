module(..., package.seeall)

function wait(action)
  if action.wait and not jester.actionable_key() and jester.ready() then
    jester.wait(action.wait)
  end
end

function reps(action)
  return action.repetitions and tonumber(action.repetitions) or 1
end

function play_file(action)
  if action.file then
    if type(action.file) == "table" then
      action.file = table.concat(action.file, "&")
    end
    local rep = reps(action)
    for i = 1, rep do
      jester.debug_log("Streaming file '%s'", action.file)
      -- Break out of the loop if an actionable key was pressed.
      if not jester.ready() or jester.actionable_key() then return end
      session:streamFile(action.file)
      wait(action)
    end
  end
end

function play_valid_file(action)
  local files = action.files
  if type(files) == "table" then
    require "lfs"
    local success, file_error, filepath
    for _, file in ipairs(files) do
      if file:sub(1, 1) ~= "/" then
        if file:sub(1, 7) == "phrase:" then
          filepath = file
          success = true
        else
          filepath = jester.conf.sounds_dir .. "/" .. file
        end
      else
        filepath = file
      end
      if not success then
        success, file_error = lfs.attributes(filepath, "mode")
      end
      if success then
        jester.debug_log("Found valid file to play: %s", file)
        -- Store the name of the valid file found.
        jester.set_storage("play", "valid_file_played", file)
        action.file = file
        return play_file(action)
      end
    end
  end
  -- No valid file found, make sure to clear out this value from any previous
  -- attempts.
  jester.debug_log("No valid file found to play.")
  jester.set_storage("play", "valid_file_played", "")
end

function play_phrase_macro(action)
  if action.phrase then
    local phrase_arguments = action.phrase_arguments or ""
    local rep = reps(action)
    for i = 1, rep do
      jester.debug_log("Playing phrase '%s' with arguments '%s', language: %s", action.phrase, phrase_arguments, tostring(action.language))
      -- Break out of the loop if an actionable key was pressed.
      if not jester.ready() or jester.actionable_key() then return end
      if action.language then
        session:sayPhrase(action.phrase, phrase_arguments, action.language)
      else
        session:sayPhrase(action.phrase, phrase_arguments)
      end
      wait(action)
    end
  end
end

function play_key_macros(action)
  local macros = action.key_announcements
  if macros then
    local order = action.order or jester.conf.key_order
    local language = action.language or "en"
    local rep = reps(action)
    for i = 1, rep do
      jester.debug_log("Announcing keys, repitition %d", i)
      for _, key in ipairs(order) do
        -- Break out of the loop if an actionable key was pressed.
        if not jester.ready() or jester.actionable_key() then return end
        if macros[key] then
          jester.debug_log("Playing key phrase '%s' with key '%s'", macros[key], key)
          session:sayPhrase(macros[key], key, language)
        end
      end
      wait(action)
    end
  end
end

