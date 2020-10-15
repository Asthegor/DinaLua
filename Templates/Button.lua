local Button = {
  _TITLE       = 'Dina GE Button',
  _VERSION     = '2.0.4',
  _URL         = 'https://dina.lacombedominique.com/documentation/templates/button/',
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

-- Parent
local CurrentFile = (...):gsub("^(.*/+)", "")
local CurrentFolder = (...):gsub('%/'..CurrentFile..'$', '')
local Parent = require(CurrentFolder.."/Panel")
setmetatable(Button, {__index = Parent})

-- Mandatory elements
local Text = require(CurrentFolder.."/Text")

--[[
proto Button.New(X, Y, Width, Height, Content, FontName, FontSize, TextColor, BackColor, Z)
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

--[[
proto Button:Draw()
.D This function draw the button with its images if defined or with its colors.
]]--
function Button:Draw()
  if self.visible then
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
end

--[[
proto Button:GetImages()
.D This function returns the images used for the button on each state : default, hover and pressed.
.R Returns the images used for default, hover and pressed state.
]]--
function Button:GetImages()
  return self.img, self.imghover, self.imgpressed
end
--[[
proto Button:SetImages(Default, Hover, Pressed)
.D This function sets the images used for default, hover and pressed state of the button and adjusts the width and height of the button.
.P Default
Image for the default state.
.P Hover
Image for the hover state.
.P Pressed
Image for the pressed state.
]]--
function Button:SetImages(Default, Hover, Pressed)
  if Hover == nil then Hover = Default end
  if Pressed == nil then Pressed = Default end

  self.img = Default
  self.imghover = Hover
  self.imgpressed = Pressed
  self.width = math.max(Default:getWidth(), Hover:getWidth(), Pressed:getWidth())
  self.height = math.max(Default:getHeight(), Hover:getHeight(), Pressed:getHeight())
end

--[[
proto Button:SetPosition(X, Y)
.D This function sets the position of the button and its label.
.P X
Coordonate on the X-axis.
.P Y
Coordonate on the Y-axis.
]]--
function Button:SetPosition(X, Y)
  Parent.SetPosition(self, X, Y)
  self.label:SetPosition(X, Y)
end

--[[
proto Button:GetTextDimensions()
.D This function returns the dimensions of the button label.
.R Width and height of the button label.
]]--
function Button:GetTextDimensions()
  return self.label:GetTextDimensions()
end

--[[
proto Button:SetLabel(Text)
.D This functions sets the button label.
.P Text
Text of the button label.
]]--
function Button:SetLabel(Text)
  self.label:SetContent(Text)
end

--[[
proto Button:SetLabelColor(Color)
.D This function sets the color of the button label.
.P Color
Color of the button label.
]]--
function Button:SetLabelColor(Color)
  self.label:SetTextColor(Color)
end

--[[
proto Button:SetFont(FontName, FontSize)
.D This function sets the font of the button label.
.P FontName
Name of the font of the button label.
.P FontSize
Size of the font of the button label.
]]--
function Button:SetFont(FontName, FontSize)
  self.label:SetFont(FontName, FontSize)
end

--[[
proto Button:SetFontSize(FontSize)
.D This function sets the font size of the button label.
.P FontSize
Size of the font of the button label.
]]--
function Button:SetFontSize(FontSize)
  self.label:SetFontSize(FontSize)
end

--[[
proto Button:Update(dt)
.D This function triggers the action for the pressed event.
.P dt
Delta time.
]]--
function Button:Update(dt)
  if self.visible then
    self:UpdatePanel(dt)
    if self.hover and love.mouse.isDown(1) and
    not self.pressed and not self.oldstate then
      self.pressed = true
    elseif self.pressed and not love.mouse.isDown(1) then
      self.pressed = false
    end
    if self.hover and not self.pressed and
    self.oldstate and love.mouse.isDown(1) and 
    self.events["pressed"] then
      self.events["pressed"](self)
    end
    self.oldstate = love.mouse.isDown(1)
  end
end

--[[
proto Button:ToString(NoTitle)
.D This function display all variables containing in the current Button instance (tables and functions are excluded).
.P NoTitle
Indicates if the title must be displayed (false) or not (true).
]]--
function Button:ToString(NoTitle)
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
Button.__tostring = function(Button, NoTitle) return Button:ToString(NoTitle) end
Button.__index = Button
return Button