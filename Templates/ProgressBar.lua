local ProgressBar = {
  _TITLE       = 'Dina GE ProgressBar',
  _VERSION     = '2.0.3',
  _URL         = 'https://dina.lacombedominique.com/documentation/templates/progressbar/',
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
local Parent = require(CurrentFolder.."/Panel")
setmetatable(ProgressBar, {__index = Parent})

function ProgressBar.New(X, Y, Width, Height, Value, Max, FrontColor, BorderColor, BackColor, Z, BorderThickness)
  local self = setmetatable(Parent.New(X, Y, Width, Height, BorderColor, BackColor, Z, BorderThickness), ProgressBar)
  self:SetColor(FrontColor, BorderColor, BackColor)
  self.value = Value
  self.max = Max or Value
  self.imgback = nil
  self.imgbar = nil

  return self
end

function ProgressBar:Draw()
  if self.visible then
    self:DrawProgressBar()
  end
end

function ProgressBar:DrawProgressBar()
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

function ProgressBar:GetMaxValue()
  return self.max
end

function ProgressBar:GetValue()
  return self.value
end

function ProgressBar:SetImages(Back, Bar)
  self.imgback = Back
  self.imgbar = Bar
  self.width = Back:getWidth()
  self.height = Back:getHeight()
end

function ProgressBar:SetColor(FrontColor, BorderColor, BackColor)
  self.frontcolor = FrontColor or self.frontcolor or {1, 1, 1, 1}
  self:SetBorderColor(BorderColor or self.bordercolor or {1, 1, 1, 1})
  self:SetBackColor(BackColor or self.backcolor or {0.5, 0.5, 0.5, 0.5})
end

function ProgressBar:SetChangeTimer(Timer, Value)
  self.changetimer = Timer or 0
  self.changevalue = Value or 0
  self.timer = 0
end


function ProgressBar:SetValue(Value)
  if Value < 0 then Value = 0 end
  if Value > self.max then Value = self.max end
  self.value = Value
end

function ProgressBar:Update(dt)
  if self.visible then
    self:UpdateProgressBar(dt)
  end
end

function ProgressBar:UpdateProgressBar(dt)
  if self.changetimer and self.changevalue then
    dt = math.min(dt, 1/60)
    self.timer = self.timer + dt
    if self.timer > self.changetimer then
      self:SetValue(self.value + self.changevalue)
      self.timer = 0
    end
  end
end

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
ProgressBar.__tostring = function(ProgressBar, NoTitle) return ProgressBar:ToString(NoTitle) end
ProgressBar.__index = ProgressBar
return ProgressBar