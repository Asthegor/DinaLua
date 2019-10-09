local File = ...

local dialogues = {}
if type(File) == "table" then
  for _,value in pairs(File) do
    local data = require(value)
    table.insert(dialogues, data)
  end
else
  dialogues = require(File)
end
