local CheckBox = {
  _TITLE       = 'Dina Game Engine - CheckBox',
  _VERSION     = '3.0.0',
  _URL         = 'https://dina.lacombedominique.com/documentation/gui/checkbox/',
  _LICENSE     = [[
Copyright (c) 2022 LACOMBE Dominique
ZLIB Licence
This software is provided 'as-is', without any express or implied warranty. In no event will the authors be held liable for any damages arising from the use of this software.
Permission is granted to anyone to use this software for any purpose, including commercial applications, and to alter it and redistribute it freely, subject to the following restrictions:
    1. The origin of this software must not be misrepresented; you must not claim that you wrote the original software. If you use this software in a product, an acknowledgment in the product documentation would be appreciated but is not required.
    2. Altered source versions must be plainly marked as such, and must not be misrepresented as being the original software.
    3. This notice may not be removed or altered from any source distribution.
]]
}

-- Parent
local Dina = require("Dina")
local Parent = Dina:require("Panel")
setmetatable(CheckBox, {__index = Parent})

-- Local functions
local function OnPressedEvent()
end
local function OnHoverEvent()
end

--[[
proto const CheckBox.new(X, Y, Width, Height, Color, Thickness, Z)
.D This function creates a new CheckBox object.
.P X
Position on the X axis of the progress bar.
.P Y
Position on the Y axis of the progress bar.
.P Width
Width of the space occupied by the progress bar.
.P Height
Height of the space occupied by the progress bar.
.P Color
color of the checkbox.
.P Thickness
Thickness of the checkbox.
.P Z
Z-Order of the checkbox.
.R Return an instance of CheckBox object.
]]--
function CheckBox.new(X, Y, Width, Height, Color, Thickness, Z)
  local self = setmetatable(Parent.new(X, Y, Width, Height, Color, nil, nil, Z, Thickness), CheckBox)
  self:setColor(Color)
  self.pressed = false
  self.oldstate = false
  self.img = nil
  self.imgpressed = nil
  self:setEvent("hover", OnHoverEvent)
  self:setEvent("pressed", OnPressedEvent)
  return self
end

--[[
proto CheckBox:draw()
.D This function draw the checkbox with its image if defined or with its colors.
]]--
function CheckBox:draw()
  if self.visible then
    love.graphics.setColor(1,1,1,1)
    if self.pressed then
      if self.imgpressed == nil then
        self:drawPanel()
        love.graphics.setColor(self.color)
        love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
      else
        self.imgpressed:draw(self.color)
      end
    else
      if self.img == nil then
        self:drawPanel()
      else
        self.img:draw(self.color)
      end
    end
    love.graphics.setColor(1,1,1,1)
  end
end

--[[
proto CheckBox:setColor(Color)
.D This function defines the color of the checkbox if no image has been set.
.P Color
Color of the checkbox.
]]--
function CheckBox:setColor(Color)
  self.color = Color
  self:setBorderColor(Color)
end

--[[
proto CheckBox:setImages(Unchecked, Checked)
.D This function sets the images for unchecked and checked status and adjusts the width and height of the component.
.P Unchecked
Path of the image used when the checkbox is not checked.
.P Checked
Path of the image used when the checkbox is checked.
]]--
function CheckBox:setImages(Unchecked, Checked)
  if Checked == nil then Checked = Unchecked end
  self.img = Dina("Image", Unchecked, self.x, self.y)
  Dina:removeComponent(self.img)
  self.imgpressed = Dina("Image", Checked, self.x, self.y)
  Dina:removeComponent(self.imgpressed)
  
  local uw, uh = self.imgpressed:getDimensions()
  local cw, ch = self.img:getDimensions()
  self.width = math.max(uw, cw)
  self.height = math.max(uh, uh)
  
  local ix = self.x + (self.width - cw) / 2
  local iy = self.y + (self.height - ch) / 2
  self.img:setPosition(ix, iy)
  
  ix = self.x + (self.width - uw) / 2
  iy = self.y + (self.height - uh) / 2
  self.imgpressed:setPosition(ix, iy)
end

--[[
proto CheckBox:setState(State)
.D This function sets the current state of the checkbox.
.P State
State of the checkbox. True for check, false otherwise.
]]--
function CheckBox:setState(State)
  self.pressed = State
end

--[[
proto CheckBox:update(dt)
.D This funtion updates the status of the checkbox if the user click on it.
.P dt
Delta time.
]]--
function CheckBox:update(dt)
  self:updatePanel(dt)
  if self.hover and love.mouse.isDown(1) and not self.oldstate then
    self:setState(not self.pressed)
  end
  self.oldstate = love.mouse.isDown(1)
end

--[[
proto CheckBox:toString(NoTitle)
.D This function display all variables containing in the current Base instance (tables and functions are excluded).
.P NoTitle
Indicates if the title must be displayed (false) or not (true).
]]--
function CheckBox:toString(NoTitle)
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
CheckBox.__tostring = function(CheckBox, NoTitle) return CheckBox:toString(NoTitle) end
CheckBox.__index = CheckBox
CheckBox.__name = "CheckBox"
return CheckBox