local Panel = {}

-- Déclaration du parent
local CurrentFile = (...):gsub("^(.*/+)", "")
local CurrentFolder = (...):gsub('%/'..CurrentFile..'$', '')
local Parent = require(CurrentFolder.."/Base")
setmetatable(Panel, {__index = Parent})

function Panel.New(X, Y, Width, Height, BorderColor, BackColor, Z, Thickness)
  -- Appel du constructeur du parent
  local self = setmetatable(Parent.New(X, Y), Panel)
  self:SetDimensions(Width, Height)
  self:SetBorderColor(BorderColor)
  self:SetBackColor(BackColor)
  self:SetZOrder(Z)
  self.thickness = Thickness or 1
  self.image = nil
  self.hover = false
  self.events = {}
  return self
end

function Panel:Draw()
  if self.visible then
    self:DrawPanel()
  end
end

function Panel:DrawPanel()
  love.graphics.setColor(1,1,1,1)
  if self.image == nil then
    if self.backcolor then
      love.graphics.setColor(self.backcolor)
      local sw, sh = love.graphics.getDimensions()
      love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    end
    if self.bordercolor then
      love.graphics.setColor(self.bordercolor)
      love.graphics.setLineWidth(self.thickness)
      love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
      love.graphics.setLineWidth(1)
    end
  else
    if self.imagecolor then
      love.graphics.setColor(self.imagecolor)
    end
    love.graphics.draw(self.image, self.x, self.y, 0, 1, 1, self.ox, self.oy)
  end
  love.graphics.setColor(1,1,1,1)
end

--[[
proto Panel:GetWidth()
.D This functions returns the width of the panel.
.R Returns the width of the panel.
]]--
function Panel:GetWidth()
  return self.width
end

--[[
proto Panel:GetHeight()
.D This functions returns the height of the panel.
.R Returns the height of the panel.
]]--
function Panel:GetHeight()
  return self.height
end

--[[
proto Panel:GetDimensions()
.D This functions returns the width and height of the text, depending on the font used.
.R Returns the width and height of the text.
]]--
function Panel:GetDimensions()
  return self:GetWidth(), self:GetHeight()
end

function Panel:SetDimensions(Width, Height)
  self.width = SetDefaultNumber(Width, 0)
  self.height = SetDefaultNumber(Height, 0)
end

function Panel:GetThickness()
  return self.thickness
end

--[[
proto Panel:GetBorderColor()
.D This functions returns the border color of the panel.
.R Returns the border color of the panel.
]]--
function Panel:GetBorderColor()
  return self.bordercolor
end
--[[
proto Panel:SetBorderColor(Color)
.D This function sets the border color of the panel.
.P Color
Color for the border (default : white).
]]--
function Panel:SetBorderColor(Color)
  self.bordercolor = Color
end
--[[
proto Panel:GetBackColor()
.D This functions returns the back color of the panel.
.R Returns the back color of the text.
]]--
function Panel:GetBackColor()
  return self.backcolor
end
--[[
proto Panel:SetBackColor(Color)
.D This function sets the back color of the panel.
.P Color
Color for the back of the panel
]]--
function Panel:SetBackColor(Color)
  self.backcolor = Color
end

--[[
proto Panel:GetZOrder()
.D This function returns the z-order of the panel.
.R Returns the z-order of the panel.
]]--
function Panel:GetZOrder()
  return self.z
end

function Panel:IsZOrderChanged()
  return self.zorderchanged
end

--[[
proto Panel:SetZOrder(Z)
.D This function sets the z-order of the panel.
.P Z
Z-order of the panel (default: 1).
]]--
function Panel:SetZOrder(Z)
  local zorder = self.z
  self.z = SetDefaultNumber(Z, 0)
  if Z ~= zorder then
    self.zorderchanged = true
  end
end
--
function Panel:SetEvent(pEventType, pFunction)
  self.events[pEventType] = pFunction
end
--
function Panel:SetImage(Image)
  self.image = Image
  if self.image then
    self.width = Image:getWidth()
    self.height = Image:getHeight()
  end
end
--
function Panel:SetImageOrigin(OriginX, OriginY)
  self.ox = SetDefaultNumber(OriginX, 0)
  self.oy = SetDefaultNumber(OriginY, 0)
end
--
function Panel:SetImageColor(Color)
  self.imagecolor = Color
end
--
function Panel:SetRotation(Rotation)
  self.r = Rotation or 0
end
--
function Panel:SetScale(ScaleX, ScaleY)
  if self.originalwidth == nil then
    self.originalwidth = self.width
  end
  if self.originalheight == nil then
    self.originalheight = self.height
  end
  self.sx = ScaleX or 1
  self.sy = ScaleY or 1
  self.width = self.originalwidth*self.sx
  self.height = self.originalheight*self.sx
end
--
function Panel:Update(dt)
  if self.visible then
    self:UpdatePanel(dt)
  end
end

function Panel:UpdatePanel(dt)
  local mx, my = love.mouse.getPosition()
  if mx > self.x and mx < self.x + self.width and
  my > self.y and my < self.y + self.height then
    if not self.hover then
      self.hover = true
      if self.events["hover"] then
        self.events["hover"](self, "begin")
      end
    end
  else
    if self.hover then
      self.hover = false
      if self.events["hover"] then
        self.events["hover"](self, "end")
      end
    end
  end
end

Panel.__call = function() return Panel.New() end
Panel.__tostring = function() return "DinaGE GUI Panel" end
Panel.__index = Panel
return Panel