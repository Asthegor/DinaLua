local CheckBox = {}

-- Déclaration du parent
local CurrentFile = (...):gsub("^(.*/+)", "")
local CurrentFolder = (...):gsub('%/'..CurrentFile..'$', '')
local Parent = require(CurrentFolder.."/Panel")
setmetatable(CheckBox, {__index = Parent})


function CheckBox.New(X, Y, Width, Height, Color, Thickness)
  local self = setmetatable(Parent.New(X, Y, Width, Height, Color, nil, nil, Thickness), CheckBox)
  self:SetColor(Color)
  self.pressed = false
  self.oldstate = false
  self.img = nil
  self.imgpressed = nil
  return self
end

function CheckBox:Draw()
  if self.visible then
    self:DrawCheckBox()
  end
end

function CheckBox:DrawCheckBox()
  love.graphics.setColor(1,1,1,1)
  if self.pressed then
    if self.imgpressed == nil then
      self:DrawPanel()
      love.graphics.setColor(self.color)
      love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    else
      love.graphics.draw(self.imgpressed, self.x, self.y)
    end
  else
    if self.img == nil then
      self:DrawPanel()
    else
      love.graphics.draw(self.img, self.x, self.y)
    end
  end
  love.graphics.setColor(1,1,1,1)
end

function CheckBox:SetColor(Color)
  self.color = Color
  self:SetBorderColor(Color)
end

function CheckBox:SetImages(Default, Pressed)
  if Pressed == nil then Pressed = Default end
  self.img = Default
  self.imgpressed = Pressed
  self.width = math.max(Default:getWidth(), Pressed:getWidth()) + self.font:getWidth(" ") + self.twidth
  self.height = math.max(Default:getHeight(), Pressed:getHeight(), self.font:getHeight(1))
end

function CheckBox:SetState(pState)
  self.pressed = pState
end

function CheckBox:Update(dt)
  self:UpdatePanel(dt)
  if self.hover and love.mouse.isDown(1) and
     not self.pressed and not self.oldstate then
    self.pressed = true
    if self.events["pressed"] then
      self.events["pressed"]("on")
    end
  elseif self.hover and love.mouse.isDown(1) and
     self.pressed and not self.oldstate then
    self.pressed = false
    if self.events["pressed"] then
      self.events["pressed"]("off")
    end
  end
  self.oldstate = love.mouse.isDown(1)
end

CheckBox.__index = CheckBox
return CheckBox