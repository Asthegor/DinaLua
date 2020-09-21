local Slider = {}

-- Déclaration du parent
local CurrentFile = (...):gsub("^(.*/+)", "")
local CurrentFolder = (...):gsub('%/'..CurrentFile..'$', '')
local Parent = require(CurrentFolder.."/Panel")
setmetatable(Slider, {__index = Parent})

local Button = require(CurrentFolder.."/Button")

function Slider.New(X, Y, Width, Height, Value, Max, SliderColor, CursorColor, Type, Z)
  local self = setmetatable(Parent.New(X, Y, Width, Height, nil, nil, Z), Slider)
  self.type = Type == "vertical" and Type or "horizontal"
  self.value = Value
  self.max = Max
  self.slidercolor = SliderColor or {1,1,1,1}
  local cursorx, cursory, cursorw, cursorh
  if self.type == "vertical" then
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
  self.cursor = Button.New(cursorx, cursory, cursorw, cursorh, "")
  self.cursor:SetBorderColor(CursorColor)
  self.cursor:SetBackColor(CursorColor)
  return self
end

function Slider:ChangeCursorPosition()
  local cursorx, cursory
  if self.type == "vertical" then
    cursorx = self.x
    cursory = self.y + self.value * self.step
  else
    cursorx = self.x + self.value * self.step
    cursory = self.y
  end
  self.cursor:SetPosition(cursorx, cursory)
end

function Slider:Draw()
  if self.visible then
    self:DrawSlider()
  end
end

function Slider:DrawSlider()
  love.graphics.setColor(self.slidercolor)
  love.graphics.rectangle("fill", self.xs, self.ys, self.ws, self.hs)
  love.graphics.setColor(1,1,1,1)
  self.cursor:Draw()
  love.graphics.setColor(1,1,1,1)
end

function Slider:SetColors(SliderColor, BorderCursorColor, BackCursorColor)
  self.slidercolor = SliderColor
  self.cursor:SetBorderColor(BorderCursorColor)
  self.cursor:SetBackColor(BackCursorColor)
end

function Slider:SetPosition(X, Y)
  self.x = X
  self.y = Y
  if self.type == "vertical" then
    self.xs = self.x + self.width/2 - self.thin/2
    self.ys = self.y
  else
    self.xs = self.x
    self.ys = self.y + self.height/2 - self.thin/2
  end
  self:ChangeCursorPosition()
end


function Slider:GetMaxValue()
  return self.max
end

function Slider:GetValue()
  return self.value
end

function Slider:SetMaxValue(pMax)
  self.max = pMax
end

function Slider:SetValue(pValue)
  if pValue >= 0 and pValue <= self.max then
    self.value = pValue
    self:ChangeCursorPosition()
  end
end


function Slider:Update(dt)
  if self.visible then
    self:UpdateSlider(dt)
  end
end

function Slider:UpdateSlider(dt)
  dt = math.min(dt, 1/60)
  self:UpdatePanel(dt)
  self.cursor:Update(dt)
  if self.cursor.pressed and love.mouse.isDown(1) then
    if self.type == "vertical" then
      local my = love.mouse.getY()
      if my < self.cursor.y then
        local newval = math.floor((self.cursor.y-my) / self.step)
        self:SetValue(self.value - newval)
      elseif my > self.cursor.y+self.cursor.height then
        local newval = math.floor((my-self.cursor.y-self.cursor.height) / self.step)
        self:SetValue(self.value + newval)
      end
    else
      local mx = love.mouse.getX()
      if mx < self.cursor.x then
        local newval = math.floor((self.cursor.x-mx) / self.step)
        self:SetValue(self.value - newval)
      elseif mx > self.cursor.x+self.cursor.width then
        local newval = math.floor((mx-self.cursor.x-self.cursor.width) / self.step)
        self:SetValue(self.value + newval)
      end
    end
  end
end


Slider.__call = function() return Slider.new() end
Slider.__tostring = function() return "DinaGE GUI Slider" end
Slider.__index = Slider
return Slider