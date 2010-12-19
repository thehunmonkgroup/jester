jester.help_map.get_digits = {}
jester.help_map.get_digits.description_short = [[Collect user input from the channel.]]
jester.help_map.get_digits.description_long = [[This module provides actions for collecting user input from a channel, in the form of DTMF key presses.]]

jester.help_map.get_digits.actions = {}

jester.help_map.get_digits.actions.get_digits = {}
jester.help_map.get_digits.actions.get_digits.description_short = [[Collect user input from the channel.]]
jester.help_map.get_digits.actions.get_digits.description_long = [[This action collects user input from a channel, in the form of DTMF key presses, and stores the collected digits in the 'get_digits' storage area.  Note that if no user input is collected, or validation fails, an empty string is saved to the storage area instead.]]
jester.help_map.get_digits.actions.get_digits.params = {
  min_digits = [[(Optional) The minimum number of digits to collect.  Default is 1.]],
  max_digits = [[(Optional) The maximum number of digits to collect. Default is 10.]],
  max_tries = [[(Optional) The maximum amount of times that validation will fail before giving up.  Default is 3.]],
  timeout = [[(Optional) Number of seconds to wait for max_digits before trying to validate.  Default is 3.]],
  terminators = [[(Optional) A string of keys that the user can use to end the collection before the timeout.  Multiple values keys can be used, eg. '*' or '*#'.  To accept no terminators, pass an empty string.  Default is '#'.]],
  audio_files = [[A file or files to play to the user during collection.  Playback is terminated when the user enters the first key.  Usually used to give the user instructions on what to enter.  Provide either a single file as a string, or multiple files in a table, eg. 'audio_files = "/path/foo.wav"' or 'audio_files = { "/path/foo.wav", "/path/bar.wav" }'.  The default is to play nothing.]],
  bad_input = [[(Optional) An audio file to play to the user when input validation fails.  Default is 'ivr/ivr-that_was_an_invalid_entry.wav'.]],
  digits_regex = [[(Optional) A regular expression to use for validating the user input.  If the user input does not match the expression, then validation fails.  The regex is in the same form as the regular expressions used in the FreeSWITCH dialplan.  Default is '\\d+', which matches one or more digits.  Note: If you need to match the * key in the regex, you will have to escape it twice, as in '\\d+|\\*'.]],
  storage_key = [[(Optional) The key to store the collected digits under in the 'get_digits' storage area.  Default is 'digits'.]],
}

