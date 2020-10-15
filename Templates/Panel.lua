local Panel = {
  _TITLE       = 'Dina GE Panel',
  _VERSION     = '2.0.4',
  _URL         = 'https://dina.lacombedominique.com/documentation/templates/panel/',
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
setmetatable(Panel, {__index = Parent})

--[[
proto const Panel.New(X, Y, Width, Height, BorderColor, BackColor, Z, Thickness)
.D This function creates a new Panel object.
.P X
Position on the X axis of the panel.
.P Y
Position on the Y axis of the panel.
.P Width
Width of the space occupied by the panel.
.P Height
Height of the space occupied by the panel.
.P BorderColor
Border color of the panel.
.P BackColor
Back color of the panel.
.P Z
Z-Order of the panel.
.P Thickness
Thickness of the panel border.
.R Return an instance of Panel object.
]]--
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

--[[
proto Panel:Draw()
.D This function draw the panel if visible.
]]--
function Panel:Draw()
  if self.visible then
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
      love.graphics.draw(self.image, self.x, self.y, self.r, self.sx, self.sy, self.ox, self.oy)
    end
    love.graphics.setColor(1,1,1,1)
  end
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

--[[
proto Panel:SetDimensions(Width, Height)
.D This function defines the new dimensions of the panel.
.P Width
Width of the space occupied by the panel.
.P Height
Height of the space occupied by the panel.
]]--
function Panel:SetDimensions(Width, Height)
  self.width = SetDefaultNumber(Width, 0)
  self.height = SetDefaultNumber(Height, 0)
end

--[[
proto Panel:GetThickness()
.D This functions returns the thickness of the border of the panel.
.R Returns the border thickness of the panel.
]]--
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

--[[
proto Panel:IsZOrderChanged()
.D This function returns if the z-order has been changed.
.R Returns if the z-order changed.
]]--
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

--[[
proto Panel:SetEvent(EventName, EventFunction)
.D This function sets an event by the given name with a given function.
]]--
function Panel:SetEvent(EventName, EventFunction)
  if IsEventValid(EventName) then
    self.events[EventName] = EventFunction
  else
    print(string.format("DinaGE - ERROR: Event name '%s' invalid.", EventName))
  end
end

--[[
proto Panel:SetImage(Image)
.D This function set an image as background of the panel.
]]--
function Panel:SetImage(Image)
  self.image = Image
  if self.image then
    self.width = Image:getWidth()
    self.height = Image:getHeight()
  end
end
--[[
proto Panel:SetImageOrigin(OriginX, OriginY)
.D This function defines the origin coordinate of the image.
]]--
function Panel:SetImageOrigin(OriginX, OriginY)
  self.ox = SetDefaultNumber(OriginX, 0)
  self.oy = SetDefaultNumber(OriginY, 0)
end
--[[
proto Panel:SetImageColor(Color)
.D This function sets the color used to draw the image.
]]--
function Panel:SetImageColor(Color)
  self.imagecolor = Color
end
--[[
proto Panel:SetImageRotation(Rotation)
.D This function sets the rotation value to apply to the image.
]]--
function Panel:SetImageRotation(Rotation)
  self.r = Rotation or 0
end
--[[
proto Panel:SetScale(ScaleX, ScaleY)
.D This function sets the scale to apply to the image and update the width and height of the panel.
]]--
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
--[[
proto Panel:Update(dt)
.D This funtion launches all updates needed for the current panel.
.P dt
Delta time.
]]--
function Panel:Update(dt)
  if self.visible then
    local mx, my = love.mouse.getPosition()
    if CollideAABB(mx, my, self.x, self.y, self.width, self.height) then
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
end

--[[
proto Panel:ToString(NoTitle)
.D This function display all variables containing in the current Panel instance (tables and functions are excluded).
.P NoTitle
Indicates if the title must be displayed (false) or not (true).
]]--
function Panel:ToString(NoTitle)
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
Panel.__tostring = function(Panel, NoTitle) return Panel:ToString(NoTitle) end
Panel.__index = Panel
return Panel