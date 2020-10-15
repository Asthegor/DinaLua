local Group = {
  _TITLE       = 'Dina GE Group',
  _VERSION     = '2.0.4',
  _URL         = 'https://dina.lacombedominique.com/documentation/templates/group/',
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
local CurrentFile = (...):gsub("^(.*/+)", "")
local CurrentFolder = (...):gsub('%/'..CurrentFile..'$', '')
local Parent = require(CurrentFolder.."/Base")
setmetatable(Group, {__index = Parent})

--[[
proto Group.New(X, Y)
.D This function creates a Group object.
.P X
Position on the X axis of the text.
.P Y
Position on the Y axis of the text.
.R Return an instance of a Group object.
]]--
function Group.New(X, Y)
  local self = setmetatable(Parent.New(X, Y), Group)
  self.components = {}
  return self
end

--[[
proto Group:Add(Component)
.D This function add a given component to the group.
.P Component
Compnent to add to the group.
]]--
function Group:Add(Component)
  table.insert(self.components, Component)
  self:UpdateDimensions()
end

--[[
proto Group:Remove(Component)
.D This function removes a given component to the group.
.P Component
Component to remove from the group.
]]--
function Group:Remove(Component)
  for i=#self.components, 1, -1 do
    if self.components[i] == Component then
      Component.remove = true
      table.remove(self.components, i)
    end
  end
end

--[[
proto Group:CallbackZOrder()
.D This functions is used to ensure that all components will be drawn in the right order.
]]--
function Group:CallbackZOrder()
  SortTableByZOrder(self.components)
end

--[[
proto Group:Draw()
.D This function launches the Draw function of all its components.
]]--
function Group:Draw()
  if self.visible then
    love.graphics.setColor(1,1,1,1)
    for _,v in pairs(self.components) do
      if v.Draw then
        v:Draw()
      end
    end
    love.graphics.setColor(1,1,1,1)
  end
end

--[[
proto Group:UpdateDimensions()
.D This function updates the width and height of the group from the position and dimensions of each of its components.
]]--
function Group:UpdateDimensions()
  self.width = 0
  self.height = 0
  local x, y, maxx, maxy, w, h
  for _,component in pairs(self.components) do
    local cx, cy = component:GetPosition()
    local cw, ch = component:GetDimensions()
    if x == nil or cx < x then
      x = cx
    end
    if y == nil or cy < y then
      y = cy
    end
    if maxx == nil or cx > maxx then
      maxx = cx
      w = cw
    end
    if maxy == nil or cy > maxy then
      maxy = cy
      h = ch
    end
  end
  if maxx and w and x and maxy and h and y then
    self.width = maxx + w - x
    self.height = maxy + h - y
  end
end

--[[
proto Group:GetDimensions()
.D This function returns the width and height of the group.
.R Width and height of the group.
]]--
function Group:GetDimensions()
  return self.width, self.height
end

--[[
proto Group:SetPosition(X, Y)
.D This function changes the position of the group and of each of its components.
.P X
Position on the X-axis of the group.
.P Y
Position on the Y-axis of the group.
]]--
function Group:SetPosition(X, Y)
  X = X and X or self.x
  Y = Y and Y or self.y
  local diffX = X - self.x
  local diffY = Y - self.y
  for _,v in pairs(self.components) do
    local x, y = v:GetPosition()
    v:SetPosition(x + diffX, y + diffY)
  end
  self.x = X
  self.y = Y
end

--[[
proto Group:SetVisible(Visible)
.D This function sets the visibility of the group and of each of its compnents.
.P Visible
Visible (true) or not (false).
]]--
function Group:SetVisible(Visible)
  for _,v in pairs(self.components) do
    if v.SetVisible then
      v:SetVisible(Visible)
    end
  end
end

--[[
proto Group:Update(dt)
.D This funtion launches all updates needed for each of the components of the group.
.P dt
Delta time.
]]--
function Group:Update(dt)
  for _,v in pairs(self.components) do
    if v.Update then
      v:Update(dt)
    end
  end
end

--[[
proto Group:ToString(NoTitle)
.D This function display all variables containing in the current Base instance (tables and functions are excluded).
.P NoTitle
Indicates if the title must be displayed (false) or not (true).
]]--
function Group:ToString(NoTitle)
  local str = ""
  if not NoTitle then
    str = str .. self._TITLE .. " (".. self._VERSION ..")\n" .. self._URL
  end
  str = str .. Parent:ToString(true)
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
Group.__tostring = function(Group, NoTitle) return Group:ToString(NoTitle) end
Group.__index = Group
return Group