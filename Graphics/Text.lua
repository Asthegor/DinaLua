local Text = {
  _TITLE       = 'Dina Game Engine - Text',
  _VERSION     = '2.0.4',
  _URL         = 'https://dina.lacombedominique.com/documentation/gui/text/',
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
-- Declaration of the parent
local Dina = require("Dina")
local Parent = Dina:require("Panel")
setmetatable(Text, {__index = Parent})

--[[
proto const Text.new(Content, X, Y, Width, Height, Color, FontName, FontSize, HAlign, VAlign, Z, WaitTime, DisplayTime, NbLoop)
.D This function creates a new Text object.
.P Content
Content of the text.
.P X
Position on the X axis of the text.
.P Y
Position on the Y axis of the text.
.P Width
Width of the space occupied by the text.
.P Height
Height of the space occupied by the text.
.P TextColor
Color of the text.
.P FontName
Name and path of the font file.
.P FontSize
Size of the text.
.P HAlign
Horizontal alignment.
.P VAlign
Vertical alignment.
.P Z
Z-Order of the text.
.P WaitTime
Duration before displaying the text.
.P DisplayTime
Duration for showing the text.
.P NbLoop
Number of time the text will be shown (all durations will also be repeat).
.R Return an instance of Text object.
]]--
function Text.new(Content, X, Y, Width, Height, TextColor, FontName, FontSize, HAlign, VAlign, Z, WaitTime, DisplayTime, NbLoop)
  local self = setmetatable(Parent.new(X, Y, Width, Height, Z), Text)
  self:setFont(FontName, FontSize)
  self:setContent(Content)
  if not Width then Width = self:getTextWidth() end
  if not Height then Height = self:getTextHeight(true) end
  self:setDimensions(Width, Height)
  self:setAlignments(HAlign, VAlign)
  self:setTextColor(TextColor)
  self:setTimers(WaitTime, DisplayTime, NbLoop)
  return self
end

--[[
proto Text:draw()
.D This function draw the text with its color and font. The text is aligned horizontally and vertically inside the width and height defined during its creation (by default, upper left).
]]--
function Text:draw()
  if self.visible then
    if self.isVisible then
      local oldFont = love.graphics.getFont()
      love.graphics.setColor(self.textcolor)
      love.graphics.setFont(self.font)
      local x = self.x
      local y = self.y
      if self.valign == "center" then
        y = y + (self.height - self:getTextHeight()) / 2
      elseif self.valign == "bottom" then
        y = y + self.height - self:getTextHeight()
      end
      if self.backcolor then
        self:drawPanel()
      end
      love.graphics.printf(self.content, x, y, self.width, self.halign)
      love.graphics.setFont(oldFont)
      love.graphics.setColor(1,1,1,1)
    end
  end
end

--[[
proto Text:getContent()
.D This functions returns the content of the text.
.R Returns the content of the text.
]]--
function Text:getContent()
  return self.content
end
--[[
proto Text:setContent(Content)
.D This function sets the text to display. If the text received is nil or an empty string, the timers are reseted.
.P Content
Text to display.
]]--
function Text:setContent(Content)
  if not Content then
    Content = ""
  end
  local bUpdate = (self.content == "" or self.content == nil)
  self.content = Content
  if self.content == "" then
    self:resetTimers()
  end
  if bUpdate then
    self:setDimensions(self:getTextWidth(), self:getTextHeight())
  end
end

--[[
proto Text:getFont()
.D This function returns the font defined for the text
.R Font of the text
]]--
function Text:getFont()
  local font = self.font
  if not font then
    font = love.graphics.getFont()
  end
  return font
end
--[[
proto Text:setFont(FontName, FontSize)
.D This function sets the font and size of the text. If the FontName is nil, no font is set. The width and height of the text are updated.
.P FontName
Path and name of the font to use to display the text. Should not be nil.
.P FontSize
Font size of the text.
]]--
function Text:setFont(FontName, FontSize)
  if FontName == nil or FontName == "" then
    self.font = love.graphics.getFont()
  end
  if FontName ~= nil and FontName ~= "" then
    self.fontname = FontName
    if FontSize ~= nil and FontSize ~= "" then
      self:setFontSize(FontSize)
    else
      self:setFontSize(self:getTextHeight(true))
    end
  else
  end
end
--[[
proto Text:setFontSize(Size)
.D This function changes the font size of the text. If no font has been set, the current text size will remain. The width and height of the text are updated.
.P Size
New font size.
]]--
function Text:setFontSize(Size)
  assert(IsNumber(Size), "ERROR: Size must be a valid number.")
  if self.fontname then
    self.fontsize = Size
    self.font = love.graphics.newFont(self.fontname, Size)
  else
    self.font = love.graphics.newFont(Size)
  end
  self:setDimensions(self:getTextWidth(), self:getTextHeight(true))
end

--[[
proto Text:getTextColor()
.D This function returns the color of the text.
.R Color of the text
]]--
function Text:getTextColor()
  return self.textcolor
end

--[[
proto Text:setTextColor(Color)
.D This function change the color of the text with the given color.
.P Color
New color of the text.
]]--
function Text:setTextColor(Color)
  if not IsColorValid(Color) then
    Color = Colors.WHITE
  end
  self.textcolor = Color
end

--[[
proto Text:getTextHeight()
.D This function returns the height of the text.
.R Height of the text
]]--
function Text:getTextHeight(Reset)
  if not self.content then
    return 0
  end
  local font = self:getFont()
  if Reset or self.width == 0 then
    return font:getHeight()
  end
  local width, wrappedtext = font:getWrap(self.content, self.width)
  return font:getHeight() * #wrappedtext
end

--[[
proto Text:getTextWidth()
.D This function returns the width of the text.
.R Width of the text.
]]--
function Text:getTextWidth()
  if not self.content then
    return 0
  end
  local font = self:getFont()
  return font:getWidth(self.content)
end

--[[
proto Text:getTextDimensions()
.D This function returns the width and height of the text
.R Width and height of the text
]]--
function Text:getTextDimensions()
  return self:getTextWidth(), self:getTextHeight()
end

--[[
proto Text:getAlignments()
.D This function returns the alignments of the text.
.R Horizontal and vertical alignments of the text.
]]--
function Text:getAlignments()
  return self.halign, self.valign
end

--[[
proto Text:setAlignments(HAlign, VAlign)
.D This function defines the horizontal and vertical alignments of the text.
.P HAlign
Horizontal alignment of the text. Can be "left", "center" or "right" (default : left).
.P VAlign
Vertical alignment of the text. Can be "up", "center" or "bottom (default : up)
]]--
function Text:setAlignments(HAlign, VAlign)
  HAlign = string.lower(HAlign or "")
  if HAlign ~= "left" and HAlign ~= "center" and HAlign ~= "right" then
    HAlign = "left"
  end
  self.halign = HAlign
  VAlign = string.lower(VAlign or "")
  if VAlign ~= "up" and VAlign ~= "center" and VAlign ~= "bottom" then
    VAlign = "up"
  end
  self.valign = VAlign
end

--[[
proto Text:resetTimers()
.D This function sets the timers to -1 for the display time, 0 for the waiting time ans -1 for the number of loops. Those values display the text without any effect.
]]--
function Text:resetTimers()
  self:setTimers(-1, -1, -1)
end

--[[
proto Text:setTimers(WaitTime, DisplayTime, NbLoop)
.D This function sets the timers used for displaying the text.
.P WaitTime
Duration before displaying the text.
.P DisplayTime
Duration for showing the text.
.P NbLoop
Number of time the text will be shown (all durations will also be repeat).
]]--
function Text:setTimers(WaitTime, DisplayTime, NbLoop)
  -- waiting time before display
  self.waitTime = SetDefaultNumber(WaitTime, -1)
  self.timerWait = self.waitTime
  -- display time
  self.displayTime = SetDefaultNumber(DisplayTime, -1)
  self.timerDisplay = self.displayTime
  -- number of loops
  self.nbloop = SetDefaultNumber(NbLoop, -1)

  if not DisplayTime and not NbLoop then
    self.isVisible = true
  end
end

--[[
proto Text:update(dt)
.D This funtion launches all updates needed for the current text.
.P dt
Delta time.
]]--
function Text:update(dt)
  if self.nbloop == 0 then
    return
  end
  self.isVisible = false
  if self.waitTime <= 0 and self.displayTime < 0 then
    self.isVisible = true
    return
  elseif self.waitTime <= 0 then
    self.isVisible = true
    self.timerDisplay = self.timerDisplay - dt
    if self.timerDisplay < 0 then
      self.isVisible = false
      if self.nbloop > 0 then
        self.nbloop = self.nbloop - 1
      end
      self.timerWait = self.waitTime
      self.timerDisplay = self.displayTime
    end
  else
    self.timerWait = self.timerWait - dt
    if self.timerWait < 0 then
      self.isVisible = true
      if self.displayTime >= 0 then
        self.timerDisplay = self.timerDisplay - dt
        if self.timerDisplay < 0 then
          self.isVisible = false
          if self.nbloop > 0 then
            self.nbloop = self.nbloop - 1
          end
          self.timerWait = self.waitTime
          self.timerDisplay = self.displayTime
        end
      end
    end
  end
end

--[[
proto Text:toString(NoTitle)
.D This function display all variables containing in the current Text instance (tables and functions are excluded).
.P NoTitle
Indicates if the title must be displayed (false) or not (true).
]]--
function Text:toString(NoTitle)
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
Text.__tostring = function(Text, NoTitle) return Text:toString(NoTitle) end
Text.__index = Text
Text.__name = "Text"
return Text