--- Simple file operations.
--
-- This module provides actions to handle simple filesystem operations.
--
-- @module file
-- @author Chad Phillips
-- @copyright 2011-2015 Chad Phillips


--- The filesystem handler (default).
--
-- The default handler for the file module. This handles file operations on
-- the local filesystem.
--
-- @handler filesystem
-- @usage
--   {
--     action = "create_directory",
--     handler = "filesystem",
--     -- other params...
--   }


--- Creates a directory.
--
-- This action creates a directory on the filesystem in the specified location.
--
-- @action create_directory
-- @string action
--   create_directory
-- @string directory
--   The directory to create, including the path. Provide either the full path
--   or a relative path from the FreeSWITCH 'base_dir' global variable.
-- @string handler
--   The handler to use, see [handlers](#Handlers). If not specified, defaults
--   to the default handler for the module.
-- @usage
--   {
--     action = "create_directory",
--     directory = "/tmp/mynewdir",
--   }


--- Delete a file.
--
-- This action deletes a file from a location on the filesystem.
--
-- @action delete_file
-- @string action
--   delete_file
-- @string file
--   The file to delete, including the path. Provide either the full path or a
--   relative path from the FreeSWITCH 'base_dir' global variable.
-- @string handler
--   The handler to use, see [handlers](#Handlers). If not specified, defaults
--   to the default handler for the module.
-- @usage
--   {
--     action = "delete_file",
--     file = "/tmp/afile.txt",
--   }


--- Determines if a file exists in the filesystem.
--
-- This action determines if a file exists on the filesystem. This only checks
-- for basic existence -- the file must be readable by the FreeSWITCH user.
--
-- The action will store the result of its check in the 'file' storage area, key
-- 'file_exists': 'true' if the file exists, 'false' otherwise.
--
-- @action file_exists
-- @string action
--   file_exists
-- @string file
--   The file to check, including the path. Provide either the full path or a
--   relative path from the FreeSWITCH 'base_dir' global variable.
-- @string if_false
--   (Optional) The sequence to call if the file does not exist.
-- @string if_true
--   (Optional) The sequence to call if the file exists.
-- @string handler
--   The handler to use, see [handlers](#Handlers). If not specified, defaults
--   to the default handler for the module.
-- @usage
--   {
--     action = "file_exists",
--     file = "/tmp/afile.txt",
--     if_false = "do_this",
--     if_true = "do_that",
--   }


--- Checks a file's size.
--
-- This action checks the size of a file. The result is stored in the 'file'
-- storage area, key 'size'.
--
-- @action file_size
-- @string action
--   file_size
-- @string file
--   The file to check, including the path. Provide either the full path or a
--   relative path from the FreeSWITCH 'base_dir' global variable.
-- @string handler
--   The handler to use, see [handlers](#Handlers). If not specified, defaults
--   to the default handler for the module.
-- @usage
--   {
--     action = "file_size",
--     file = "/tmp/afile.txt",
--   }


--- Move a file from one location to another.
--
-- This action moves a file from one location on the filesystem to another.
--
-- @action move_file
-- @string action
--   move_file
-- @bool binary
--   (Optional) Boolean, only neccesary for copying files. Set to true if the
--   source file is binary (sound files are typically binary). Default is
--   false.
-- @bool copy
--   (Optional) To copy the file to the destination instead of moving it, set
--   this to true. Default is false.
-- @string destination
--   The new destination of the file, including the path. Provide either the
--   full path or a relative path from the FreeSWITCH 'base_dir' global variable.
-- @string source
--   The file to move, including the path. Provide either the full path or a
--   relative path from the FreeSWITCH 'base_dir' global variable.
-- @string handler
--   The handler to use, see [handlers](#Handlers). If not specified, defaults
--   to the default handler for the module.
-- @usage
--   {
--     action = "move_file",
--     binary = false,
--     copy = false,
--     destination = "storage/mymovedfile.txt",
--     source = "/tmp/originalfile.txt",
--   }


--- Removes a directory.
--
-- This action removes a directory from the filesystem in the specified
-- location.
--
-- @action remove_directory
-- @string action
--   remove_directory
-- @string directory
--   The directory to remove, including the path. Provide either the full path
--   or a relative path from the FreeSWITCH 'base_dir' global variable.
-- @string handler
--   The handler to use, see [handlers](#Handlers). If not specified, defaults
--   to the default handler for the module.
-- @usage
--   {
--     action = "remove_directory",
--     directory = "/tmp/somedir",
--   }


local core = require "jester.core"

local _M = {}

--[[
  Appends the freeswitch base_dir if a relative path is passed.
]]
local function get_filepath(file)
  -- Look for leading slash to indicate full path.
  if file:sub(1, 1) ~= "/" then
    file = core.conf.base_dir .. "/" .. file
  end
  return file
end

--[[
  Create a directory.
]]
function _M.create_directory(action)
  local directory = action.directory
  if directory then
    local success, file_error
    require "lfs"
    local path = get_filepath(directory)
    -- Look for existing directory.
    success, file_error = lfs.attributes(path, "mode")
    if success then
      core.log.debug("Directory '%s' already exists, skipping creation.", path)
    else
      -- Create new directory.
      success, file_error = lfs.mkdir(path)
      if success then
        core.log.debug("Created directory '%s'", path)
      else
        core.log.debug("Failed to create directory '%s'!: %s", path, file_error)
      end
    end
  else
    core.log.debug("Cannot create directory, no 'path' parameter defined!")
  end
end

--[[
  Remove a directory.
]]
function _M.remove_directory(action)
  local directory = action.directory
  if directory then
    local success, file_error
    require "lfs"
    local path = get_filepath(directory)
    -- Look for existing directory.
    success, file_error = lfs.attributes(path, "mode")
    if success then
      -- Remove directory.
      success, file_error = lfs.rmdir(path)
      if success then
        core.log.debug("Deleted directory '%s'", path)
      else
        core.log.debug("Failed to delete directory '%s'!: %s", path, file_error)
      end
    else
      core.log.debug("Directory '%s' does not exist, skipping removal.", path)
    end
  else
    core.log.debug("Cannot delete directory, no 'path' parameter defined!")
  end
end

--[[
  Move or copy a file.
]]
function _M.move_file(action)
  local operation = action.copy and "copy" or "move"
  local binary = action.binary and "b" or ""
  if action.source and action.destination then
    local success, file_error
    local source_file = get_filepath(action.source)
    local destination_file = get_filepath(action.destination)
    -- Move.
    if operation == "move" then
      success, file_error = os.rename(source_file, destination_file)
    -- Copy.
    else
      -- There is no copy function for files in Lua, so open the original,
      -- read it, and write the new one.
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
      core.log.debug("Successful file %s from '%s' to '%s'", operation, source_file, destination_file)
    else
      core.log.debug("Failed file %s from '%s' to '%s'!: %s", operation, source_file, destination_file, file_error)
    end
  else
    core.log.debug("Cannot perform file %s, missing parameter! Source: %s, Destination: %s", operation, tostring(action.source), tostring(action.destination))
  end
end

--[[
  Delete a file.
]]
function _M.delete_file(action)
  if action.file then
    local file = get_filepath(action.file)
    local success, file_error = os.remove(file)
    if success then
      core.log.debug("Deleted file '%s'", file)
    else
      core.log.debug("Failed to delete file '%s'!: %s", file, file_error)
    end
  else
    core.log.debug("Cannot delete file, no 'file' parameter defined!")
  end
end

--[[
  Check for file existence.
]]
function _M.file_exists(action)
  local result, file
  if action.file then
    require "lfs"
    file = get_filepath(action.file)
    -- If we can pull the file attributes, then the file exists.
    local success, file_error = lfs.attributes(file, "mode")
    if success then
      result = "true"
    else
      result = "false"
    end
  else
    result = ""
  end
  -- Store the result of the check.
  core.set_storage("file", "file_exists", result)
  if result == "false" then
    core.log.debug("File '%s' does not exist", file)
    -- Run false sequence if specified.
    if action.if_false then
      core.queue_sequence(action.if_false)
    end
  elseif result == "true" then
    core.log.debug("File '%s' exists", file)
    -- Run true sequence if specified.
    if action.if_true then
      core.queue_sequence(action.if_true)
    end
  else
    core.log.debug("Cannot check file, no 'file' parameter defined!")
  end
end

--[[
  Returns a file's size.
]]
function _M.file_size(action)
  local file, size
  if action.file then
    require "lfs"
    file = get_filepath(action.file)
    size = lfs.attributes(file, "size")
  end
  -- Store the result of the check.
  core.set_storage("file", "size", size)
end

return _M
