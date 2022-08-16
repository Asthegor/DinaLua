local Manager = {
  _TITLE       = 'Dina Game Engine - Manager',
  _VERSION     = '2.0.5',
  _URL         = 'https://dina.lacombedominique.com/documentation/core/manager/',
  _LICENSE     = [[
Copyright (c) 2021 LACOMBE Dominique
ZLIB Licence
This software is provided 'as-is', without any express or implied warranty. In no event will the authors be held liable for any damages arising from the use of this software.
Permission is granted to anyone to use this software for any purpose, including commercial applications, and to alter it and redistribute it freely, subject to the following restrictions:
    1. The origin of this software must not be misrepresented; you must not claim that you wrote the original software. If you use this software in a product, an acknowledgment in the product documentation would be appreciated but is not required.
    2. Altered source versions must be plainly marked as such, and must not be misrepresented as being the original software.
    3. This notice may not be removed or altered from any source distribution.
]]
}

--[[
proto const Manager.new()
.D This function creates a new instance of Manager and define an unique id.
.R Returns a new instance of Manager.
]]--

function Manager.new()
  local self = {}
  local id = string.gsub(tostring(self), "table: ", "")
  self = setmetatable(self, Manager)
  self.id = id
  return self
end

--System functions
Manager.__index = Manager
return Manager