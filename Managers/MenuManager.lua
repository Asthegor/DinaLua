local MenuManager = {
  _VERSION     = 'Dina GE Menu Manager v1.3',
  _DESCRIPTION = 'Menu Manager in Dina Game Engine',
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
  self.Components = {}
  return self
end

--[[
proto MenuManager:AddComponent(ComponentName, ComponentType, ...)
.D This function add a new component, defined by its given name, to the menu. Cannot add a MenuManager to the components
.P ComponentName
Name of the component to add to the menu.
.P ComponentType
Type of the component to add to the menu. Cannot be "MenuManager".
.P ...
Other arguments needed to create the component.
.R Returns a new instance of the component.
]]--
function MenuManager:AddComponent(ComponentName, ComponentType, ...)
  if not self.Components then
    self.Components = {}
  end
  local component = self.GameEngine.AddComponent(ComponentName, ComponentType, ...)
  table.insert(self.Components, component)
  return component
end

--[[
proto MenuManager.CallbackZOrder()
.D This functions is used to ensure that all components are drawn in the right order.
]]--
function MenuManager:CallbackZOrder()
  SortTableByZOrder(self.Components)
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
  local components = self.Components
  for index = 1, #components do
    local component = components[index]
    if component.Draw then
      component:Draw()
    end
  end
end

--[[
proto MenuManager:GetComponentByName(Name)
.D This function retreive a component by its name.
.P Name
Name of the component
.R Returns the component if found; nil otherwise.
]]--
function MenuManager:GetComponentByName(Name)
  return self.Components[Name]
end

--[[
proto MenuManager:StopSounds()
.D This function stop all sounds.
]]--
function MenuManager:StopSounds()
  for _, component in pairs(self.Components) do
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
  local components = self.Components
  for index = 1, #components do
    local component = components[index]
    if component.Update then
      component:Update(dt)
    end
  end
end

MenuManager.__call = function() return MenuManager.New() end
MenuManager.__index = MenuManager
MenuManager.__tostring = function() return "MenuManager" end
return MenuManager