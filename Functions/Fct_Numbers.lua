local Fct_Numbers = {
  _VERSION     = 'Dina GE Fct_Numbers v1.0',
  _DESCRIPTION = 'Fct_Numbers in Dina Game Engine',
  _URL         = 'https://dina.lacombedominique.com/documentation/functions/fct_numbers/',
  _LICENSE     = [[
    MIT LICENSE

    Copyright (c) 2019 LACOMBE Dominique

    Permission is hereby granted, free of charge, to any person obtaining a
    copy of this software and associated documentation files (the
    "Software"), to deal in the Software without restriction, including
    without limitation the rights to use, copy, modify, merge, publish,
    distribute, sublicense, and/or sell copies of the Software, and to
    permit persons to whom the Software is furnished to do so, subject to
    the following conditions:
    The above copyright notice and this permission notice shall be included
    in all copies or substantial portions of the Software.
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
    OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
    CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
    TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
    SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
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
