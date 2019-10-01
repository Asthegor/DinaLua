local GameEngine = {
  _VERSION     = 'Dina GE v1.0',
  _DESCRIPTION = 'Dina Game Engine',
  _URL         = 'https://dina.lacombedominique.com/documentation/gameengine/',
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
proto GameEngine.GetComponent(ComponentName, Args...)
.D This function creates a new component based on the given name with some arguments.
.P ComponentName
Name of the component to create. Must not be nil.
.P Args...
Arguments to send to the component constructor. Can be none.
.R Returns the component initialized with the arguments.
]]--
function GameEngine.GetComponent(ComponentName, ...)
  if ComponentName == nil then
    return nil
  end
  if GameEngineFiles == nil then
    LoadGameEngineFiles()
  end
  local RequirePath = GameEngineFiles[string.lower(ComponentName)]
  if RequirePath ~= nil then
    local Component = require(RequirePath)
    local newComponent = Component.New(...)
    table.insert(Components, newComponent)
    return newComponent
  end
  return nil
end

--[[
proto GameEngine.Update(dt)
.D This function launch the Update function of all components created by GetComponent.
.P dt
Delta time.
]]--
function GameEngine.Update(dt)
  for index = 1, #Components do
    local component = Components[index]
    local err, result = pcall(component.Update, component, dt)
  end
end

--[[
proto GameEngine.Update(dt)
.D This function launch the Draw function of all components created by GetComponent.
.P dt
Delta time.
]]--
function GameEngine.Draw()
  for index = 1, #Components do
    local component = Components[index]
    local err, result = pcall(component.Draw, component)
  end
end

return GameEngine