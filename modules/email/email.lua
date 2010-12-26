module(..., package.seeall)

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
  local subject = action.subject
  local from
  if action.from then
    from = "<" .. action.from .. ">"
  else
    from = "<noreply@" .. jester.get_variable("hostname") .. ">"
  end
  local message = action.message or ""
  local tokens = action.tokens
  local attachments = action.attachments
  local headers = action.headers or {}
  local server = action.server or "localhost"
  local port = action.port and tonumber(action.port) or 25

  if to and to ~= "" then
    -- Format the recipient list.
    if type(to) == "string" then
      to = string.split(to, ",")
    end
    for k, v in ipairs(to) do
      to[k] = "<" .. v .. ">"
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
    local constructed_body = {
      {
        -- Ensure a carriage return at the end of the main body.
        body = mime.eol(0, message .. "\n"),
      },
    }

    -- Attachments exist, so process them.
    if attachments then
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

    local source = smtp.message(
      {
        headers = headers,
        body = constructed_body,
      }
    )

    -- Finally send it.
    local result, error_message = smtp.send(
      {
        from = from,
        rcpt = to,
        source = source,
        server = server,
        port = port,
      }
    )

    if error_message then
      jester.debug_log("Mail error: " .. tostring(error_message))
    else
      jester.debug_log("Sent email from '%s' to '%s', subject '%s', server '%s', port '%s'", from, table.concat(to, ", "), tostring(subject), server, port)
    end
  end
end

