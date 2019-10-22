local Fct_Tables = {
  _VERSION     = 'Dina GE Fct_Tables v1.2',
  _DESCRIPTION = 'Fct_Tables in Dina Game Engine',
  _URL         = 'https://dina.lacombedominique.com/documentation/functions/fct_tables/',
  _LICENSE     = [[
    ZLIB Licence

    Copyright (c) 2019 LACOMBE Dominique

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
  table.sort(Table, function(a,b) return ((a.GetZOrder and a:GetZOrder()) or 0) < ((b.GetZOrder and b:GetZOrder()) or 0) end)
end
