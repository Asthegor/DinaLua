local Dina = {
  _TITLE       = 'Dina - Game Engine (c)',
  _VERSION     = 'v3.2.0',
  _URL         = 'https://dina.lacombedominique.com/',
  _LICENSE     = [[
Copyright (c) 2019-2022 LACOMBE Dominique
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
local UtilsFolder = CurrentFolder.."/Utils"

-- Local functions
local function InitializeGlobalFunctions()
  local files = love.filesystem.getDirectoryItems(UtilsFolder)
  for k, filename in ipairs(files) do
    local file = filename:gsub('%.lua$', '')
    require(UtilsFolder.."/"..file)
  end
end
local function CreateComponent(Dina, ComponentType, ...)
  if not ComponentType then
    return nil
  end
  local RComponent = Dina:require(ComponentType)
  if RComponent then
    local Component = RComponent.new(...)
    if Dina.loadingstate then
      if not Dina.statecomponents[Dina.loadingstate] then
        Dina.statecomponents[Dina.loadingstate] = {}
      end
      table.insert(Dina.statecomponents[Dina.loadingstate], Component)
    end
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
  self.statecomponents = {}
  self.datas = {}

  self.width = love.graphics.getWidth()
  self.height = love.graphics.getHeight()
end
local function ToString()
  return Dina._TITLE .. "\n" .. Dina._VERSION .. "\n" .. Dina._URL .. "\n" .. Dina._LICENSE
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


--[[
proto Dina:draw(WithState)
.D This function starts the "draw" function of the current state or of each of the loaded components.
.P WithState
Indicates whether to take into account the current state (true by default) or not.
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
.D This function starts the update function of the current state (if it has been defined). Otherwise, this function calls the update function of all loaded components.
.P dt
Delta time.
]]--
local maxdt = 1/60
function Dina:update(dt, WithState)
  dt = math.min(dt, maxdt)
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
      if component then
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
  end
  if calculate then
    SortTableByZOrder(self.components)
  end

  self:removeComponents()
  if self.controller then
    if self.controller.update then
      self.controller:update(dt)
    end
  end
end

--[[
proto Dina:removeComponent(Component)
.D This function deletes the given component.
.P Component
Component to remove
]]--
function Dina:removeComponent(Component)
  if Component == nil or type(Component) ~= "table" then return end
  for item = #self.components, 1, -1 do
    if self.components[item].id == Component.id then
      table.remove(self.components, item)
    end
  end
end

--[[
proto Dina:removeComponents()
.D This function removes all components tag for removed.
]]--
function Dina:removeComponents()
  for i = #self.components, 1, -1 do
    if self.components[i].remove then
      table.remove(self.components, i)
    end
  end
end

--[[
proto Dina:setGlobalValue(Name, Data)
.D This function allows to create a global data which can be used everywhere in the code. If the data already exists, it will be overwritten.
.P Name
Name of the data
.P Data
Value of the data
]]--
function Dina:setGlobalValue(Name, Data)
  assert(IsStringValid(string.lower(Name)), "ERROR: Name must not be empty.")
  self.datas[string.lower(Name)] = Data
end

--[[
proto Dina:getGlobalValue(Name)
.D This function allows to retrieve the value of a global data.
.P Name
Name of the data
.R Returns the value of the data if it exists; otherwise returns nil.
]]--
function Dina:getGlobalValue(Name)
  return self.datas[string.lower(Name)]
end

--[[
proto Dina:addState(State, File, Load)
.D This function adds a new report with the supplied file. If the report already exists, no changes are made.
.P File
Path and file name without extension.
.P Load
Name of the function to run when the state is loaded (by default, "load").
]]--
function Dina:addState(State, File, Load)
  self:loadController()
  if not self:isValidState(State) then
    self.statecomponents[State] = {}
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
.D This function allows to remove a given state.
.P State
State to remove.
]]--
function Dina:removeState(State)
  if self:isValidState(State) then
    self.states[State] = nil
  end
end

--[[
proto Dina:setState(State)
.D This function sets the current state and starts the stored Load function.
.P State
New state to define
]]--
function Dina:setState(State)
  if self:isValidState(State) then
    if self.controller then
      self.controller:dissociate()
    end
    if self.state and self.state ~= self.oldstate then
      for _, component in pairs(self.statecomponents[self.state]) do
        self:removeComponent(component)
      end
      self.statecomponents[self.state] = {}
      self.oldstate = self.state
    end
    self.state = State
    self.loadingstate = State
    local LoadFct = self.loadfcts[self.state]
    self.states[State][LoadFct]()
    self.loadingstate = nil
  else
    print(string.format("ERROR: Invalid state '%s'", State))
  end
end
--[[
proto Dina:isValidState(State)
.D This function checks if the given state has already been defined (true) or not (false).
.P State
State to be checked.
.R Returns true if the state already exists; false otherwise.
]]--
function Dina:isValidState(State)
  return self.states[State] and true or false
end


--[[
proto Dina:loadController()
.D This function allows you to initialize the management of the controllers.
]]--
function Dina:loadController()
  if not self.controller then
    self.controller = CreateComponent(Dina, "Controller")
  end
end

--[[
proto Dina:setActionKeys(Object, FctName, State, ...)
.D This function allows you to associate one or more keys with the given function.
.P Object
Object that must contain the function to be executed.
.P FctName
Name of the function to be executed.
.P Mode
Mode: 'pressed', 'released' or 'continuous'.
.P ...
List of keys that should trigger the execution of the function (see tutorials or examples for more details).
]]--
function Dina:setActionKeys(Object, FctName, Mode, ...)
  assert(type(Object) == "table", "ERROR: invalid Object parameter.")
  assert(type(Object[FctName]) == "function", "ERROR: invalid FctName parameter.")
  Mode = string.lower(Mode)
  assert(Mode == "pressed" or Mode == "released" or Mode == "continuous", "ERROR: invalid Mode parameter; must be 'pressed', 'released' or 'continuous'.")
  if self.controller == nil then
    self:loadController()
  end
  local UID = self.controller:associate(Object, FctName, Mode)
  self.controller:setActionKeys(UID, ...)
end

--[[
proto Dina:resetActionKeys()
.D This function removes all action keys previously defined by setActionKeys.
]]--
function Dina:resetActionKeys()
  if self.controller then
    self.controller:dissociate()
  end
end

-- System function
function Dina:require(Component)
  local path = SearchDirItem(Component..".lua", self.path)
  if path then
    path = path:gsub('%.lua$', '')
    return require(path)
  end
  return nil
end
Initialize(Dina)
Dina = setmetatable(Dina, Dina) -- DO NOT REMOVE
Dina.__call = function(...) return CreateComponent(...) end
Dina.__tostring = function() return ToString() end
return Dina