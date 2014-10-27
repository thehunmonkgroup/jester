jester.help_map.speech_to_text = {}
jester.help_map.speech_to_text.description_short = [[Speech to text translation.  WARNING: experimental.]]
jester.help_map.speech_to_text.description_long = [[This module provides speech to text translation.  WARNING: totally experimental, no guarantees it will work!

The module requires the Lua lua-cjson and luasec packages, more details at http://luarocks.org/repositories/rocks]]
jester.help_map.speech_to_text.handlers = {
  -- Google changed things so their API is not longer generally accessible.
  -- google = [[Uses Google's Speech to Text service.]],
  att = [[Uses AT&T's Speech to Text service. The service requires a valid developer account and application key/secret, see https://developer.att.com/apis/speech for more information.]],
}

jester.help_map.speech_to_text.actions = {}

jester.help_map.speech_to_text.actions.speech_to_text_from_file = {}
jester.help_map.speech_to_text.actions.speech_to_text_from_file.description_short = [[Translates a sound file to text.]]
jester.help_map.speech_to_text.actions.speech_to_text_from_file.description_long = [[Translates a sound file to text.

Translations are stored in the specified storage area with the following keys, where X is the chunk number:
  translation_X: The translated text for the chunk.
  confidence_X: The confidence level of the translated chunk, a decimal number in the range of 0 to 1.

A 'status' key is also place in the storage area, indicating the result of the translation.  A value of 0 indicates the translation was successful.

This action requires that flac is installed and executable by FreeSWITCH, and that the lua-cjson package is installed and in the FreeSWITCH Lua path.]]
jester.help_map.speech_to_text.actions.speech_to_text_from_file.params = {
  filepath = [[The full path to the file to translate.]],
  storage_area = [[(Optional) The storage area to store the response in.  Defaults to 'speech_to_text'.]],
  app_key = [[(Optional) The application key used to access the service.]],
  app_secret = [[(Optional) The application secret used to access the service.]],
}

