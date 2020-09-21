local ProgressBar = {}

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

ProgressBar.__index = ProgressBar
return ProgressBar