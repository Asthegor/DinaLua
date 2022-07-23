local Button = {
  _TITLE       = 'Dina Game Engine - Button',
  _VERSION     = '2.0.4',
  _URL         = 'https://dina.lacombedominique.com/documentation/gui/button/',
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
local Parent = Dina:require("Panel")
setmetatable(Button, {__index = Parent})

-- Mandatory elements
local Text = Dina:require("Text")

--[[
proto Button.new(X, Y, Width, Height, Content, FontName, FontSize, TextColor, BackColor, Z)
.D This function creates a new Button object.
.P X
Position on the X axis of the button.
.P Y
Position on the Y axis of the button.
.P Width
Width of the space occupied by the button.
.P Height
Height of the space occupied by the button.
.P Content
Text of the button.
.P FontName
Name of the font text.
.P FontSize
Size of the text font.
.P TextColor
Color of the text.
.P BackColor
Back color of the button.
.P Z
Z-Order of the button.
.R Return an instance of Button object.
]]--
function Button.new(X, Y, Width, Height, Content, FontName, FontSize, TextColor, BackColor, Z)
  local self = setmetatable(Parent.new(X, Y, Width, Height, BackColor, BackColor, Z), Button)
  self.label = Text.new(Content, X, Y, Width, Height, TextColor, FontName, FontSize, "center", "center")
  self.pressed = false
  self.oldstate = false
  self.img = nil
  self.imghover = nil
  self.imgpressed = nil
  return self
end

--[[
proto Button:draw()
.D This function draw the button with its images if defined or with its colors.
]]--
function Button:draw()
  if self.visible then
    self:drawButton()
  end
end

--[[
proto Button:drawButton()
.D This function draw the button with its images if defined or with its colors.
]]--
function Button:drawButton()
  if self.pressed then
    if self.imgpressed == nil then
      self:drawPanel()
    else
      love.graphics.draw(self.imgpressed, self.x, self.y)
    end
  elseif self.hover then
    if self.imghover == nil then
      self:drawPanel()
    else
      love.graphics.draw(self.imghover, self.x, self.y)
    end
  else
    if self.img == nil then
      self:drawPanel()
    else
      love.graphics.draw(self.img, self.x, self.y)
    end
  end
  self.label:draw()
end

--[[
proto Button:getImages()
.D This function returns the images used for the button on each state : default, hover and pressed.
.R Returns the images used for default, hover and pressed state.
]]--
function Button:getImages()
  return self.img, self.imghover, self.imgpressed
end
--[[
proto Button:setImages(Default, Hover, Pressed)
.D This function sets the images used for default, hover and pressed state of the button and adjusts the width and height of the button.
.P Default
Image for the default state.
.P Hover
Image for the hover state.
.P Pressed
Image for the pressed state.
]]--
function Button:setImages(Default, Hover, Pressed)
  if Hover == nil then Hover = Default end
  if Pressed == nil then Pressed = Default end

  self.img = Default
  self.imghover = Hover
  self.imgpressed = Pressed
  self.width = math.max(Default:getWidth(), Hover:getWidth(), Pressed:getWidth())
  self.height = math.max(Default:getHeight(), Hover:getHeight(), Pressed:getHeight())
end

--[[
proto Button:setPosition(X, Y)
.D This function sets the position of the button and its label.
.P X
Coordonate on the X-axis.
.P Y
Coordonate on the Y-axis.
]]--
function Button:setPosition(X, Y)
  Parent.setPosition(self, X, Y)
  self.label:setPosition(X, Y)
end

--[[
proto Button:getTextDimensions()
.D This function returns the dimensions of the button label.
.R Width and height of the button label.
]]--
function Button:getTextDimensions()
  return self.label:getTextDimensions()
end

--[[
proto Button:setLabel(Text)
.D This functions sets the button label.
.P Text
Text of the button label.
]]--
function Button:setLabel(Text)
  self.label:setContent(Text)
end

--[[
proto Button:setLabelColor(Color)
.D This function sets the color of the button label.
.P Color
Color of the button label.
]]--
function Button:setLabelColor(Color)
  self.label:setTextColor(Color)
end

--[[
proto Button:setFont(FontName, FontSize)
.D This function sets the font of the button label.
.P FontName
Name of the font of the button label.
.P FontSize
Size of the font of the button label.
]]--
function Button:setFont(FontName, FontSize)
  self.label:setFont(FontName, FontSize)
end

--[[
proto Button:setFontSize(FontSize)
.D This function sets the font size of the button label.
.P FontSize
Size of the font of the button label.
]]--
function Button:setFontSize(FontSize)
  self.label:setFontSize(FontSize)
end

--[[
proto Button:update(dt)
.D This function triggers the action for the pressed event.
.P dt
Delta time.
]]--
function Button:update(dt)
  if self.visible then
    self:updatePanel(dt)
    if self.hover and love.mouse.isDown(1) and not self.pressed and not self.oldstate then
      self.pressed = true
    elseif self.pressed and not love.mouse.isDown(1) then
      self.pressed = false
    end
    if self.hover and self.pressed and not self.oldstate and love.mouse.isDown(1) and self.events["pressed"] then
      self.events["pressed"](self)
    end
    self.oldstate = love.mouse.isDown(1)
  end
end

--[[
proto Button:toString(NoTitle)
.D This function display all variables containing in the current Button instance (tables and functions are excluded).
.P NoTitle
Indicates if the title must be displayed (false) or not (true).
]]--
function Button:toString(NoTitle)
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
Button.__tostring = function(Button, NoTitle) return Button:toString(NoTitle) end
Button.__index = Button
Button.__name = "Button"
return Button