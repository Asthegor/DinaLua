local MenuManager = {
  _VERSION     = 'Dina GE Menu Manager v1.1',
  _DESCRIPTION = 'Menu Manager in Dina Game Engine',
  _URL         = 'https://dina.lacombedominique.com/documentation/managers/menumanager/',
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
  local component = self.GameEngine.AddComponent(ComponentName, ComponentType, ...)
  self.Components[ComponentName] = component
  return component
end

--[[
proto MenuManager:Draw()
.D This function launchs the Draw function of all its components.
]]--
function MenuManager:Draw()
  for key, component in pairs(self.Components) do
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
  for _, component in pairs(components) do
    if component.Update then
      component:Update(dt)
    end
  end
end

MenuManager.__call = function() return MenuManager.New() end
MenuManager.__index = MenuManager
MenuManager.__tostring = function() return "MenuManager" end
return MenuManager