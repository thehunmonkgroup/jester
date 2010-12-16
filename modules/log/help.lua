jester.help_map.log = {}
jester.help_map.log.description_short = [[Custom logger for sequences.]]
jester.help_map.log.description_long = [[This module provides custom logging functionality for sequences.  It can be used to log data somewhere from within a sequence.]]
jester.help_map.log.handlers = {
  console = [[Logs to the FreeSWITCH console.]],
}

jester.help_map.log.actions = {}

jester.help_map.log.actions.log = {}
jester.help_map.log.actions.log.description_short = [[Log a custom message.]]
jester.help_map.log.actions.log.description_long = [[Logs a custom message, with a custom level.]]
jester.help_map.log.actions.log.params = {
  message = [[The message to log.]],
  level = [[The log level of the message. This value will vary depending on the handler.]],
}

