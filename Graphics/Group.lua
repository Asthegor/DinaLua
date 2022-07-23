local Group = {
  _TITLE       = 'Dina Game Engine - Group',
  _VERSION     = '2.0.4',
  _URL         = 'https://dina.lacombedominique.com/documentation/gui/group/',
  _LICENSE     = [[
Copyright (c) 2020 LACOMBE Dominique
ZLIB Licence
This software is provided 'as-is', without any express or implied warranty. In no event will the authors be held liable for any damages arising from the use of this software.
Permission is granted to anyone to use this software for any purpose, including commercial applications, and to alter it and redistribute it freely, subject to the following restrictions:
    1. The origin of this software must not be misrepresented; you must not claim that you wrote the original software. If you use this software in a product, an acknowledgment in the product documentation would be appreciated but is not required.
    2. Altered source versions must be plainly marked as such, and must not be misrepresented as being the original software.
    3. This notice may not be removed or altered from any source distribution.
]]
}

-- Déclaration du parent
local Dina = require("Dina")
local Parent = Dina:require("Base")
setmetatable(Group, {__index = Parent})

--[[
proto Group.new(X, Y)
.D This function creates a Group object.
.P X
Position on the X axis of the text.
.P Y
Position on the Y axis of the text.
.R Return an instance of a Group object.
]]--
function Group.new(X, Y)
  local self = setmetatable(Parent.new(X, Y), Group)
  self.components = {}
  self.width = 0
  self.height = 0
  return self
end

--[[
proto Group:add(Component)
.D This function add a given component to the group.
.P Component
Composant à ajouter au groupe.
]]--
function Group:add(Component)
  table.insert(self.components, Component)
  Dina:removeComponent(Component)
  self:updateDimensions()
end

--[[
proto Group:nbComponents()
.D This function returns the number of components already presents into the group.
.R Returns the number of components presents into the group.
]]--
function Group:nbComponents()
  return #self.components
end

--[[
proto Group:remove(Component)
.D This function removes a given component to the group. It's definitive, no rollback possible.
.P Component
Component to remove from the group.
]]--
function Group:removeComponent(Component)
  for i=#self.components, 1, -1 do
    if self.components[i] == Component then
      Component.remove = true
      table.remove(self.components, i)
    end
  end
end

--[[
proto Group:callbackZOrder()
.D This functions is used to ensure that all components will be drawn in the right order.
]]--
function Group:callbackZOrder()
  SortTableByZOrder(self.components)
end

--[[
proto Group:draw()
.D This function launches the Draw function of all its components.
]]--
function Group:draw()
  if self.visible then
    love.graphics.setColor(1,1,1,1)
    for _,v in pairs(self.components) do
      if v.draw then
        v:draw()
      end
    end
    love.graphics.setColor(1,1,1,1)
  end
end

--[[
proto Group:updateDimensions()
.D This function updates the width and height of the group from the position and dimensions of each of its components.
]]--
function Group:updateDimensions()
  self.width = 0
  self.height = 0
  local x, y, maxx, maxy, w, h
  for _,component in pairs(self.components) do
    local cx, cy = component:getPosition()
    local cw, ch = component:getDimensions()
    if x == nil or cx < x then
      x = cx
    end
    if y == nil or cy < y then
      y = cy
    end

    local cfx = 1
    local cfy = 1
    if component.getFlip then
      cfx, cfy = component:getFlip()
    end
    local cfxv = cfx > 0 and 1 or 0
    if w == nil or w < cx + cw * cfxv then
      w = cx + cw * cfxv
    end
    local cfyv = cfy > 0 and 1 or 0
    if h == nil or h < cy + ch * cfyv then
      h = cy + ch * cfyv
    end
  end
  if w and x and h and y then
    self.width = w - x
    self.height = h - y
  end
end

--[[
proto Group:getDimensions()
.D This function returns the width and height of the group.
.R Width and height of the group.
]]--
function Group:getDimensions()
  return self.width, self.height
end

--[[
proto Group:setDimensions()
.D This function sets the width and height of the group.
.P Width 
Width of the group.
.P Height
Height of the group.
]]--
function Group:setDimensions(Width, Height)
  self.width = SetDefaultNumber(Width, self.width)
  self.height = SetDefaultNumber(Height, self.height)
end
--[[
proto Group:setPosition(X, Y)
.D This function changes the position of the group and of each of its components.
.P X
Position on the X-axis of the group.
.P Y
Position on the Y-axis of the group.
]]--
function Group:setPosition(X, Y)
  X = X and X or self.x
  Y = Y and Y or self.y
  --local diffX = X - self.x
  local diffY = Y - self.y
  for _,item in pairs(self.components) do
    local x, y = item:getPosition()
    local diffX = X - x
    item:setPosition(x + diffX, y + diffY)
  end
  self.x = X
  self.y = Y
end

--[[
proto Group:center()
.D Cette fonction permet de centrer tous les composants par rapport à la position du groupe. Elle est similaire à la fonction centerOrigin d'un composant image.
]]--
function Group:center()
  local gw, gh = self:getDimensions()
  local diffX = -1 * (gw/2)
  local diffY = -1 * (gh/2)
  for _,v in pairs(self.components) do
    local x, y = v:getPosition()
    v:setPosition(x + diffX, y + diffY)
  end
end

--[[
proto Group:centerOnScreen()
.D Cette fonction permet de centrer le groupe à l'écran.
]]--
function Group:centerOnScreen()
  local gw, gh = self:getDimensions()
  self:setPosition((Dina.width - gw) / 2, (Dina.height - gh) / 2)
end
--[[
proto Group:setVisible(Visible)
.D This function sets the visibility of the group and of each of its compnents.
.P Visible
Visible (true) or not (false).
]]--
function Group:setVisible(Visible)
  for _,v in pairs(self.components) do
    if v.setVisible then
      v:setVisible(Visible)
    end
  end
end

--[[
proto Group:update(dt)
.D This funtion launches all updates needed for each of the components of the group.
.P dt
Delta time.
]]--
function Group:update(dt)
  for _,v in pairs(self.components) do
    if v.update then
      v:update(dt)
    end
  end
end

--[[
proto Group:toString(NoTitle)
.D This function display all variables containing in the current Base instance (tables and functions are excluded).
.P NoTitle
Indicates if the title must be displayed (false) or not (true).
]]--
function Group:toString(NoTitle)
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
Group.__tostring = function(Group, NoTitle) return Group:toString(NoTitle) end
Group.__index = Group
Group.__name = "Group"
return Group