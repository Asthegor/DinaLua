local Char_Fcts = {
  _TITLE       = 'Dina Game Engine - String Functions',
  _VERSION     = '2.0.4',
  _URL         = 'https://dina.lacombedominique.com/documentation/functions/strings/',
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
proto IsStringValid(String)
.D This function checks if the given string is not nil and not empty.
.R True if the given string is valid; false otherwise.
]]--
function IsStringValid(String)
  return String and type(String) == "string" and String ~= "" and true or false
end
