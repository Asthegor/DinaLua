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
.D Cette fonction lance la fonction update de l'état courant (s'il a été défini). Autrement, cette fonction lance la fonction update de tous les composants chargés.
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

  self:removeComponent()
  if self.controller then
    if self.controller.update then
      self.controller:update(dt)
    end
  end
end

--[[
proto Dina:removeComponent(Component)
.D Cette fonction supprime le composant fourni ou tous les composants indiqués comme à supprimer.
.P Component
Component to remove
]]--
function Dina:removeComponent(Component)
  for i = #self.components, 1, -1 do
    if self.components[i].remove or 
       (Component and self.components[i].id == Component.id) then
      table.remove(self.components, i)
    end
  end
end

--[[
proto Dina:setGlobalValue(Name, Data)
.D Cette fonction permet de créer une donnée globale qui pourra être utilisée partout dans le code. Si la donnée existe déjà, elle sera écrasée.
.P Name
Nom de la donnée
.P Data
Valeur de la donnée
]]--
function Dina:setGlobalValue(Name, Data)
  assert(IsStringValid(string.lower(Name)), "ERROR: Name must not be empty.")
  self.datas[string.lower(Name)] = Data
end

--[[
proto Dina:getGlobalValue(Name)
.D Cette fonction permet de récupérer la valeur d'une donnée globale.
.P Name
Nom de la donnée
.R Retourne la valeur de la donnée si elle existe; autrement retourne nil.
]]--
function Dina:getGlobalValue(Name)
  return self.datas[string.lower(Name)]
end

--[[
proto Dina:addState(State, File, Load)
.D Cette fonction ajoute un nouvel état avec le fichier fourni. Si l'état existe déjà, aucun changement n'est effectué.
.P File
Chemin et nom du fichier sans extension.
.P Load
Nom de la fonction à lancer lors du chargement de l'état (par défaut, "load").
]]--
function Dina:addState(State, File, Load)
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
.D Cette fonction permet de retirer un état donné.
.P State
Etat à retirer.
]]--
function Dina:removeState(State)
  if self:isValidState(State) then
    self.states[State] = nil
  end
end

--[[
proto Dina:setState(State)
.D Cette fonction définit l'état courant et lance la fonction Load enregistrée.
.P State
Nouvel état à définir.
.P NoLoad
Indique si la fonction Load est à exécuter (true) ou non (false; valeur par default).
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
.D Cette fonction vérifie si l'état donné a déjà été défini (true) ou non (false).
.P State
Etat à vérifer.
.R Retourne true si l'état existe déjà; false autrement.
]]--
function Dina:isValidState(State)
  return self.states[State] and true or false
end


--[[
proto Dina:loadController()
.D Cette fonction permet d'initialiser la gestion des contrôleurs.
]]--
function Dina:loadController()
  if not self.controller then
    self.controller = CreateComponent(Dina, "Controller")
  end
end

--[[
proto Dina:setActionKeys(Object, FctName, State, ...)
.D Cette fonction permet d'associer une ou plusieurs touches à la fonction donnée.
.P Object
Objet qui doit contenir la fonction à exécuter.
.P FctName
Nom de la fonction à exécuter.
.P Mode
Mode de gestion des touches : 'pressed', 'released' ou 'continuous'.
.P ...
Liste des touches devant déclencher l'exécution de la fonction (voir les tutoriels ou exemples pour plus de détails).
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

-- System functions
Dina.__call = function(...) return CreateComponent(...) end
Dina.__tostring = function() return ToString() end
Dina = setmetatable(Dina, Dina) -- DO NOT REMOVE
return Dina