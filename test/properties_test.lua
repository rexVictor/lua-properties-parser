luaunit = require('luaunit')
parser = require('src.properties')

TestLoadProperties = {}
expectedTable = {}
expectedTable["easy"] = "start"
expectedTable["first"] = "multiline"
expectedTable["not"] = "a multi\\"
expectedTable["line"] = ""
expectedTable["cracy"] = "mul\\\\\\\\\\\\\\ine"
expectedTable["thiskey"] = "should be thiskey"
expectedTable["escape"] = "\\\\\\\\\\\\\raction\\"
expectedTable["new\nline"] = "in\r\nvarious\rforms"
expectedTable[":=\\"] = "ohyeah"
expectedTable["not#a"] = "c!omment"
expectedTable["flip"] = "╯°□°）╯︵ ┻━┻"
expectedTable["\"unescaped"] = "quote's"
expectedTable["\"orescaped"] = "one's"
expectedTable["\ttabitup"] = "\ffeedit down"
expectedTable["test"] = ""
expectedTable["some"] = ""
expectedTable["different"] = ""
expectedTable["newlines"] = ""
expectedTable["formfeed"] = "as whitespace"

local function sizeOf(t)
  local i = 0
  for key in pairs(t) do
    i = i + 1
  end
  return i
end

function TestLoadProperties:test_loadProperties() 
  local actualTable = parser.loadProperties('testresources/wtf.properties')
  assertEquals(sizeOf(actualTable), sizeOf(expectedTable))
  for key in pairs(actualTable) do
    assertEquals(actualTable[key], expectedTable[key])
  end
end

luaunit:run()
