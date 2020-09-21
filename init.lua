local GameEngine = {
  _VERSION     = 'Dina GE v1.3',
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

local CurrentFile = (...):gsub("^(.*/+)", "")
local CurrentFolder = (...):gsub('%/'..CurrentFile..'$', '')



-- Require core elements
local FunctionsFolder = CurrentFolder.."/fcts"
local files = love.filesystem.getDirectoryItems(FunctionsFolder)
for k, filename in ipairs(files) do
  local file = filename:gsub('%.lua$', '')
  require(FunctionsFolder.."/"..file)
end

-- Lists all sub-folders needed for the game engine to work properly.
local GameEngineFolders = {
  Managers  = CurrentFolder .. "/Managers",
  Templates = CurrentFolder .. "/Templates"
}

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
local IndexComponents = {}

GameEngine.ScreenWidth = love.graphics.getWidth()
GameEngine.ScreenHeight = love.graphics.getHeight()


--[[
proto GameEngine:CreateComponent(ComponentType, Args...)  
.D This function creates a new component based on the given name with some arguments.
.P ComponentType
Type of the component to create. Must not be nil.
.P Args...
Arguments to send to the component constructor. Can be none.
.R Returns the component initialized with the arguments.
]]--
function GameEngine:CreateComponent(ComponentType, ...)
  if not ComponentType then
    return nil
  end
  if GameEngineFiles == nil then
    LoadGameEngineFiles()
  end
  local RequirePath = GameEngineFiles[string.lower(ComponentType)]
  if RequirePath then
    local Component = require(RequirePath).New(...)
    table.insert(Components, Component)
    return Component
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
proto GameEngine.Update(dt)  
.D This function launch the Update function of all components created by GetComponent.
.P dt  
Delta time.
]]--
function GameEngine.Update(dt)
  for key, component in pairs(Components) do
    if component.CallbackZOrder then
      component:CallbackZOrder()
    end
    if component.Update then
      component:Update(dt)
    end
  end
end


GameEngine.__call = function(...) return GameEngine:CreateComponent(...) end

return GameEngine