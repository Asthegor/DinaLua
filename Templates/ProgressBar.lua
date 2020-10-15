local ProgressBar = {
  _TITLE       = 'Dina GE ProgressBar',
  _VERSION     = '2.0.4',
  _URL         = 'https://dina.lacombedominique.com/documentation/templates/progressbar/',
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
local Parent = require(CurrentFolder.."/Panel")
setmetatable(ProgressBar, {__index = Parent})

--[[
proto const ProgressBar.New(X, Y, Width, Height, Value, Max, FrontColor, BorderColor, BackColor, Z, BorderThickness)
.D This function creates a new ProgressBar object.
.P X
Position on the X axis of the progress bar.
.P Y
Position on the Y axis of the progress bar.
.P Width
Width of the space occupied by the progress bar.
.P Height
Height of the space occupied by the progress bar.
.P Value
Current value of the progress bar.
.P Max
Max value of the progress bar.
.P FrontColor
Front color of the progress bar.
.P BorderColor
Border color of the progress bar.
.P BackColor
Back color of the progress bar.
.P Z
Z-Order of the progress bar.
.P BorderThickness
Thickness of the border.
.R Return an instance of ProgressBar object.
]]--
function ProgressBar.New(X, Y, Width, Height, Value, Max, FrontColor, BorderColor, BackColor, Z, BorderThickness)
  local self = setmetatable(Parent.New(X, Y, Width, Height, BorderColor, BackColor, Z, BorderThickness), ProgressBar)
  self:SetColor(FrontColor, BorderColor, BackColor)
  self.value = Value
  self.max = Max or Value
  self.imgback = nil
  self.imgbar = nil

  return self
end

--[[
proto ProgressBar:Draw()
.D This function draw the progress bar with its image if define; otherwise with its colors.
]]--
function ProgressBar:Draw()
  if self.visible then
    love.graphics.setColor(1,1,1,1)
    local barsize = (self.width - 2) * (self.value / self.max)
    if self.imgback and self.imgbar then
      love.graphics.draw(self.imgback, self.x, self.y)
      local barquad = love.graphics.newQuad(0, 0, barsize, self.height, self.width, self.height)
      love.graphics.draw(self.imgbar, barquad, self.x, self.y)
    else
      self:DrawPanel()
      love.graphics.setColor(self.frontcolor)
      love.graphics.rectangle("fill", self.x + 1, self.y + 1, barsize, self.height - 2)
    end
    love.graphics.setColor(1,1,1,1)
  end
end

--[[
proto ProgressBar:GetMaxValue()
.D This function returns the max value of the progress bar.
.R Max value of the progress bar.
]]--
function ProgressBar:GetMaxValue()
  return self.max
end

--[[
proto ProgressBar:GetValue()
.D This function returns the current value of the progress bar.
.R Current value of the progress bar.
]]--
function ProgressBar:GetValue()
  return self.value
end

--[[
proto ProgressBar:SetImages(Back, Bar)
.D This function sets the back and front image to draw the progress bar. The progress bar is adjusted to the dimensions of the image used for the back.
.P Back
Image used for the back.
.P Bar
Image used to draw the bar.
]]--
function ProgressBar:SetImages(Back, Bar)
  self.imgback = Back
  self.imgbar = Bar
  self.width = Back:getWidth()
  self.height = Back:getHeight()
end

--[[
proto ProgressBar:SetColor(FrontColor, BorderColor, BackColor)
.D This function sets the colors of the progress bar.
.P FrontColor
Color for the front.
.P BorderColor
Color for the border.
.P BackColor
Color for the back.
]]--
function ProgressBar:SetColor(FrontColor, BorderColor, BackColor)
  self.frontcolor = FrontColor or self.frontcolor or {1, 1, 1, 1}
  self:SetBorderColor(BorderColor or self.bordercolor or {1, 1, 1, 1})
  self:SetBackColor(BackColor or self.backcolor or {0.5, 0.5, 0.5, 0.5})
end

--[[
proto ProgressBar:SetChangeTimer(Timer, Value)
.D This function defines the values for the automatic fill.
.P Timer
Duration to wait before an automatic update of the value.
.P Value
Value to increase the progress bar.
]]--
function ProgressBar:SetChangeTimer(Timer, Value)
  self.changetimer = Timer or 0
  self.changevalue = Value or 0
  self.timer = 0
end

--[[
proto ProgressBar:SetValue(Value)
.D This function sets the current value of the progress bar.
.P Value
Current value of the progress bar (must be between 0 and Max).
]]--
function ProgressBar:SetValue(Value)
  if Value < 0 then Value = 0 end
  if Value > self.max then Value = self.max end
  self.value = Value
end

--[[
proto ProgressBar:Update(dt)
.D This funtion launches all updates needed for the current progress bar.
.P dt
Delta time.
]]--
function ProgressBar:Update(dt)
  if self.visible then
    if self.changetimer and self.changevalue then
      self.timer = self.timer + dt
      if self.timer > self.changetimer then
        self:SetValue(self.value + self.changevalue)
        self.timer = 0
      end
    end
  end
end

--[[
proto ProgressBar:ToString(NoTitle)
.D This function display all variables containing in the current ProgressBar instance (tables and functions are excluded).
.P NoTitle
Indicates if the title must be displayed (false) or not (true).
]]--
function ProgressBar:ToString(NoTitle)
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
ProgressBar.__tostring = function(ProgressBar, NoTitle) return ProgressBar:ToString(NoTitle) end
ProgressBar.__index = ProgressBar
return ProgressBar