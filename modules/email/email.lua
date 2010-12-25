module(..., package.seeall)

--[[
  Formats a 10 digit phone number.
]]
function format_phone_number(number)
  if string.len(number) == 10 then
    number = "(" .. string.sub(number, 1, 3) .. ") " .. string.sub(number, 4, 6) .. "-" .. string.sub(number, 7)
  end
  return number
end

--[[
  Converts voicemail message data into the email sending format.
]]
function voicemail_to_email(voicemail_data)
  voicemail_number = format_phone_number(voicemail_data.mailbox)
  -- Fudge the UTC timestamp so other timezones get an accurate display
  -- of message time.
  adjusted_utc_timestamp = adjust_mountain_time(voicemail_data.message_timestamp, voicemail_data.tz)
  date_time = os.date("%A, %B %e, %Y at %I:%M %p", adjusted_utc_timestamp)
  caller_id_number = format_phone_number(voicemail_data.caller_id_number)
  email = {
    headers = {
      subject = "[Apartment Lines] New voicemail message for " .. voicemail_number,
    },
    to = voicemail_data.recipients,
    message = string.format([[
Mailbox number: %s
Date/time: %s
CallerID number: %s
CallerID name: %s
Message ID: %s

    ]], voicemail_number, date_time, caller_id_number, voicemail_data.caller_id_name, voicemail_data.message_id),
    attachments = {
      {
        filetype = "audio/x-wav",
        filename = "apartmentlines-message-" .. voicemail_data.message_id .. ".wav",
        filepath = voicemail_data.filepath
      }
    }
  }

  send_email(email)
end

--[[
  Sends emails with optional attachments. data is a table with the following
  key/value pairs:
    to: A table of addresses to send to, each addres in the form
        <user@example.com>
    from: Optional. Defaults to <noreply@[domain]>
    message: Main body of the email -- Quoted block w/ CRLF at the end.
    headers: A table of main email headers, key = header name,
             value = header description.
    attachments: Optional. A table of attachments to send.  Each item in
                 the table is a table with the following key/value pairs:
                    filetype: The MIME type of the file, ex: audio/x-wav
                    filename: Name of the file
                    description: Optional. File description.
                    filepath: Full path to the file.
]]

function send_email_socket(data)
  -- Load the smtp support and its friends.
  local smtp = require("socket.smtp")
  local mime = require("mime")
  local ltn12 = require("ltn12")
  local from
  if data.from then
    from = "<" .. data.from .. ">"
  else
    from = "noreply@" .. jester.get_variable("domain", "localdomain")
  end

  local constructed_body = { { body = mime.eol(0, data.message) } }

  -- Attachments exist, so process them.
  if data.attachments then
    local next_attachment
    for index, attachment in ipairs(data.attachments)
    do
      next_attachment = {
        headers = {
          ["Content-Type"] = attachment.filetype .. '; name="' .. attachment.filename .. '"',
          ["Content-Disposition"] = 'attachment; filename="' .. attachment.filename .. '"',
          ["Content-Description"] = attachment.description or "",
          ["Content-Transfer-Encoding"] = "BASE64"
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
      headers = data.headers,
      body = constructed_body
    }
  )

  -- Finally send it.
  local result, error = smtp.send(
    {
      from = from,
      rcpt = data.to,
      source = source,
    }
  )

  if error then
    jester.debug_log("Mail error: " .. tostring(error))
  end
end

