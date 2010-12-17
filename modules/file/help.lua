jester.help.file = {}
jester.help.file.description_short = [[Simple file operations.]]
jester.help.file.description_long = [[This module provides actions to handle simple filesystem operations.]]
jester.help.file.handlers = {} 
jester.help.file.handlers.filesystem = [[The default handler for the file module.  This handles file operations on the local filesystem.]]

jester.help.file.actions = {}

jester.help.file.actions.create_directory = {}
jester.help.file.actions.create_directory.description_short = [[Creates a directory.]]
jester.help.file.actions.create_directory.description_long = [[This action creates a directory on the filesystem in the specified location.]]
jester.help.file.actions.create_directory.params = {
  directory = [[The directory to create, including the path. Provide either the full path or a relative path from the FreeSWITCH base_dir global variable, eg. 'path = "/tmp/mynewdir"' or 'path = "storage/mynewdir"'.]],
}

jester.help.file.actions.remove_directory = {}
jester.help.file.actions.remove_directory.description_short = [[Removes a directory.]]
jester.help.file.actions.remove_directory.description_long = [[This action removes a directory from the filesystem in the specified location.]]
jester.help.file.actions.remove_directory.params = {
  directory = [[The directory to remove, including the path. Provide either the full path or a relative path from the FreeSWITCH base_dir global variable, eg. 'path = "/tmp/mynewdir"' or 'path = "storage/mynewdir"'.]],
}

jester.help.file.actions.move_file = {}
jester.help.file.actions.move_file.description_short = [[Move a file from one location to another.]]
jester.help.file.actions.move_file.description_long = [[This action moves a file from one location on the filesystem to another.]]
jester.help.file.actions.move_file.params = {
  source = [[The file to move, including the path. Provide either the full path or a relative path from the FreeSWITCH base_dir global variable, eg. 'source = "/tmp/myorginalfile.wav"' or 'source = "storage/myoriginalfile.wav"'.]],
  destination = [[The new destination of the file, including the path. Provide either the full path or a relative path from the FreeSWITCH base_dir global variable, eg. 'destination = "/tmp/mynewfile.wav"' or 'destination = "storage/mynewfile.wav"'.]],
  copy = [[To copy the file to the destination instead of moving it, set this to true, eg 'copy = true'.  Default is false.]],
  binary = [[Boolean, only neccesary for copying files.  Set to true if the source file is binary (sound files are typically binary).  Default is false.]],
}

jester.help.file.actions.delete_file = {}
jester.help.file.actions.delete_file.description_short = [[Delete a file.]]
jester.help.file.actions.delete_file.description_long = [[This action deletes a file from a location on the filesystem.]]
jester.help.file.actions.delete_file.params = {
  file = [[The file to delete, including the path. Provide either the full path or a relative path from the FreeSWITCH base_dir global variable, eg. 'file = "/tmp/myfile.wav"' or 'source = "storage/myfile.wav"'.]],
}

jester.help.file.actions.file_exists = {}
jester.help.file.actions.file_exists.description_short = [[Determines if a file exists in the filesystem.]]
jester.help.file.actions.file_exists.description_long = [[This action determines if a file exists on the filesystem.  This only checks for basic existence -- the file must be readable by the FreeSWITCH user.]]
jester.help.file.actions.file_exists.params = {
  file = [[The file to check, including the path. Provide either the full path or a relative path from the FreeSWITCH base_dir global variable, eg. 'file = "/tmp/myfile.wav"' or 'source = "storage/myfile.wav"'.]],
  if_true = [[(Optional) The sequence to call if the file exists.]],
  if_false = [[(Optional) The sequence to call if the file does not exist.]],
}

