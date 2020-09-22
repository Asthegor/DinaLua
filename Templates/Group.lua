local Group = {
  _TITLE       = 'Dina GE Group',
  _VERSION     = '2.0.3',
  _URL         = 'https://dina.lacombedominique.com/documentation/templates/group/',
  _LICENSE     = [[
    ZLIB Licence

    Copyright (c) 2020 LACOMBE Dominique

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


function Group.New(X, Y)
  local self = setmetatable(Parent.New(X, Y), Group)
  self.components = {}
  return self
end

function Group:AddComponent(Component)
  table.insert(self.components, Component)
end
function Group:NbComponents()
  return #self.components
end
function Group:Draw()
  if self.visible then
    self:DrawGroup()
  end
end
function Group:DrawGroup()
  love.graphics.setColor(1,1,1,1)
  for _,v in pairs(self.components) do
    if v.Draw then
      v:Draw()
    end
  end
  love.graphics.setColor(1,1,1,1)
end
  
function Group:GetDimensions()
  local width = 0
  local height = 0
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
    width = maxx + w - x
    height = maxy + h - y
  end
  return width, height
end

function Group:SetPosition(X, Y)
  local diffX = X - self.x
  local diffY = Y - self.y
  for _,v in pairs(self.components) do
    local x, y = v:GetPosition()
    v:SetPosition(x + diffX, y + diffY)
  end
  self.x = X
  self.y = Y
end

function Group:SetVisible(Visible)
  for _,v in pairs(self.components) do
    if v.SetVisible then
      v:SetVisible(Visible)
    end
  end
end

function Group:Update(dt)
  for _,v in pairs(self.components) do
    if v.Update then
      v:Update(dt)
    end
  end
end

function Group:Unload()
  for _,v in pairs(self.components) do
    v = nil
  end
end

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
Group.__tostring = function(NoTitle) return Group:ToString(NoTitle) end
Group.__call = function() return Group.New() end
Group.__index = Group
return Group