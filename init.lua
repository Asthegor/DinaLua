local GameEngine = {
  _VERSION     = 'Dina GE v1.2',
  _DESCRIPTION = 'Dina Game Engine',
  _URL         = 'https://dina.lacombedominique.com/documentation/gameengine/',
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

-- Lists all sub-folders needed for the game engine to work properly.
local CurrentFolder = (...):gsub('%/init$', '')
local GameEngineFolders = {
  Managers  = CurrentFolder .. "/Managers",
  Templates = CurrentFolder .. "/Templates"
}
-- Add all generic functions from the Functions folders
local FctPath = CurrentFolder .. "/Functions"
local files = love.filesystem.getDirectoryItems(FctPath)
for k, filename in ipairs(files) do
  local file = filename:gsub('%.lua$', '')
  require(FctPath.. "/" .. file)
end

-- DO NOT MODIFY. DO NOT MODIFY.
-- This variable MUST NOT be defined.
local GameEngineFiles = nil

--This function retreive all lua files from all sub-directories defined in GameEngineFolders.
local function LoadGameEngineFiles()
  GameEngineFiles = {}
  for name, path in pairs(GameEngineFolders) do
    local files = love.filesystem.getDirectoryItems(path)
    for k, filename in ipairs(files) do
      local file = filename:gsub('%.lua$', '')
      GameEngineFiles[string.lower(file)] = path .. "/" .. file
    end
  end
end

-- The Components table contains all loaded components.
local Components = {}
--[[
  proto GameEngine.AddComponent(ComponentName, Args...)  
  .D This function creates a new component based on the given name with some arguments.
.P ComponentName  
Name of the component to create. Must not be nil.
.P Args...
Arguments to send to the component constructor. Can be none.
.R Returns the component initialized with the arguments.
]]--
function GameEngine.AddComponent(ComponentName, ComponentType, ...)
  if not ComponentType then
    return nil
  end
  if not GameEngineFiles then
    LoadGameEngineFiles()
  end
  local RequirePath = GameEngineFiles[string.lower(ComponentType)]
  if RequirePath then
    local Component = require(RequirePath)
    local newComponent = Component.New(ComponentName, ...)
    table.insert(Components, newComponent)
    return newComponent
  end
  print("Component '"..tostring(ComponentType).."' not found.")
  return nil
end

--[[
proto GameEngine.Draw()
.D This function launch the Draw function of all components created by GetComponent.
]]--
function GameEngine.Draw()
  for key, component in pairs(Components) do
    if component.Draw then
      component:Draw()
    end
  end
end

--[[
proto GameEngine.CallbackZOrder()
.D This functions is used to ensure that all components are drawn in the right order.
]]--
function GameEngine.CallbackZOrder()
  for key, component in pairs(Components) do
    if component.CallbackZOrder then
      print("CallbackZOrder for "..tostring(component))
      component:CallbackZOrder()
    end
  end
end

--[[
proto GameEngine.Update(dt)  
.D This function launch the Update function of all components created by GetComponent.
.P dt  
Delta time.
]]--
function GameEngine.Update(dt)
  for key, component in pairs(Components) do
    if component.Update then
      component:Update(dt)
    end
  end
end

return GameEngine