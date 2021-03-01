local Table_Fcts = {
  _TITLE       = 'Dina Game Engine - Table Functions',
  _VERSION     = '2.0.3',
  _URL         = 'https://dina.lacombedominique.com/documentation/functions/tables/',
  _LICENSE     = [[
Copyright (c) 2020 LACOMBE Dominique
ZLIB Licence
This software is provided 'as-is', without any express or implied warranty. In no event will the authors be held liable for any damages arising from the use of this software.
Permission is granted to anyone to use this software for any purpose, including commercial applications, and to alter it and redistribute it freely, subject to the following restrictions:
    1. The origin of this software must not be misrepresented; you must not claim that you wrote the original software. If you use this software in a product, an acknowledgment in the product documentation would be appreciated but is not required.
    2. Altered source versions must be plainly marked as such, and must not be misrepresented as being the original software.
    3. This notice may not be removed or altered from any source distribution.
]]
}


--[[
proto SortTableByZOrder(Table)
.D This function sorts the table by the Z-Order value. If the Z-Order do not exist into the component, the function use the value 0.
.P Table
Table to sort by the Z-Order.
]]--
function SortTableByZOrder(Table)
  table.sort(Table, 
             function(a,b)
               a.zorderchanged = false
               b.zorderchanged = false
               return ((a.getZOrder and a:getZOrder()) or 0) < ((b.getZOrder and b:getZOrder()) or 0)
             end)
end

--[[
proto PrintTable(Table, offset)
.D <strong>DEBUG FUNCTION:</strong> This function print the content of a table. If the table has some attributes which are also tables, the function will print their content too.
.P Table
Table to print.
.P offset
Offset in order to display a tree.
]]--
function PrintTable(pTable, offset)
  offset = offset or 1
  local i = 1
  for key, value in pairs(pTable) do
    if type(value) == "table" then
      print(string.rep("| ", offset-1).."|-"..tostring(key))
      PrintTable(value, offset+1)
    else
      local str = string.rep("| ", offset-1)
      if i == #pTable then
        str = str..">-"
      else
        str = str.."|-"
      end
      str = str..tostring(key).."="..tostring(value)
      print(str)
      i = i + 1
    end
  end
end

function GetName(Item)
  return Item.__name
end