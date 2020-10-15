local DinaGE = {
  _VERSION     = 'v2.0.4',
  _TITLE       = 'Dina GE - Dina Game Engine (c)',
  _URL         = 'https://dina.lacombedominique.com/',
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

local CurrentFile = (...):gsub("^(.*/+)", "")
local CurrentFolder = (...):gsub('%/'..CurrentFile..'$', '')



-- Require core elements
local FunctionsFolder = CurrentFolder.."/fcts"
local files = love.filesystem.getDirectoryItems(FunctionsFolder)
for k, filename in ipairs(files) do
  local file = filename:gsub('%.lua$', '')
  require(FunctionsFolder.."/"..file)
end


-- This table contains all components created by CreateComponent function.
DinaGE.components = {}
DinaGE.ComponentFiles = {}

DinaGE.ScreenWidth = love.graphics.getWidth()
DinaGE.ScreenHeight = love.graphics.getHeight()

-- Function to create a new component
local function CreateComponent(DinaGE, ComponentType, ...)
  if not ComponentType then
    return nil
  end
  local RequirePath = DinaGE.ComponentFiles[string.lower(ComponentType)]
  if RequirePath then
    local Component = require(RequirePath).New(...)
    table.insert(DinaGE.components, Component)
    return Component
  end
  print("DinaGE - ERROR: Component '"..tostring(ComponentType).."' not found.")
  return nil
end

--[[
proto DinaGE:Draw()
.D This function launch the Draw function of all components.
]]--
function DinaGE:Draw()
  for _, component in pairs(self.components) do
    if component.Draw then
      component:Draw()
    end
  end
end

--[[
proto DinaGE:Update(dt)  
.D This function removes all components marked as to be removed and launch the Update function of each of the components.
.P dt  
Delta time.
]]--
function DinaGE:Update(dt)
  for i=#self.components, 1, -1 do
    if self.components[i].remove then
      table.remove(self.components, i)
    else
      local component = self.components[i]
      if component.CallbackZOrder then
        component:CallbackZOrder()
      end
      if component.Update then
        component:Update(dt)
      end
    end
  end
end

--[[
proto DinaGE:KeyPressed(Key)
.D This function launch the KeyPress function of all components.
.P Key
Key pressed.
]]--
function DinaGE:KeyPress(Key)
  for _, component in pairs(self.components) do
    if component.KeyPress then
      component:KeyPress(Key)
    end
  end
end

-- Function to load mandatory datas
local function InitializeComponents()
  --This function retreive all lua files from all sub-directories defined in GameEngineFolders.
  -- Lists all sub-folders needed for the game engine to work properly.
  local GameEngineFolders = {
    Managers  = CurrentFolder .. "/Managers",
    Templates = CurrentFolder .. "/Templates"
  }
  for _, path in pairs(GameEngineFolders) do
    local files = love.filesystem.getDirectoryItems(path)
    for _, filename in ipairs(files) do
      local file = filename:gsub('%.lua$', '')
      DinaGE.ComponentFiles[string.lower(file)] = path .. "/" .. file
    end
  end
  
end

-- Function to diplay all informations about the engine
local function ToString()
  return DinaGE._TITLE .. "\n" .. DinaGE._VERSION .. "\n" .. DinaGE._URL .. "\n" .. DinaGE._LICENSE
end

InitializeComponents()
DinaGE.__call = function(...) return CreateComponent(...) end
DinaGE.__tostring = function() return ToString() end
DinaGE = setmetatable(DinaGE, DinaGE)
DinaGE.__index = DinaGE
return DinaGE