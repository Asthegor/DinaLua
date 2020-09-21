local Button = {}

-- Déclaration du parent
local CurrentFile = (...):gsub("^(.*/+)", "")
local CurrentFolder = (...):gsub('%/'..CurrentFile..'$', '')
local Parent = require(CurrentFolder.."/Panel")
setmetatable(Button, {__index = Parent})

-- Déclaration des éléments supplémentaires
local Text = require(CurrentFolder.."/Text")

function Button.New(X, Y, Width, Height, Content, FontName, FontSize, TextColor, BackColor, Z)
  local self = setmetatable(Parent.New(X, Y, Width, Height, Z, BackColor, BackColor), Button)
  self.label = Text.New(Content, X, Y, Width, Height, TextColor, FontName, FontSize, "center", "center")
  self.pressed = false
  self.oldstate = false
  self.img = nil
  self.imghover = nil
  self.imgpressed = nil
  return self
end
--
function Button:Draw()
  if self.visible then
    self:DrawButton()
  end
end
function Button:DrawButton()
  if self.pressed then
    if self.imgpressed == nil then
      self:DrawPanel()
    else
      love.graphics.draw(self.imgpressed, self.x, self.y)
    end
  elseif self.hover then
    if self.imghover == nil then
      self:DrawPanel()
    else
      love.graphics.draw(self.imghover, self.x, self.y)
    end
  else
    if self.img == nil then
      self:DrawPanel()
    else
      love.graphics.draw(self.img, self.x, self.y)
    end
  end
  self.label:Draw()
end
--
function Button:GetImages()
  return self.img, self.imghover, self.imgpressed
end
--
function Button:SetImages(pDefault, pHover, pPressed)
  if pHover == nil then pHover = pDefault end
  if pPressed == nil then pPressed = pDefault end
    
  self.img = pDefault
  self.imghover = pHover
  self.imgpressed = pPressed
  self.width = math.max(pDefault:getWidth(), pHover:getWidth(), pPressed:getWidth())
  self.height = math.max(pDefault:getHeight(), pHover:getHeight(), pPressed:getHeight())
end
--
function Button:SetPosition(pX, pY)
  Parent.SetPosition(self, pX, pY)
  self.label:SetPosition(pX, pY)
end
--
function Button:GetTextDimensions()
  return self.label:GetTextDimensions()
end

function Button:SetContent(pText)
  self.label:SetContent(pText)
end
--
function Button:SetTextColor(pColor)
  self.label:SetTextColor(pColor)
end
--
function Button:SetFont(FontName, FontSize)
  self.label:SetFont(FontName, FontSize)
end
--
function Button:SetFontSize(FontSize)
  self.label:SetFontSize(FontSize)
end
--
function Button:Update(dt)
  self:UpdatePanel(dt)
  if self.hover and love.mouse.isDown(1) and
     not self.pressed and not self.oldstate then
    self.pressed = true
  elseif self.pressed and not love.mouse.isDown(1) then
    self.pressed = false
  end
  if self.hover and not self.pressed and
     self.oldstate and not love.mouse.isDown(1) and 
     self.events["pressed"] then
    self.events["pressed"](self)
  end
  self.oldstate = love.mouse.isDown(1)
end
--
Button.__call = function() return Button.New() end
Button.__tostring = function() return "DinaGE GUI Button" end
Button.__index = Button
return Button