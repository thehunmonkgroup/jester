jester.help_map.speech_to_text = {}
jester.help_map.speech_to_text.description_short = [[Speech to text translation.  WARNING: experimental.]]
jester.help_map.speech_to_text.description_long = [[This module provides speech to text translation.  WARNING: totally experimental, no guarantees it will work!

The module requires the Lua JSON package, more details at http://luaforge.net/projects/json]]
jester.help_map.speech_to_text.handlers = {
  google = [[Uses Google's Speech to Text service.]],
}

jester.help_map.speech_to_text.actions = {}

jester.help_map.speech_to_text.actions.speech_to_text_from_file = {}
jester.help_map.speech_to_text.actions.speech_to_text_from_file.description_short = [[Translates a sound file to text.]]
jester.help_map.speech_to_text.actions.speech_to_text_from_file.description_long = [[Translates a sound file to text.

Translations are stored in the specified storage area with the following keys, where X is the chunk number:
  translation_X: The translated text for the chunk.
  confidence_X: The confidence level of the translated chunk, a decimal number in the range of 0 to 1.

A 'status' key is also place in the storage area, indicating the result of the translation.  A value of 0 indicates the translation was successful.

This action requires that flac is installed and executable by FreeSWITCH.]]
jester.help_map.speech_to_text.actions.speech_to_text_from_file.params = {
  filepath = [[The full path to the file to translate.]],
  storage_area = [[(Optional) The storage area to store the response in.  Defaults to 'speech_to_text'.]],
}

