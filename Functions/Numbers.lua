local Fct_Numbers = {
  _TITLE       = 'Dina Game Engine - Numbers',
  _VERSION     = '1.1',
  _URL         = 'https://dina.lacombedominique.com/documentation/functions/numbers/',
  _LICENSE     = [[
Copyright (c) 2019 LACOMBE Dominique
ZLIB Licence
This software is provided 'as-is', without any express or implied warranty. In no event will the authors be held liable for any damages arising from the use of this software.
Permission is granted to anyone to use this software for any purpose, including commercial applications, and to alter it and redistribute it freely, subject to the following restrictions:
    1. The origin of this software must not be misrepresented; you must not claim that you wrote the original software. If you use this software in a product, an acknowledgment in the product documentation would be appreciated but is not required.
    2. Altered source versions must be plainly marked as such, and must not be misrepresented as being the original software.
    3. This notice may not be removed or altered from any source distribution.
]]
}

--[[
proto IsInLimits(Num, Min, Max)
.D This function checks if Num is between Min and Max limits (limits included).
.P Num
Number to check.
.P Min
Min limit value.
.P Max
Max limit value.
.R Return true if Num is above or equal of Min and below or equal of Max; false otherwise.
]]--
function IsInLimits(Num, Min, Max)
  return IsNumber(Num) and IsNumber(Min) and IsNumber(Max) and Min <= Num and Num <= Max
end
--[[
proto IsNumber(Data)
.D Check if Data is a number.
.P Data
Value to check if it's a number.
.R Returns true if Data is a number; false otherwise.
]]--
function IsNumber(Data)
  return type(Data) == 'number'
end

--[[
proto SetDefaultNumber(Data, Default)
.D This function check if Data is a number. if not, return Default; return Data otherwise.
.P Data
Value to set a default value
.P Default
Default value.
.R Return Default if Data is not a number; return Data otherwise.
]]--
function SetDefaultNumber(Data, Default)
  return IsNumber(Data) and Data or Default
end
