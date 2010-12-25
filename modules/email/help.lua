jester.help_map.email = {}
jester.help_map.email.description_short = [[Send emails from Jester.]]
jester.help_map.email.description_long = [[This module provides email functionality from within Jester.  Support for attachments is included.]]
jester.help_map.email.handlers = {
  socket = [[Socket-based email using LuaSocket.  This is the default handler.]],
}

jester.help_map.email.actions = {}

jester.help_map.email.actions.email = {}
jester.help_map.email.actions.email.description_short = [[Email a custom message.]]
jester.help_map.email.actions.email.description_long = [[Emails a custom message, with optional attachments.  Tokens are supported where noted -- tokens are inserted by prefixing the token name with a colon, eg. ':mailbox' would be substituted with the 'mailbox' token, if it exists.]]
jester.help_map.email.actions.email.params = {
  subject = [[The message subject.  Tokens are supported.]],
  message = [[(Optional) The message to email.  Tokens are supported.]],
}

