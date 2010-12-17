jester.help.play = {}
jester.help.play.description_short = [[Play sounds on a channel.]]
jester.help.play.description_long = [[This module provides actions for playing various sounds on a channel.  The handlers for this module operate on the following actions:

  play
  play_valid_file]]
jester.help.play.handlers = {
  file = [[The default handler for the file module, operates on files on the local filesystem.]],
}

jester.help.play.actions = {}

jester.help.play.actions.play = {}
jester.help.play.actions.play.description_short = [[Play something on the channel.]]
jester.help.play.actions.play.description_long = [[This action plays sound on the channel.]]
jester.help.play.actions.play.params = {
  file = [[The name of the resource to play. It should be:
  1. A full file path
  2. A relative file path from the FreeSWITCH 'sounds' directory
  3. A phrase prefixed with 'phrase:', eg, 'phrase:invalid_sound'.
  
To play several files together in a group, pass a table of names instead, eg. 'file = { "foo", "bar", "phrase:goodbye" }'.]],
  repetitions = [[How many times to repeat the file(s).]],
  wait = [[How long to wait between repetitions, in milliseconds.]],
  keys = [[See 'help keys'.]],
}

jester.help.play.actions.play_phrase = {}
jester.help.play.actions.play_phrase.description_short = [[Play a phrase macro.]]
jester.help.play.actions.play_phrase.description_long = [[This action plays a FreeSWITCH phrase macro on the channel.]]
jester.help.play.actions.play_phrase.params = {
  phrase = [[The name of the phrase macro to play.]],
  phrase_arguments = [[(Optional) Arguments to pass to the phrase macro, if any.]],
  language = [[(Optional) Language to play the phrase in.  Defaults to the language set on the channel or the default global language.]],
  repetitions = [[How many times to repeat the phrase.]],
  wait = [[How long to wait between repetitions, in milliseconds.]],
  keys = [[See 'help keys'.]],
}

jester.help.play.actions.play_keys = {}
jester.help.play.actions.play_keys.description_short = [[Play a series of key press choices on the channel.]]
jester.help.play.actions.play_keys.description_long = [[This action allows you to map key press choices to announcements about what each key press will do, and play these announcements in a set order on the channel.

Keys are mapped both to actions, and to phrases in the FreeSWITCH phrase engine.  The phrases receive the mapped key as an argument.

You use this alongside of the standard 'keys' parameter to provide 'Press 1 for this, press 2 for that' menu selections.

The mapping is a standard table similar to the 'keys' table, with the value for each key being the name of a FreeSWITCH phrase macro to play for the key announcement:

  key_announcements = {
    ["4"] = "play_previous",
    ["5"] = "play_repeat",
    ["6"] = "play_next",
    ["7"] = "delete_message",
    ["8"] = "forward_message_to_email",
    ["9"] = "save_message",
    ["#"] = "exit",
  },

The order that the announcements are made can be customized, if no custom order is provided, then the default order from the profile or from the global configuration is used.]]
jester.help.play.actions.play_keys.params = {
  repetitions = [[How many times to repeat the key announcements.]],
  wait = [[How long to wait between repetitions, in milliseconds.]],
  order = [[A table of keys representing the order to play the announcements in.  For example, to play the announcements for the 3 key, then the 2 key, then the 1 key: order = {"3", "2", "1"}]],
  key_announcements = [[Described above.]],
  keys = [[See 'help keys'.]],
}

jester.help.play.actions.play_valid_file = {}
jester.help.play.actions.play_valid_file.description_short = [[From a list of files, play the first valid file found.]]
jester.help.play.actions.play_valid_file.description_long = [[This action checks a list of files in order, and plays the first valid file it finds from the list.  Useful for playing a custom file, but falling back to default file.  Note that for speed, only basic file existence is checked -- the file must be readable by the FreeSWITCH user.]]
jester.help.play.actions.play_valid_file.params = {
  files = [[A table of resources to check for possible playback on the channel. Values in the table should be:
  1. Full file paths
  2. Relative file paths from the FreeSWITCH 'sounds' directory
  3. A phrase prefixed with 'phrase:', eg, 'phrase:invalid_sound' (note that this will always be considered a valid file)
  
List the files in the order you would prefer them to be searched, eg. 'file = { "mycustomgreeting", "phrase:invalid_entry" }'.]],
  repetitions = [[How many times to repeat the file(s).]],
  wait = [[How long to wait between repetitions, in milliseconds.]],
  keys = [[See 'help keys'.]],
}

