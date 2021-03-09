--[[
  Support functions for strings.
]]

--[[
  Trims whitespace from either end of a string.
]]
function string:trim()
  return (string.gsub(self, "^%s*(.-)%s*$", "%1"))
end

--[[
  Trims whitespace from either end of a string.
]]
function trim(s)
  return s:trim()
end

--[[
  Splits a string by a given delimter and returns a table of ordered pieces.
]]
function string:split(delimiter, notrim)
  local result = {}
  local from = 1
  local piece
  local delim_from, delim_to = string.find(self, delimiter, from)
  while delim_from do
    piece = string.sub(self, from , delim_from-1)
    if not notrim then
      piece = piece:trim()
    end
    table.insert(result, piece)
    from = delim_to + 1
    delim_from, delim_to = string.find(self, delimiter, from)
  end
  piece = string.sub(self, from)
  if not notrim then
    piece = piece:trim()
  end
  table.insert(result, piece)
  return result
end


--[[
  Provides word wrapping with variable boundary, respecting existing
  indentation, and allowing additional indentation to be added.
]]
function string:wrap(boundary, indent)
  local output = {}
  local index, words, leading_space, full_indent
  local indent = indent or ""
  local buffer = indent
  local lines = self:split("\n", true)

  for _, line in pairs(lines) do
    if line:match("^%s*$") then
      table.insert(output, "")
    else
      words = line:split(" ", true)
      leading_space = line:match("^(%s+)%S")
      if (#words > 0) then
        if leading_space then
          full_indent = leading_space .. indent
        else
          full_indent = indent
        end
        index = 1
        while words[index] do
          local word = " " .. words[index]
          if (buffer:len() >= boundary) then
            table.insert(output, buffer:sub(1, boundary))
            buffer = full_indent .. buffer:sub(boundary + 1)
          else
            if (word:len() > boundary) then
              table.insert(output, buffer)
              table.insert(output, full_indent .. word)
              buffer = indent
              index = index + 1
            elseif (buffer:len() + word:len() >= boundary) then
              table.insert(output, buffer)
              buffer = full_indent
            else
              if (buffer == full_indent) then
                buffer = full_indent .. word:sub(2)
              else
                buffer = buffer .. word
              end
              index = index + 1
            end
          end
        end
        if (buffer:match("%S")) then
            table.insert(output, buffer)
            buffer = indent
        end
      end
    end
  end
  return table.concat(output, "\n")
end

--[[
  Replaces tokens in a string with their token values.
]]
function string:token_replace(tokens)
  local substitutions
  local total = 0
  for token, replacement in pairs(tokens) do
    self, substitutions = self:gsub(":" .. token, replacement)
    total = total + substitutions
  end
  return self, total
end

