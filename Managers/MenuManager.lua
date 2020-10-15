local MenuManager = {
  _TITLE       = 'Dina GE Menu Manager',
  _VERSION     = '2.0.4',
  _URL         = 'https://dina.lacombedominique.com/documentation/managers/menumanager/',
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
proto const MenuManager.New()
.D This function creates a new MenuManager object.
.R Return an instance of MenuManager object.
]]--
function MenuManager.New()
  local self = setmetatable({}, MenuManager)
  self.GameEngine = require("DinaGE")
  self.components = {}
  return self
end

--[[
proto MenuManager:Add(ComponentType, Args...)
.D This function add a new component, defined by its given name, to the menu. Cannot add a MenuManager to the components
.P ComponentType
Type of the component to add to the menu. Cannot be "MenuManager".
.P Args...
Other arguments needed to create the component.
.R Returns a new instance of the component.
]]--
function MenuManager:Add(ComponentType, ...)
  if not self.components then
    self.components = {}
  end
  local component = self.GameEngine(ComponentType, ...)
  table.insert(self.components, component)
  return component
end

--[[
proto MenuManager.CallbackZOrder()
.D This functions is used to ensure that all components are drawn in the right order.
]]--
function MenuManager:CallbackZOrder()
  local calculate = false
  for _, component in pairs(self.components) do
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


--[[
proto MenuManager:ChangePosition(X, Y)
.D This function change the position on the X and Y axis for all positionable components.
.P X
Add this value to the X axis position of all positionable components.
.P Y
Add this value to the Y axis position of all positionable components.
]]--
function MenuManager:ChangePosition(X, Y)
  for _, component in pairs(self.components) do
    if component.ChangePosition then
      component.ChangePosition(X, Y)
    end
  end
end

--[[
proto MenuManager:Draw()
.D This function launchs the Draw function of all its components.
]]--
function MenuManager:Draw()
  love.graphics.push()
  for index = 1, #self.components do
    local component = self.components[index]
    if component.Draw then
      component:Draw()
    end
  end
  love.graphics.pop()
end

--[[
proto MenuManager:StopSounds()
.D This function stop all sounds.
]]--
function MenuManager:StopSounds()
  for _, component in pairs(self.components) do
    if tostring(component) == "Sound" then
      component:Stop()
    end
  end
end

--[[
proto MenuManager:Update(dt)
.D This function launchs the update of all its child elements.
.P dt
Deltatime
]]--
function MenuManager:Update(dt)
  for index = 1, #self.components do
    local component = self.components[index]
    if component.Update then
      component:Update(dt)
    end
  end
end

function MenuManager:ToString(NoTitle)
  local str = ""
  if not NoTitle then
    str = str .. self._TITLE .. " (".. self._VERSION ..")\n" .. self._URL
  end
  for k,v in pairs(self) do
    local vtype = type(v)
    if vtype == "function"        then goto continue end
    if vtype == "table"           then goto continue end
    if string.sub(k, 1, 1) == "_" then goto continue end
    str = str .. "\n" .. tostring(k) .. " : " .. tostring(v)
    ::continue::
  end
  return str
end
-- System functions
MenuManager.__tostring = function(NoTitle) return MenuManager:ToString(NoTitle) end
MenuManager.__index = MenuManager
return MenuManager