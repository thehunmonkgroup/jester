jester.help_map.email = {}
jester.help_map.email.description_short = [[Send emails from Jester.]]
jester.help_map.email.description_long = [[This module provides email functionality from within Jester.  Support for attachments is included.]]
jester.help_map.email.handlers = {
  socket = [[Socket-based email using LuaSocket.  This is the default handler.]],
}

jester.help_map.email.actions = {}

jester.help_map.email.actions.email = {}
jester.help_map.email.actions.email.description_short = [[Email a custom message.]]
jester.help_map.email.actions.email.description_long = [[Emails a custom message, with optional attachments.  Tokens are supported where noted -- tokens are inserted by prefixing the token name with a colon, eg. ':mailbox' would be substituted with the 'mailbox' token value, if it exists.

The email action uses a template system for composing emails.  You can create as many templates as you wish, and specify which template is to be used at the time of sending.]]
jester.help_map.email.actions.email.params = {
  to = [[List of addresses to send to.  Can be either a table, eg. 'to = {"foo@example.com", "bar@example.com"}', or a comma separated list, eg. 'to = "foo@example.com, bar@example.com"'.]],
  template = [[List of template names to use.  Templates should be listed in the order that they should be used with the addresses in the 'to' parameter -- ie, the first listed template is used for the first listed address, etc.  Can be either a table, eg. 'template = {"default", "notification"}', or a comma separated list, eg. 'to = "default, notification"'.]],
  email_templates = [[(Optional) A table of email templates to use.  Keys are template names, values are a table of template information with the following key/value pairs:

  subject:
    (Optional) The message subject.  Tokens are supported.
  message:
    (Optional) The message to email.  Tokens are supported.
  allow_attachments:
    (Optional) Boolean to control if attachments can be sent using this template.  Set to false to disable sending attachments even if they exist.  Default is true, allow sending.

If this parameter is not provided, the action will look in the profile settings for an 'email_template' table to use instead.  The templates must either be defined in this parameter or the profile parameter!]],
  from = [[(Optional) The address to send the email from.  Defaults to 'noreply@[hostname]'.]],
  tokens = [[(Optional) A table of token replacements to apply, key = token name, value = token replacement, eg. 'tokens = {foo = "bar"}' would replace the token ':foo' with 'bar'.  All token replacements are searched for in all areas that support tokens.]],
  attachments = [[(Optional) A table of attachments to send.  Each item in the table is a table with the following key/value pairs:
  filetype: The MIME type of the file, ex: audio/x-wav
  filename: Name of the file
  description: (Optional) File description.
  filepath: Full path to the file.]],
  headers = [[(Optional) A table of email headers, key = header name, value = header description.  Note that some email headers will need to use the full table key syntax, eg. 'headers = {["Reply-To"] = "foo@example.com"}'.]],
  server = [[(Optional) The server to use to send the message.  Defaults to 'localhost'.]],
  port = [[(Optional) The port to use to send the message.  Defaults to '25'.]],
}

