module(..., package.seeall)

local core = require "jester.core"

--[[
  Sends emails with optional attachments.
]]
function send_email_socket(action)
  -- Load the smtp support and its friends.
  local smtp = require("socket.smtp")
  local mime = require("mime")
  local ltn12 = require("ltn12")

  require "jester.support.string"

  local to = action.to
  local template = action.template
  local email_templates = action.email_templates or jester.profile.email_templates
  local from
  if action.from then
    from = "<" .. action.from .. ">"
  else
    from = "<noreply@" .. jester.get_variable("hostname") .. ">"
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
          jester.debug_log("Mail error: " .. tostring(error_message))
        else
          jester.debug_log("Sent email from '%s' to '%s', subject '%s', server '%s', port '%s'", from, recipient, tostring(subject), server, port)
        end
      end
    end
  end
end

