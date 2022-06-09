local Slider = {
  _TITLE       = 'Dina Game Engine - Slider',
  _VERSION     = '2.0.4',
  _URL         = 'https://dina.lacombedominique.com/documentation/gui/slider/',
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
-- MANDATORY ELEMENTS
local Dina = require("Dina")
local Parent = Dina:require("Panel")
setmetatable(Slider, {__index = Parent})
-- Mandatory components
local Button = Dina:require("Button")


--[[
proto const Slider.new(X, Y, Width, Height, Value, Max, SliderColor, CursorColor, Orientation, Z)
.D This function creates a new Slider object.
.P X
Position on the X axis of the slider.
.P Y
Position on the Y axis of the slider.
.P Width
Width of the space occupied by the slider.
.P Height
Height of the space occupied by the slider.
.P Value
Current value of the slider.
.P Max
Max value of the slider.
.P SliderColor
Color of the slider (bar).
.P CursorColor
Color of the cursor.
.P Orientation
Orientation of the slider : horizontal or vertical.
.P Z
Z-Order of the slider.
.R Return an instance of Slider object.
]]--
function Slider.new(X, Y, Width, Height, Value, Max, SliderColor, CursorColor, Orientation, Z)
  local self = setmetatable(Parent.new(X, Y, Width, Height, nil, nil, Z), Slider)
  self.orientation = Orientation == "vertical" and Orientation or "horizontal"
  self.value = Value
  self.max = Max
  self.slidercolor = SliderColor or {1,1,1,1}
  local cursorx, cursory, cursorw, cursorh
  if self.orientation == "vertical" then
    self.thin = self.width * .2
    cursorw = self.width
    cursorh = self.thin
    self.step = (self.height - self.thin/2) / Max
    cursorx = self.x
    cursory = self.y + self.value * self.step
    self.xs = self.x + self.width/2 - self.thin/2
    self.ys = self.y
    self.ws = self.thin
    self.hs = self.height
  else
    self.thin = self.height * .2
    cursorw = self.thin
    cursorh = self.height
    self.step = (self.width - self.thin/2) / Max
    cursorx = self.x + self.value * self.step
    cursory = self.y
    self.xs = self.x
    self.ys = self.y + self.height/2 - self.thin/2
    self.ws = self.width
    self.hs = self.thin
  end
  self.cursor = Button.new(cursorx, cursory, cursorw, cursorh, "")
  self.cursor:setBorderColor(CursorColor)
  self.cursor:setBackColor(CursorColor)
  return self
end

--[[
proto Slider:changeCursorPosition()
.D This function change the position of the cursor on the slider based on its value.
]]--
function Slider:changeCursorPosition()
  local cursorx, cursory
  if self.orientation == "vertical" then
    cursorx = self.x
    cursory = self.y + self.value * self.step
  else
    cursorx = self.x + self.value * self.step
    cursory = self.y
  end
  self.cursor:setPosition(cursorx, cursory)
end

--[[
proto Slider:draw()
.D This function draw the slider if defined as visible.
]]--
function Slider:draw()
  if self.visible then
    love.graphics.setColor(self.slidercolor)
    love.graphics.rectangle("fill", self.xs, self.ys, self.ws, self.hs)
    love.graphics.setColor(1,1,1,1)
    self.cursor:draw()
    love.graphics.setColor(1,1,1,1)
  end
end

--[[
proto Slider:setColors(SliderColor, BorderCursorColor, BackCursorColor)
.D This function sets the colors for the slider and the cursor.
.P SliderColor
Color of the slider
.P BorderCursorColor
Color of the border of the cursor.
.P BackCursorColor
Color of the back of the cursor.
]]--
function Slider:setColors(SliderColor, BorderCursorColor, BackCursorColor)
  self.slidercolor = SliderColor
  self.cursor:setBorderColor(BorderCursorColor)
  self.cursor:setBackColor(BackCursorColor)
end

--[[
proto Slider:setPosition(X, Y)
.D This function define the new position of the slider.
.P X
.P Y
]]--
function Slider:setPosition(X, Y)
  self.x = X
  self.y = Y
  if self.orientation == "vertical" then
    self.xs = self.x + self.width/2 - self.thin/2
    self.ys = self.y
  else
    self.xs = self.x
    self.ys = self.y + self.height/2 - self.thin/2
  end
  self:changeCursorPosition()
end

--[[
proto Slider:getMaxValue()
.D This function returns the maximum value of the slider.
.R Maximum value of the slider.
]]--
function Slider:getMaxValue()
  return self.max
end

--[[
proto Slider:getValue()
.D This function returns the current value of the slider.
.R Value of the slider.
]]--
function Slider:getValue()
  return self.value
end

--[[
proto Slider:setMaxValue(Max)
.D This function defines the maximum value of the slider (greater or equal to 1) and change the value of the steps and the position of the cursor. The current value is updated regards of the given maximum value.
.P Max
Maximum value to set.
]]--
function Slider:setMaxValue(Max)
  if Max < 1 then Max = 1 end
  self.max = Max
  if self.max > self.value then
    self:setValue(self.max)
  end
  if self.orientation == "vertical" then
    self.step = (self.height - self.thin/2) / Max
  else
    self.step = (self.width - self.thin/2) / Max
  end
  self:changeCursorPosition()
end

--[[
proto Slider:setValue(Value)
.D This function set the current value of the slider and change the position of the cursor.
.P Value
Value to set.
]]--
function Slider:setValue(Value)
  if Value >= 0 and Value <= self.max then
    self.value = Value
    self:changeCursorPosition()
  end
end

--[[
proto Slider:update(dt)
.D This function update the cursor position when the mouse dragged it.
.P dt
Delta time.
]]--
function Slider:update(dt)
  if self.visible then
    self:updatePanel(dt)
    self.cursor:update(dt)
    if self.cursor.pressed and love.mouse.isDown(1) then
      if self.orientation == "vertical" then
        local my = love.mouse.getY()
        if my < self.cursor.y then
          local newval = math.floor((self.cursor.y-my) / self.step)
          self:setValue(self.value - newval)
        elseif my > self.cursor.y+self.cursor.height then
          local newval = math.floor((my-self.cursor.y-self.cursor.height) / self.step)
          self:setValue(self.value + newval)
        end
      else
        local mx = love.mouse.getX()
        if mx < self.cursor.x then
          local newval = math.floor((self.cursor.x-mx) / self.step)
          self:setValue(self.value - newval)
        elseif mx > self.cursor.x+self.cursor.width then
          local newval = math.floor((mx-self.cursor.x-self.cursor.width) / self.step)
          self:setValue(self.value + newval)
        end
      end
    end
  end
end

--[[
proto Slider:toString(NoTitle)
.D This function display all variables containing in the current Slider instance (tables and functions are excluded).
.P NoTitle
Indicates if the title must be displayed (false) or not (true).
]]--
function Slider:toString(NoTitle)
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
Slider.__tostring = function(Slider, NoTitle) return Slider:toString(NoTitle) end
Slider.__index = Slider
Slider.__name = "Slider"
return Slider