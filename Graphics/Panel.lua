local Panel = {
  _TITLE       = 'Dina Game Engine - Panel',
  _VERSION     = '2.0.4',
  _URL         = 'https://dina.lacombedominique.com/documentation/core/panel/',
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
setmetatable(Panel, {__index = Parent})

--[[
proto const Panel.new(X, Y, Width, Height, BorderColor, BackColor, Z, Thickness)
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
function Panel.new(X, Y, Width, Height, BorderColor, BackColor, Z, Thickness)
  -- Appel du constructeur du parent
  local self = setmetatable(Parent.new(X, Y), Panel)
  self:setDimensions(Width, Height)
  self:setBorderColor(BorderColor)
  self:setBackColor(BackColor)
  self:setZOrder(Z)
  self.thickness = Thickness or 1
  self.hover = false
  self.events = {}
  return self
end

--[[
proto Panel:draw()
.D This function draw the panel if visible.
]]--
function Panel:draw()
  if self.visible then
    self:drawPanel()
  end
end

--[[
proto Panel:drawPanel()
.D This function draw the panel (mainly used for child elements).
]]--
function Panel:drawPanel()
  love.graphics.setColor(1,1,1,1)
  if self.backcolor then
    love.graphics.setColor(self.backcolor)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
  end
  if self.bordercolor then
    love.graphics.setColor(self.bordercolor)
    love.graphics.setLineWidth(self.thickness)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
    love.graphics.setLineWidth(1)
  end
  love.graphics.setColor(1,1,1,1)
end

--[[
proto Panel:getWidth(Original)
.D This functions returns the width of the panel.
.P Original
Indique si on doit utiliser les dimensions originelles.
.R Returns the width of the panel.
]]--
function Panel:getWidth(Original)
  if not Original then
    return self.width
  end
  return self.originalwidth
end

--[[
proto Panel:getHeight(Original)
.D This functions returns the height of the panel.
.P Original
Indique si on doit utiliser les dimensions originelles.
.R Returns the height of the panel.
]]--
function Panel:getHeight(Original)
  if not Original then
    return self.height
  end
  return self.originalheight
end

--[[
proto Panel:getDimensions(Original)
.D Cette fonction retourne la largeur et la hauteur.
.P-f Original
Indique si on doit retourner les dimensions originelles.
.R Retourne la largeur et la hauteur.
]]--
function Panel:getDimensions(Original)
  return self:getWidth(Original), self:getHeight(Original)
end

--[[
proto Panel:setDimensions(Width, Height)
.D This function defines the new dimensions of the panel.
.P Width
Width of the space occupied by the panel.
.P Height
Height of the space occupied by the panel.
]]--
function Panel:setDimensions(Width, Height)
  self.width = SetDefaultNumber(Width, 0)
  self.height = SetDefaultNumber(Height, 0)
end

--[[
proto Panel:getThickness()
.D This functions returns the thickness of the border of the panel.
.R Returns the border thickness of the panel.
]]--
function Panel:getThickness()
  return self.thickness
end
--[[
proto Panel:setThickness(Thickness)
.D This functions sets the thickness of the border of the panel.
.P Thickness
New value for the thickness of the border (default: 1).
]]--
function Panel:setThickness(Thickness)
  Thickness = SetDefaultNumber(Thickness, 1)
  if Thickness < 0 then Thickness = 1 end
  self.thickness = Thickness
end

--[[
proto Panel:getBorderColor()
.D This functions returns the border color of the panel.
.R Returns the border color of the panel.
]]--
function Panel:getBorderColor()
  return self.bordercolor
end
--[[
proto Panel:setBorderColor(Color)
.D This function sets the border color of the panel.
.P Color
Color for the border (default : white).
]]--
function Panel:setBorderColor(Color)
  self.bordercolor = Color
end
--[[
proto Panel:getBackColor()
.D This functions returns the back color of the panel.
.R Returns the back color of the text.
]]--
function Panel:getBackColor()
  return self.backcolor
end
--[[
proto Panel:setBackColor(Color)
.D This function sets the back color of the panel.
.P Color
Color for the back of the panel
]]--
function Panel:setBackColor(Color)
  self.backcolor = Color
end

--[[
proto Panel:getZOrder()
.D This function returns the z-order of the panel.
.R Returns the z-order of the panel.
]]--
function Panel:getZOrder()
  return self.z
end

--[[
proto Panel:isZOrderChanged()
.D This function returns if the z-order has been changed.
.R Returns if the z-order changed.
]]--
function Panel:isZOrderChanged()
  return self.zorderchanged
end

--[[
proto Panel:setZOrder(Z)
.D This function sets the z-order of the panel.
.P Z
Z-order of the panel (default: 1).
]]--
function Panel:setZOrder(Z)
  local zorder = self.z
  self.z = SetDefaultNumber(Z, 0)
  if Z ~= zorder then
    self.zorderchanged = true
  end
end

--[[
proto Panel:setEvent(EventName, EventFunction)
.D This function sets an event by the given name with a given function.
]]--
function Panel:setEvent(EventName, EventFunction)
  if IsEventValid(EventName) then
    self.events[EventName] = EventFunction
  else
    print(string.format("DinaGE - ERROR: Event name '%s' invalid.", EventName))
  end
end

--[[
proto Panel:getScale()
.D This function returns the scales of the current Panel.
.R Returns the scale on X-axis and Y-axis.
]]--
function Panel:getScale()
  return self.sx, self.sy
end
--[[
proto Panel:setScale(ScaleX, ScaleY)
.D This function sets the scale to apply to the image and update the width and height of the panel.
]]--
function Panel:setScale(ScaleX, ScaleY)
  if self.originalwidth == nil then
    self.originalwidth = self.width or 1
  end
  if self.originalheight == nil then
    self.originalheight = self.height or 1
  end
  self.sx = ScaleX or 1
  self.sy = ScaleY or 1
  self.width = self.originalwidth*self.sx
  self.height = self.originalheight*self.sy
end
--[[
proto Panel:update(dt)
.D This funtion launches all updates needed for the current panel.
.P dt
Delta time.
]]--
function Panel:update(dt)
  if self.visible then
    self:updatePanel(dt)
  end
end

--[[
proto Panel:updatePanel(dt)
.D This function launches the hover event for the panel.
]]--
function Panel:updatePanel(dt)
  if self.events["hover"] then
    local mx, my = love.mouse.getPosition()
    if CollidePointRect(mx, my, self.x, self.y, self.width, self.height) then
      if not self.hover then
        self.hover = true
        self.events["hover"](self, "begin")
      end
    elseif self.hover then
      self.hover = false
      self.events["hover"](self, "end")
    end
  end
end

--[[
proto Panel:toString(NoTitle)
.D This function display all variables containing in the current Panel instance (tables and functions are excluded).
.P NoTitle
Indicates if the title must be displayed (false) or not (true).
]]--
function Panel:toString(NoTitle)
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
Panel.__tostring = function(Panel, NoTitle) return Panel:toString(NoTitle) end
Panel.__index = Panel
Panel.__name = "Panel"
return Panel