jester.help_map.file = {}
jester.help_map.file.description_short = [[Simple file operations.]]
jester.help_map.file.description_long = [[This module provides actions to handle simple filesystem operations.]]
jester.help_map.file.handlers = {}
jester.help_map.file.handlers.filesystem = [[The default handler for the file module.  This handles file operations on the local filesystem.]]

jester.help_map.file.actions = {}

jester.help_map.file.actions.create_directory = {}
jester.help_map.file.actions.create_directory.description_short = [[Creates a directory.]]
jester.help_map.file.actions.create_directory.description_long = [[This action creates a directory on the filesystem in the specified location.]]
jester.help_map.file.actions.create_directory.params = {
  directory = [[The directory to create, including the path. Provide either the full path or a relative path from the FreeSWITCH base_dir global variable, eg. 'path = "/tmp/mynewdir"' or 'path = "storage/mynewdir"'.]],
}

jester.help_map.file.actions.remove_directory = {}
jester.help_map.file.actions.remove_directory.description_short = [[Removes a directory.]]
jester.help_map.file.actions.remove_directory.description_long = [[This action removes a directory from the filesystem in the specified location.]]
jester.help_map.file.actions.remove_directory.params = {
  directory = [[The directory to remove, including the path. Provide either the full path or a relative path from the FreeSWITCH base_dir global variable, eg. 'path = "/tmp/mynewdir"' or 'path = "storage/mynewdir"'.]],
}

jester.help_map.file.actions.move_file = {}
jester.help_map.file.actions.move_file.description_short = [[Move a file from one location to another.]]
jester.help_map.file.actions.move_file.description_long = [[This action moves a file from one location on the filesystem to another.]]
jester.help_map.file.actions.move_file.params = {
  source = [[The file to move, including the path. Provide either the full path or a relative path from the FreeSWITCH base_dir global variable, eg. 'source = "/tmp/myorginalfile.wav"' or 'source = "storage/myoriginalfile.wav"'.]],
  destination = [[The new destination of the file, including the path. Provide either the full path or a relative path from the FreeSWITCH base_dir global variable, eg. 'destination = "/tmp/mynewfile.wav"' or 'destination = "storage/mynewfile.wav"'.]],
  copy = [[(Optional) To copy the file to the destination instead of moving it, set this to true, eg 'copy = true'.  Default is false.]],
  binary = [[(Optional) Boolean, only neccesary for copying files.  Set to true if the source file is binary (sound files are typically binary).  Default is false.]],
}

jester.help_map.file.actions.delete_file = {}
jester.help_map.file.actions.delete_file.description_short = [[Delete a file.]]
jester.help_map.file.actions.delete_file.description_long = [[This action deletes a file from a location on the filesystem.]]
jester.help_map.file.actions.delete_file.params = {
  file = [[The file to delete, including the path. Provide either the full path or a relative path from the FreeSWITCH base_dir global variable, eg. 'file = "/tmp/myfile.wav"' or 'source = "storage/myfile.wav"'.]],
}

jester.help_map.file.actions.file_exists = {}
jester.help_map.file.actions.file_exists.description_short = [[Determines if a file exists in the filesystem.]]
jester.help_map.file.actions.file_exists.description_long = [[This action determines if a file exists on the filesystem.  This only checks for basic existence -- the file must be readable by the FreeSWITCH user.

The action will store the result of its check in the 'file' storage area, key 'file_exists': 'true' if the file exists, 'false' otherwise.]]
jester.help_map.file.actions.file_exists.params = {
  file = [[The file to check, including the path. Provide either the full path or a relative path from the FreeSWITCH base_dir global variable, eg. 'file = "/tmp/myfile.wav"' or 'source = "storage/myfile.wav"'.]],
  if_true = [[(Optional) The sequence to call if the file exists.]],
  if_false = [[(Optional) The sequence to call if the file does not exist.]],
}

jester.help_map.file.actions.file_size = {}
jester.help_map.file.actions.file_size.description_short = [[Checks a file's size.]]
jester.help_map.file.actions.file_size.description_long = [[This action checks the size of a file. The result is stored in the 'file' storage area, key 'size']]
jester.help_map.file.actions.file_size.params = {
  file = [[The file to check, including the path. Provide either the full path or a relative path from the FreeSWITCH base_dir global variable, eg. 'file = "/tmp/myfile.wav"' or 'source = "storage/myfile.wav"'.]],
}
