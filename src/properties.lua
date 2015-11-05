local P = {}

--imports
local rex = rex
local io = io
local assert = assert
local tonumber = tonumber
local utf8 = utf8
local table = table

_ENV = P

local function parse(logicalLine)
  local trimmed = logicalLine:gsub("^[\t\f ]*","")
  local delimiterPosition = nil
  for candidate in trimmed:gmatch"\\*[\t\f=: ]" do
    if #candidate % 2 == 1 then
      delimiterPosition = trimmed:find(candidate)
      delimiterPosition = delimiterPosition + #candidate - 1
    end
    if delimiterPosition then
      break
    end
  end
  if delimiterPosition then
    local delimiter = trimmed:sub(delimiterPosition, delimiterPosition)
    local key = trimmed:sub(0,delimiterPosition - 1)
    local value = nil
    if delimiter:find"^[\t\f ]$" then
      value = trimmed:gsub("^" .. key .. "[\t\f=: ]*", "")
    else
      value = trimmed:gsub("^" .. key .. delimiter .. "[\t\f ]*", "")
    end
    return key,value
  else
    return trimmed:gsub("[\r\n\t\f ]*$",""), ""
  end
end

local function concatMultiLines(line, iterator)
  local multLine = line
  local final = multLine:match"\\+$"
  while final do
    if #final % 2 == 1 then
      local nextLine = iterator()
      nextLine = nextLine:match"^%s*(.*)$"
      multLine = multLine:sub(0,#multLine-1) .. nextLine
      final = multLine:match"\\+$"
    else
      final = nil
    end
  end
  return multLine
end

local function unescape(str)
  local result = {}
  local iterator = str:gmatch"."
  local escaped = false
  local position = 1
  for char in iterator do
    local toAdd = nil
    if escaped then
      if char == "n" then
        toAdd = "\n"
      elseif char == "t" then
        toAdd = "\t"
      elseif char == "f" then
        toAdd = "\f"
      elseif char == "\\" then
        toAdd = "\\"
      elseif char == "r" then
        toAdd = "\r"
      elseif char == "u" then
        local first = iterator()
        local second = iterator()
        local third = iterator()
        local fourth = iterator()
        local codeString = first .. second .. third .. fourth
        toAdd = utf8.char(tonumber(codeString, 16))
      else
        toAdd = char
      end
      escaped = false
    elseif char == "\\" then
        escaped = true
    else
      toAdd = char
    end
    if toAdd then
      result[position] = toAdd
      position = position + 1
    end
  end
  return table.concat(result)
end

local function loadProperties(file)
  local result = {}
  local file = assert(io.open(file, "r"))
  local content = file:read"*a"
  local iterator = content:gmatch"[^\n\r]+"
  for line in iterator do
    if (line:find"^%s*[^#!%s]") then
      line = concatMultiLines(line, iterator)
      local key, value = parse(line)
      key = unescape(key)
      value = unescape(value)
      result[key] = value
    end
  end
  assert(file:close ())
  return result
end

P.loadProperties = loadProperties

return P
