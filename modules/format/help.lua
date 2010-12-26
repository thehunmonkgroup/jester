jester.help_map.format = {}
jester.help_map.format.description_short = [[Custom logger for sequences.]]
jester.help_map.format.description_long = [[This module provides custom logging functionality for sequences.  It can be used to log data somewhere from within a sequence.]]

jester.help_map.format.actions = {}

jester.help_map.format.actions.format_number = {}
jester.help_map.format.actions.format_number.description_short = [[Formats a number using a given mask.]]
jester.help_map.format.actions.format_number.description_long = [[This action formats a number using a given mask.  The mask can be used to exclude specific digits, and to add additional formatting around a long string of numbers.  A specific use case is formatting the number '+15555551212' into the more readable '(555) 555-1212'.  The formatted result is placed in the 'format' storage area.]]
jester.help_map.format.actions.format_number.params = {
  number = [[The number to format.]],
  mask = [[(Optional) The mask to apply to the number.  Default is to do no formatting.  The mask has two special placeholder characters, the exclamation point and the underscore.  To ignore a number, use the exclamation point.  To place a number, use the underscore.  For example, to format the number '+15555551212' to '(555) 555-1212', you would use the mask '!!(___) ___-____'.]],
  storage_key = [[(Optional) The key to store the formatted result under in the 'format' storage area.  Default is 'number'.]],
}

jester.help_map.format.actions.format_date = {}
jester.help_map.format.actions.format_date.description_short = [[Formats a Unix timestamp as a date string.]]
jester.help_map.format.actions.format_date.description_long = [[This action formats a Unix timestamp to a date string.  The format string is configurable, and timezones are supported.  The formatted result is placed in the 'format' storage area.]]
jester.help_map.format.actions.format_date.params = {
  timestamp = [[The Unix timestamp to format.]],
  timezone = [[(Optional) The timezone to use to calculate the time.  This should be a string as found in /usr/share/zoneinfo, eg. 'America/New_York'.  Default is 'UTC'.]],
  format = [[(Optional) The format string to use.  Should be a string in the form taken by strftime.  Default is '%Y-%m-%d %H:%M:%S'.]],
  storage_key = [[(Optional) The key to store the formatted result under in the 'format' storage area.  Default is 'date'.]],
}

