local MenuManager = {
  _TITLE       = 'Dina Game Engine - Menu Manager',
  _VERSION     = '3.1.2',
  _URL         = 'https://dina.lacombedominique.com/documentation/menus/menumanager/',
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

-- Declaration of the parent
local Dina = require("Dina")
local Parent = Dina:require("Manager")
setmetatable(MenuManager, {__index = Parent})

-- Locale functions
local function CenterItem(item)
  local _, iy = item:getPosition()
  local itw = item:getTextDimensions()
  local ix = (Dina.width - itw)/2
  item:setPosition(ix, iy)
end
local function SearchItemIdCollideWithMouse(MenuManager, mousePos)
  for i = 1, #MenuManager.items do
    local item = MenuManager.items[i]
    local ix, iy = item:getPosition()
    local iw, ih = item:getDimensions()
    if mousePos.x == nil or mousePos.y == nil or ix == nil or iy == nil or iw == nil or ih == nil then
      print("error", mousePos.x,mousePos.y,ix,iy,iw,ih)
    end
    if CollidePointRect(mousePos.x, mousePos.y, ix, iy, iw, ih) then
      return i
    end
  end
  return 0
end
--

--[[
proto const MenuManager.new()
.D Cette fonction crée une instance de l'objet MenuManager.
.R Retourne une instance de l'objet MenuManager.
]]--
function MenuManager.new(CtrlSpace)
  local self = setmetatable(Parent.new(), MenuManager)
  self.titletext = {}
  self.shadowtext = {}
  self.images = {}
  self.items = {}
  self.itemgroup = Dina("Group")
  self.itemgroup:setPosition(0, Dina.height/2)
  self.currentitem = 0
  self:setCtrlSpace(CtrlSpace)

  Dina:loadController()
  return self
end

function MenuManager:setNextKeys(...)
  if (...) then
    Dina:setActionKeys(self, "nextItem", "pressed", ...)
  else
    Dina:setActionKeys(self, "nextItem", "pressed", {"Keyboard", "down"}, {"Gamepad", "lefty", 1}, {"Mouse", "wheel_down"}, {"Mouse", "moved"})
  end
end

function MenuManager:setPreviousKeys(...)
  if (...) then
    Dina:setActionKeys(self, "previousItem", "pressed", ...)
  else
    Dina:setActionKeys(self, "previousItem", "pressed", {"Keyboard", "up"}, {"Gamepad", "lefty", -1}, {"Mouse", "wheel_up"}, {"Mouse", "moved"})
  end
end

function MenuManager:setValidateKeys(...)
  if (...) then
    Dina:setActionKeys(self, "validateItem", "pressed", ...)
  else
    Dina:setActionKeys(self, "validateItem", "pressed", {"Keyboard", "space"}, {"Gamepad", "a"}, {"Mouse", "button_1"})
  end
end

--[[
proto MenuManager:addImage(ImageName, X, Y, CenterOrigin)
.D Cette fonction permet d'ajouter une image au menu
.P ImageName
Emplacement et nom de l'image.
.P X
Position de l'image sur l'axe des X.
.P Y
Position de l'image sur l'axe des Y.
.P CenterOrigin
Indique si l'origine de l'image sera le centre de l'image.
]]--
function MenuManager:addImage(ImageName, X, Y, CenterOrigin)
  local image = Dina("Image", ImageName, X, Y, 1, 1, -100)
  if CenterOrigin == true then
    image:centerOrigin()
  end
end

--[[
proto MenuManager:addTitle(Title, Y, FontName, FontSize, TitleColor, WithShadow, ShadowColor, ShadowOffsetX, ShadowOffsetY)
.D Cette fonction permet d'ajouter un titre au menu
.P Title
Titre du jeu
.P Y
Position en hauteur du texte.
.P FontName
Nom de la police de caractères.
.P FontSize
Taille du texte.
.P TitleColor
Couleur du titre.
.P WithShadow
Indique si on veut avoir une ombre au titre.
.P ShadowColor
COuleur de l'ombre.
.P ShadowOffsetX
Décalage de l'ombre en pixels sur l'axe des X.
.P ShadowOffsetY
Décalage de l'ombre en pixels sur l'axe des Y. Si non renseigné, on utilise celui de l'axe X.
]]--
function MenuManager:addTitle(Title, Y, FontName, FontSize, TitleColor, WithShadow, ShadowColor, ShadowOffsetX, ShadowOffsetY)
  local titletext = Dina("Text", Title)
  titletext:setTextColor(TitleColor)
  titletext:setFont(FontName, FontSize)
  titletext:setZOrder(50)
  local x = (Dina.width - titletext:getTextWidth()) / 2
  titletext:setPosition(x, Y)
  if ShadowOffsetX == nil then
    ShadowOffsetX = 0
  end
  if ShadowOffsetY == nil then
    ShadowOffsetY = ShadowOffsetX
  end

  if WithShadow and ShadowOffsetX ~= 0 and ShadowOffsetY ~= 0 then
    local shadowtext = Dina("Text", Title, x + ShadowOffsetX, Y + ShadowOffsetY)
    shadowtext:setTextColor(ShadowColor)
    shadowtext:setFont(FontName, FontSize)
    shadowtext:setZOrder(45)
  end
end

function MenuManager:setCtrlSpace(Value)
  self.ctrlspace = SetDefaultNumber(Value, 0)
end


--[[
proto MenuManager:addItem(Text, OnSelection, OnDeselection, onValidation)
.D Cette fonction permet d'ajouter un item au menu.
.P Text
Texte à afficher.
.P OnSelection
Fonction à exécuter lorsqu'on sélectionne l'item.
.P OnDeselection
Fonction à exécuter quand on quitte la sélection.
.P onValidation
Fonction à exécuter lorsqu'on active l'item sélectionné.
]]--
function MenuManager:addItem(Text, FontName, FontSize, OnSelection, OnDeselection, OnValidation)
  assert(type(Text) == "string" and Text ~= "", "ERROR: The parameter 'Text' must not be an empty string.")
  assert(OnSelection == nil or type(OnSelection) == "function", "ERROR: The parameter 'OnSelection' must be a function.")
  assert(OnDeselection == nil or type(OnDeselection) == "function", "ERROR: The parameter 'OnDeselection' must be a function.")
  assert(OnValidation == nil or type(OnValidation) == "function", "ERROR: The parameter 'onValidation' must be a function.")

  local item = Dina("Text", Text)
  item:setFont(FontName, FontSize)
  item.onselection = OnSelection
  item.ondeselection = OnDeselection
  item.onvalidation = OnValidation

  local gx, gy = self.itemgroup:getPosition()
  local gw, gh = self.itemgroup:getDimensions()
  local itw = item:getTextDimensions()
  local ix = (Dina.width - itw)/2
  local iy = gy
  if gh then iy = iy + gh end
  item:setPosition(ix, iy)

  self.itemgroup:add(item)
  gw, gh = self.itemgroup:getDimensions()
  self.itemgroup:setDimensions(gw, gh + self.ctrlspace)

  table.insert(self.items, item)
  return item
end

--[[
proto MenuManager:nextItem()
.D Cette fonction permet de sélectionner l'item suivant du menu
]]--
function MenuManager:nextItem()
  if self.currentitem > 0 then
    local item = self.items[self.currentitem]
    if item then
        if item.ondeselection then
        item.ondeselection(item)
        end
        CenterItem(item)
    end
  end
  self.currentitem = self.currentitem + 1
  if self.currentitem > #self.items then
    self.currentitem = 1
  end
  local item = self.items[self.currentitem]
  if item then
    if item.onselection then
      item.onselection(item)
    end
    CenterItem(item)
  end
end

function MenuManager:previousItem()
  if self.currentitem > 0 then
    local item = self.items[self.currentitem]
    if item then
        if item.ondeselection then
        item.ondeselection(item)
        end
        CenterItem(item)
    end
  end
  self.currentitem = self.currentitem - 1
  if self.currentitem < 1 then
    self.currentitem = #self.items
  end
  local item = self.items[self.currentitem]
  if item then
    if item.onselection then
      item.onselection(item)
    end
    CenterItem(item)
  end
end

function MenuManager:validateItem()
  if self.currentitem > 0 then
    local item = self.items[self.currentitem]
    if item then
      if item.onvalidation then
        item.onvalidation(item)
      end
    end
  end
end

-- Fonction système
function MenuManager:toString(NoTitle)
  local str = ""
  if not NoTitle then
    str = str .. self._TITLE .. " (".. self._VERSION ..")\n" .. self._URL
  end
  for k,v in pairs(self) do
    local vtype = type(v)
    if vtype == "function"        then goto continue end
    if vtype == "table"           then goto continue end
    if string.sub(k, 1, 1) == "_" then goto continue end
    str = str .. "\n" .. tostring(k) .. " : " .. tostring(v)
    ::continue::
  end
  return str
end
-- System functions
MenuManager.__tostring = function(MenuManager, NoTitle) return MenuManager:toString(NoTitle) end
MenuManager.__index = MenuManager
MenuManager.__name = "MenuManager"
return MenuManager