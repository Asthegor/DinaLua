local Dina = {
  _TITLE       = 'Dina - Game Engine (c)',
  _VERSION     = 'v3.1.0',
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
local EngineFolders = love.filesystem.getDirectoryItems(CurrentFolder)
local FunctionsFolder = CurrentFolder.."/Functions"
--for _,path in ipairs(EngineFolders) do
--  package.path = package.path .. ";Dina."..path..".?.lua"
--end


local function InitializeGlobalFunctions()
  local files = love.filesystem.getDirectoryItems(FunctionsFolder)
  for k, filename in ipairs(files) do
    local file = filename:gsub('%.lua$', '')
    require(FunctionsFolder.."/"..file)
  end
end
local function CreateComponent(Dina, ComponentType, ...)
  if not ComponentType then
    return nil
  end
  local RComponent = Dina:require(ComponentType)
  if RComponent then
    local Component = RComponent.new(...)
    table.insert(Dina.components, Component)
    return Component
  end
  print("ERROR: Component '"..tostring(ComponentType).."' not found.")
  return nil
end
local function Initialize(self)
  self.path = CurrentFolder

  InitializeGlobalFunctions()

  self.components = {}
  self.states = {}
  self.loadfcts = {}

  self.width = love.graphics.getWidth()
  self.height = love.graphics.getHeight()
end
local function ToString()
  return Dina._TITLE .. "\n" .. Dina._VERSION .. "\n" .. Dina._URL .. "\n" .. Dina._LICENSE
end

--[[
proto Dina:draw(WithState)
.D Cette fonction lance la fonction "draw" de l'état courant ou celle de chacun des composants chargés.
.P WithState
Indique si on veut prendre en compte l'état courant (vrai par défaut) ou non.
]]--
function Dina:draw(WithState)
  if WithState == nil then
    WithState = true
  end
  if WithState and self.state then
    if self.states[self.state] then
      if self.states[self.state].draw then
        self.states[self.state]:draw()
      end
    end
  else
    for _, component in pairs(self.components) do
      if component.draw then
        component:draw()
      end
    end
  end
end

--[[
proto Dina:update(dt)
.D If a state has been set, this function launches the update fonction of the current state. Otherwise, the function launches the update of all of its components.
.P dt
Delta time.
]]--
function Dina:update(dt, WithState)
  local calculate = false
  if WithState == nil then
    WithState = true
  end
  if WithState and self.state then
    if self.states[self.state] then
      if self.states[self.state].update then
        self.states[self.state]:update(dt)
      end
    end
  else
    for i = 1, #self.components do
      local component = self.components[i]
      if component.callbackZOrder then
        component:callbackZOrder()
      elseif component.isZOrderChanged then
        if component:isZOrderChanged() == true then
          calculate = true
        end
      end
      if component.update then
        component:update(dt)
      end
    end
  end
  if calculate then
    SortTableByZOrder(self.components)
  end

  self:removeComponent()
  if self.controller then
    if self.controller.update then
      self.controller:update(dt)
    end
  end
end

--[[
proto Dina:removeComponent(Component)
.D This function removes all components indicated to be removed or the given component from the list of components.
.P Component
Component to remove
]]--
function Dina:removeComponent(Component)
  for i = #self.components, 1, -1 do
    if self.components[i].remove or (Component and self.components[i].id == Component.id) then
      table.remove(self.components, i)
    end
  end
end

--[[
proto Dina:addState(State, File, Load)
.D This function add a new state with the given file. If the given state already exists, the function does nothing.
.P File
Path and name of the file without extension.
.P Load
Name of the function to load (by default, "load").
]]--
function Dina:addState(State, File, Load)
  if not self:isValidState(State) then
    self.states[State] = require(File)
    if Load == nil or Load == "" then Load = "load" end
    local LoadFct = self.states[State][Load]
    if LoadFct and type(LoadFct) == "function" then
      self.loadfcts[State] = Load
    end
  end
end

--[[
proto Dina:removeState(State)
.D Cette fonction permet de retirer un etat donne.
.P State
Etat a retirer.
]]--
function Dina:removeState(State)
  if self:isValidState(State) then
    self.states[State] = nil
  end
end

--[[
proto Dina:setState(State)
.D This function sets the state to the given one and launches the given Load function.
.P State
New state to set.
.P NoLoad
Indicates if the Load function is launches (value : false; default) or not (value : true).
]]--
function Dina:setState(State, NoLoad)
  if self:isValidState(State) then
    if self.controller then
      self.controller:dissociate()
    end
    self.oldstate = self.state
    self.state = State
    if NoLoad ~= true then NoLoad = false end
    if not NoLoad then
      local LoadFct = self.loadfcts[self.state]
      self.states[State][LoadFct]()
    end
  else
    print(string.format("DinaGE - ERROR: Invalid state '%s'", State))
  end
end
--[[
proto Dina:isValidState(State)
.D This function check if the given state has already been set (true) or not (false).
.P State
The state to check.
.R Returns if the state already exists.
]]--
function Dina:isValidState(State)
  return self.states[State] and true or false
end



--TODO: help
function Dina:loadController()
  self.controller = CreateComponent(Dina, "Controller")
end
--TODO: help
function Dina:setActionKeys(Object, FctName, State, ...)
  assert(type(Object) == "table", "ERROR: invalid Object parameter.")
  assert(type(Object[FctName]) == "function", "ERROR: invalid FctName parameter.")
  State = string.lower(State)
  assert(State == "pressed" or State == "released" or State == "continuous", "ERROR: invalid State parameter; must be 'pressed', 'released' or 'continuous'.")
  local UID = self.controller:associate(Object, FctName, State)
  self.controller:setActionKeys(UID, ...)
end


local function SearchDirItem(Item, Path)
  local paths = love.filesystem.getDirectoryItems(Path)
  for _, name in pairs(paths) do
    if string.lower(name) == string.lower(Item) then
      return Path .. "/" .. name
    end
    local filepath = SearchDirItem(Item, Path .. "/" .. name)
    if filepath then
      return filepath
    end
  end
  return nil
end

-- TODO: help
function Dina:require(Component)
  local path = SearchDirItem(Component..".lua", self.path)
  if path then
    path = path:gsub('%.lua$', '')
    return require(path)
  end
  return nil
end

Initialize(Dina)


Dina.__call = function(...) return CreateComponent(...) end
Dina.__tostring = function() return ToString() end
Dina = setmetatable(Dina, Dina) -- DO NOT REMOVE
return Dina