jester.help_map.log = {}
jester.help_map.log.description_short = [[Custom logger for sequences.]]
jester.help_map.log.description_long = [[This module provides custom logging functionality for sequences.  It can be used to log data somewhere from within a sequence.]]
jester.help_map.log.handlers = {
  console = [[Logs to the FreeSWITCH console.]],
  file = [[Logs to a file on the local filesystem.]],
}

jester.help_map.log.actions = {}

jester.help_map.log.actions.log = {}
jester.help_map.log.actions.log.description_short = [[Log a custom message.]]
jester.help_map.log.actions.log.description_long = [[Logs a custom message, with a custom level.]]
jester.help_map.log.actions.log.params = {
  message = [[The message to log.]],
  level = [[(Optional) The log level of the message. This value will vary depending on the handler.  Default is 'info'.]],
  file = [[(Optional) Required only for handlers that log to a file.  Provide a full path to the file.  Default is '/tmp/jester.log'.]],
}

