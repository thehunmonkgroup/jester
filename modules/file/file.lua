module(..., package.seeall)

function get_filepath(file)
  if file:sub(1, 1) ~= "/" then
    file = jester.conf.base_dir .. "/" .. file
  end
  return file
end

function create_directory(action)
  local directory = action.directory
  if directory then
    local success, file_error
    require "lfs"
    local path = get_filepath(directory)
    success, file_error = lfs.attributes(path, "mode")
    if success then
      jester.debug_log("Directory '%s' already exists, skipping creation.", path)
    else
      success, file_error = lfs.mkdir(path)
      if success then
        jester.debug_log("Created directory '%s'", path)
      else
        jester.debug_log("Failed to create directory '%s'!: %s", path, file_error)
      end
    end
  else
    jester.debug_log("Cannot create directory, no 'path' parameter defined!")
  end
end

function remove_directory(action)
  local directory = action.directory
  if directory then
    local success, file_error
    require "lfs"
    local path = get_filepath(directory)
    success, file_error = lfs.attributes(path, "mode")
    if success then
      success, file_error = lfs.rmdir(path)
      if success then
        jester.debug_log("Deleted directory '%s'", path)
      else
        jester.debug_log("Failed to delete directory '%s'!: %s", path, file_error)
      end
    else
      jester.debug_log("Directory '%s' does not exist, skipping removal.", path)
    end
  else
    jester.debug_log("Cannot delete directory, no 'path' parameter defined!")
  end
end

function move_file(action)
  local operation = action.copy and "copy" or "move"
  local binary = action.binary and "b" or ""
  if action.source and action.destination then
    local success, file_error
    local source_file = get_filepath(action.source)
    local destination_file = get_filepath(action.destination)
    if operation == "move" then
      success, file_error = os.rename(source_file, destination_file)
    else
      local source, file_error = io.open(source_file, "r" .. binary)
      if source then
        local destination, file_error = io.open(destination_file, "w" .. binary)
        if destination then
          success = destination:write(source:read("*all"))
          destination:close()
        end
        source:close()
      end
    end
    if success then
      jester.debug_log("Successful file %s from '%s' to '%s'", operation, source_file, destination_file)
    else
      jester.debug_log("Failed file %s from '%s' to '%s'!: %s", operation, source_file, destination_file, file_error)
    end
  else
    jester.debug_log("Cannot perform file %s, missing parameter! Source: %s, Destination: %s", operation, tostring(action.source), tostring(action.destination))
  end
end

function delete_file(action)
  if action.file then
    local file = get_filepath(action.file)
    local success, file_error = os.remove(file)
    if success then
      jester.debug_log("Deleted file '%s'", file)
    else
      jester.debug_log("Failed to delete file '%s'!: %s", file, file_error)
    end
  else
    jester.debug_log("Cannot delete file, no 'file' parameter defined!")
  end
end

function file_exists(action)
  local result, file
  if action.file then
    require "lfs"
    file = get_filepath(action.file)
    local success, file_error = lfs.attributes(file, "mode")
    if success then
      result = "true"
    else
      result = "false"
    end
  else
    result = ""
  end
  jester.set_storage("file", "file_exists", result)
  if result == "false" then
    jester.debug_log("File '%s' does not exist", file)
    if action.if_false then
      jester.run_sequence(action.if_false)
    end
  elseif result == "true" then
    jester.debug_log("File '%s' exists", file)
    if action.if_true then
      jester.run_sequence(action.if_true)
    end
  else
    jester.debug_log("Cannot check file, no 'file' parameter defined!")
  end
end

