local ComponentManager = {
  _VERSION     = 'Dina GE Components v1.3',
  _DESCRIPTION = 'Component Manager in Dina Game Engine',
  _URL         = 'https://dina.lacombedominique.com/documentation/core/componentmanager/',
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
proto const ComponentManager.New()
.D This function creates a new ComponentManager object.
.R Return an instance of ComponentManager object.
]]--
function ComponentManager.New()
  local self = setmetatable({}, ComponentManager)
  self.components = {}
  return self
end



--[[
proto ComponentManager:CallbackZOrder()
.D This functions is used to ensure that all components are drawn in the right order by arranging the components table.
]]--
function ComponentManager:CallbackZOrder()
  local calculate = false
  for key, component in pairs(self.components) do
    if component.IsZOrderChanged then
      if component:IsZOrderChanged() == true then
        calculate = true
        break
      end
    end
  end
  if calculate then
    SortTableByZOrder(self.components)
  end
end