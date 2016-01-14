--- Send emails from Jester.
--
-- This module provides email functionality from within Jester. Support for
-- attachments is included.
--
-- @module email
-- @author Chad Phillips
-- @copyright 2011-2015 Chad Phillips


--- The socket handler (default).
--
-- Socket-based email using LuaSocket. This is the default handler.
--
-- @handler socket
-- @usage
--   {
--     action = "email",
--     handler = "socket",
--     -- other params...
--   }


--- Email a custom message.
--
-- Emails a custom message, with optional attachments. Tokens are supported
-- where noted -- tokens are inserted by prefixing the token name with a colon,
-- eg. ':mailbox' would be substituted with the 'mailbox' token value, if it
-- exists.
--
-- The email action uses a template system for composing emails. You can create
-- as many templates as you wish, and specify which template is to be used at
-- the time of sending.
--
-- @action email
-- @string action
--   email
-- @tab attachments
--   (Optional) A list of attachments to send. Each item in the list is a
--   table with the following key/value pairs:
--
--     filetype:
--       The MIME type of the file.
--     filename:
--       Name of the file.
--     description:
--       (Optional) File description.
--     filepath:
--       Full path to the file.
--
-- @tab email_templates
--   (Optional) A table of email templates to use. Keys are template names,
--   values are a table of template information with the following key/value
--   pairs:
--
--     subject:
--       (Optional) The message subject. Tokens are supported.
--     message:
--       (Optional) The message to email. Tokens are supported.
--     allow_attachments:
--       (Optional) Boolean to control if attachments can be sent using this
--       template. Set to false to disable sending attachments even if they
--       exist. Default is true, allow sending.
--
--   If this parameter is not provided, the action will look in the profile
--   settings for an 'email_templates' table to use instead. The templates must
--   either be defined in this parameter or the profile parameter!
-- @string from
--   (Optional) The address to send the email from. Defaults to
--   'noreply@[hostname]'.
-- @tab headers
--   (Optional) A table of email headers, key = header name, value = header
--   description. Note that some email headers will need to use the full table
--   key syntax.
-- @int port
--   (Optional) The port to use to send the message. Defaults to 25.
-- @string server
--   (Optional) The server to use to send the message. Defaults to 'localhost'.
-- @tab template
--   List of template names to use for sending. Templates should be listed in
--   the order that they should be used with the addresses in the 'to'
--   parameter -- ie, the first listed template is used for the first listed
--   address, etc. Can be either a table or a comma separated list. If no
--   template name is provided for the address, the action will fall back to
--   the template named 'default'.
-- @tab to
--   List of addresses to send to. Can be either a table or a comma separated
--   list.
-- @tab tokens
--   (Optional) A table of token replacements to apply, key = token name, value
--   = token replacement, eg. <code>tokens = {foo = "bar"}</code> would replace
--   the token ':foo' with 'bar' in the message. All token replacements are
--   searched for in all areas that support tokens.
-- @string handler
--   The handler to use, see [handlers](#Handlers). If not specified, defaults
--   to the default handler for the module.
-- @usage
--   {
--     action = "email",
--     attachments = {
--       {
--         filetype = "audio/x-wav",
--         filename = "word.wav",
--         description = "your word of the day",
--         filepath = profile.temp_recording_dir .. "/word.wav",
--       },
--     },
--     email_templates = {
--       custom = {
--         subject = "Hi, :name",
--         message = "Your word of the day is :word",
--         allow_attachments = true,
--       },
--     },
--     from = "mail@example.com",
--     headers = {
--       ["Reply-To"] = "baz@example.com",
--     },
--     port = 25,
--     server = 'localhost',
--     template = {
--       "default",
--       "custom",
--     },
--     to = {
--       "foo@example.com",
--       "bar@example.com",
--     },
--     tokens = {
--       name = "Bob",
--       word = "cucumber",
--     },
--   },


local core = require "jester.core"

local _M = {}

--[[
  Sends emails with optional attachments.
]]
function _M.send_email_socket(action)
  -- Load the smtp support and its friends.
  local smtp = require("socket.smtp")
  local mime = require("mime")
  local ltn12 = require("ltn12")

  require "jester.support.string"

  local to = action.to
  local template = action.template
  local email_templates = action.email_templates or core.profile.email_templates
  local from
  if action.from then
    from = "<" .. action.from .. ">"
  else
    from = "<noreply@" .. core.get_variable("hostname") .. ">"
  end
  local tokens = action.tokens
  local attachments = action.attachments
  local headers = action.headers or {}
  local server = action.server or "localhost"
  local port = action.port and tonumber(action.port) or 25

  -- Make sure we have templates and a recipient list before trying to send.
  if email_templates and to and to ~= "" then
    -- Transform the recipient list and template list into tables if necessary.
    if type(to) == "string" then
      to = string.split(to, ",")
    end
    if template and template ~= "" then
      if type(template) == "string" then
        template = string.split(template, ",")
      end
    else
      template = {}
    end

    local subject, message, recipient, t
    local allow_attachments, body, constructed_body
    local source, result, error_message

    -- Loop through the recipient emails.
    for k, v in ipairs(to) do
      -- Look for matching template, fall back to default.
      t = email_templates.default
      if template[k] then
        t = email_templates[template[k]] or email_templates.default
      end

      if t then
        headers.To = headers.To or v
        recipient = "<" .. v .. ">"
        subject = t.subject
        message = t.message or ""
        if t.allow_attachments == false then
          allow_attachments = false
        else
          allow_attachments = true
        end

        -- Token replacements.
        if tokens then
          if subject then
            subject = string.token_replace(subject, tokens)
          end
          message = string.token_replace(message, tokens)
        end

        -- Put subject in headers.
        if subject then
          headers.Subject = subject
        end

        -- Main body.
        constructed_body = {
          {
            -- Ensure a carriage return at the end of the main body.
            body = mime.eol(0, message .. "\n"),
          },
        }

        -- Attachments exist, so process them.
        if attachments and allow_attachments then
          local next_attachment
          for index, attachment in ipairs(attachments)
          do
            next_attachment = {
              headers = {
                ["Content-Type"] = attachment.filetype .. '; name="' .. attachment.filename .. '"',
                ["Content-Disposition"] = 'attachment; filename="' .. attachment.filename .. '"',
                ["Content-Description"] = attachment.description or "",
                ["Content-Transfer-Encoding"] = "BASE64",
              },
              body = ltn12.source.chain(
                ltn12.source.file(io.open(attachment.filepath, "rb")),
                ltn12.filter.chain(mime.encode("base64"), mime.wrap())
              )
            }
            table.insert(constructed_body, next_attachment)
          end
        end


        source = smtp.message(
          {
            headers = headers,
            body = constructed_body,
          }
        )

        -- Finally send it.
        core.debug_dump(recipient)
        result, error_message = smtp.send(
          {
            from = from,
            rcpt = recipient,
            source = source,
            server = server,
            port = port,
          }
        )

        if error_message then
          core.debug_log("Mail error: " .. tostring(error_message))
        else
          core.debug_log("Sent email from '%s' to '%s', subject '%s', server '%s', port '%s'", from, recipient, tostring(subject), server, port)
        end
      else
        core.debug_log("Mail send error, missing template: " .. tostring(template[k] or "default"))
      end
    end
  end
end

return _M
