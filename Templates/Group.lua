local Group = {}

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

Group.__call = function() return Group.New() end
Group.__tostring = function() return "DinaGE GUI Group" end
Group.__index = Group
return Group