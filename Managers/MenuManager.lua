local MenuManager = {
  _VERSION     = 'Dina GE Menu Manager v1.0',
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
  local component = self.GameEngine.GetComponent(ComponentType, ...)
  if tostring(component) == tostring(self) then
    return nil
  end
  self.Components[ComponentName] = component
  return component
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
proto MenuManager:SetTitle(Content, PosX, PosY, FontName, FontSize, DisplayTime, WaitTime, NbLoop)
.D This function creates a menu title at a given position, font, font size and a delay before and for displaying, including the number of times it will be shown.
.P Content
String to display.
.P PosX
Position in pixels from the left of the screen.
.P PosY
Position in pixels from the top of the screen.
.P FontName
Name of the font.
.P FontSize
Size of the font.
.P DisplayTime
Title display duration.
.P WaitTime
Time before displaying the title.
.P NbLoop
Number of times the title will be displayed
]]--
function MenuManager:SetTitle(Content, FontName, FontSize, WaitTime, DisplayTime, NbLoop, X, Y)
  if type(Content) == "table" then
    self:AddComponent("Title", "Text", Content)
    return
  end
  self:AddComponent("Title", "Text", Content, FontName, FontSize, WaitTime, DisplayTime, NbLoop, X, Y)
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

--[[
proto MenuManager:Draw()
.D This function launchs the draw function of all its child elements.
]]--
function MenuManager:Draw()
  local components = self.Components
  for key, component in pairs(components) do
    if component.Draw then
      component:Draw()
    end
  end
end

--***********************************************************************************************
-- Functions for managing the sounds.
--***********************************************************************************************
--[[
proto MenuManager:PlaySound(Name, NbLoop)
.D This function play a sound for the given number of times.
.P Name
Name to retreive the sound.
.P NbLoop
Number of times the sound must be played. 0 means never and -1 means always (default: -1).
]]--
function MenuManager:PlaySound(Name, NbLoop)
  local sound = self:GetComponentByName(Name)
  if sound then
    sound:Play()
  end
end

--[[
proto MenuManager:SetSoundLooping(Name, NbLoop)
.D This function set the given number of times to play a sound.
.P Name
Name to retreive the sound.
.P NbLoop
Number of times the sound must be played. 0 means never and -1 means always (default: -1).
]]--
function MenuManager:SetSoundLooping(Name, NbLoop)
  local sound = self:GetComponentByName(Name)
  if sound then
    sound:SetLooping(NbLoop)
  end
end
--[[
proto MenuManager:StopAll()
.D This function stop all musics and sounds.
]]--
function MenuManager:StopAllSounds()
  for _, component in pairs(self.Components) do
    if tostring(component) == "Sound" then
      component:Stop()
    end
  end
end

--[[
proto MenuManager:StopSound(Name)
.D This function stop a sound.
.P Name
Name to retreive the sound.
]]--
function MenuManager:StopSound(Name)
  local sound = self:GetComponentByName(Name)
  if sound then
    sound:Stop()
  end
end
--***********************************************************************************************

MenuManager.__index = MenuManager
MenuManager.__tostring = function() return "MenuManager" end
return MenuManager