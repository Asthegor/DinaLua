local Text = {
  _TITLE       = 'Dina GE Text',
  _VERSION     = '2.0.4',
  _URL         = 'https://dina.lacombedominique.com/documentation/templates/text/',
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
local CurrentFile = (...):gsub("^(.*/+)", "")
local CurrentFolder = (...):gsub('%/'..CurrentFile..'$', '')
local Parent = require(CurrentFolder.."/Panel")
setmetatable(Text, {__index = Parent})

--[[
proto const Text.New(Content, X, Y, Width, Height, Color, FontName, FontSize, HAlign, VAlign, Z, WaitTime, DisplayTime, NbLoop)
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
function Text.New(Content, X, Y, Width, Height, TextColor, FontName, FontSize, HAlign, VAlign, Z, WaitTime, DisplayTime, NbLoop)
  local self = setmetatable(Parent.New(X, Y, Width, Height, Z), Text)
  self:SetContent(Content)
  if (self.width == 0 and Width == nil) or (self.height == 0 and Height == nil) then
    self.width, self.height = self:GetTextDimensions()
  end
  self:SetTextColor(TextColor)
  self:SetFont(FontName, FontSize)
  self:SetAlignments(HAlign, VAlign)
  self:SetTimers(WaitTime, DisplayTime, NbLoop)
  return self
end

--*************************************************************

--[[
proto Text:Draw()
.D This function draw the text with its color and font. The text is aligned horizontally and vertically inside the width and height defined during its creation (by default, upper left).
]]--
function Text:Draw()
  if self.visible then
    if self.isVisible then
      local oldFont = love.graphics.getFont()
      love.graphics.setColor(self.textcolor)
      love.graphics.setFont(self.font)
      local x = self.x
      local y = self.y
      if self.valign == "center" then
        y = y + (self.height - self:GetTextHeight()) / 2
      elseif self.valign == "bottom" then
        y = y + self.height - self:GetTextHeight()
      end
      if self.backcolor then
        self:DrawPanel()
      end
      love.graphics.printf(self.content, x, y, self.width, self.halign)
      love.graphics.setFont(oldFont)
      love.graphics.setColor(1,1,1,1)
    end
  end
end

--*************************************************************

--[[
proto Text:GetContent()
.D This functions returns the content of the text.
.R Returns the content of the text.
]]--
function Text:GetContent()
  return self.content
end
--[[
proto Text:SetContent(Content)
.D This function sets the text to display. If the text received is nil or an empty string, the timers are reseted.
.P Content
Text to display.
]]--
function Text:SetContent(Content)
  if not Content then
    Content = ""
  end
  self.content = Content
  if self.content == "" then
    self:ResetTimers()
  end
end

--*************************************************************

--[[
proto Text:GetFont()
.D This function returns the font defined for the text
.R Font of the text
]]--
function Text:GetFont()
  local font = self.font
  if not font then
    font = love.graphics.getFont()
  end
  return font
end
--[[
proto Text:SetFont(FontName, FontSize)
.D This function sets the font and size of the text. If the FontName is nil, no font is set. The width and height of the text are updated.
.P FontName
Path and name of the font to use to display the text. Should not be nil.
.P FontSize
Font size of the text.
]]--
function Text:SetFont(FontName, FontSize)
  if FontName ~= nil and FontName ~= "" then
    self.fontname = FontName
    self.fontsize = FontSize
    self.font = love.graphics.newFont(FontName, FontSize)
  else
    self.font = love.graphics.getFont()
    if FontSize ~= nil and FontSize ~= "" then
      self:SetFontSize(FontSize)
    end
  end
end
--[[
proto Text:SetNewSize(Size)
.D This function changes the font size of the text. If no font has been set, the current text size will remain. The width and height of the text are updated.
.P Size
New font size.
]]--
function Text:SetFontSize(Size)
  if self.fontname then
    self.fontsize = Size
    self.font = love.graphics.newFont(self.fontname, Size)
  end
end

--*************************************************************
--[[
proto Text:GetTextColor()
.D This function returns the color of the text.
.R Color of the text
]]--
function Text:GetTextColor()
  return self.textcolor
end

--[[
proto Text:SetTextColor(Color)
.D This function change the color of the text with the given color.
.P Color
New color of the text.
]]--
function Text:SetTextColor(Color)
  if not IsColorValid(Color) then
    Color = Colors.WHITE
  end
  self.textcolor = Color
end

--[[
proto Text:GetTextHeight()
.D This function returns the height of the text.
.R Height of the text
]]--
function Text:GetTextHeight()
  if not self.content then
    return 0
  end
  local font = self:GetFont()
  return font:getHeight()
end

--[[
proto Text:GetTextWidth()
.D This function returns the width of the text.
.R Width of the text.
]]--
function Text:GetTextWidth()
  if not self.content then
    return 0
  end
  local font = self:GetFont()
  return font:getWidth(self.content)
end

--[[
proto Text:GetTextDimensions()
.D This function returns the width and height of the text
.R Width and height of the text
]]--
function Text:GetTextDimensions()
  return self:GetTextWidth(), self:GetTextHeight()
end

--[[
proto Text:GetAlignments()
.D This function returns the alignments of the text.
.R Horizontal and vertical alignments of the text.
]]--
function Text:GetAlignments()
  return self.halign, self.valign
end

--[[
proto Text:SetAlignments(HAlign, VAlign)
.D This function defines the horizontal and vertical alignments of the text.
.P HAlign
Horizontal alignment of the text. Can be "left", "center" or "right".
.p VAlign
Vertical alignment of the text. Can be "up", "center" or "bottom.
]]--
function Text:SetAlignments(HAlign, VAlign)
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
proto Text:ResetTimers()
.D This function sets the timers to -1 for the display time, 0 for the waiting time ans -1 for the number of loops. Those values display the text without any effect.
]]--
function Text:ResetTimers()
  self:SetTimers(-1, -1, -1)
end

--[[
proto Text:SetTimers(WaitTime, DisplayTime, NbLoop)
.D This function sets the timers used for displaying the text.
.P DisplayTime
Duration for showing the text.
.P WaitTime
Duration before displaying the text.
.P NbLoop
Number of time the text will be shown (all durations will also be repeat).
]]--
function Text:SetTimers(WaitTime, DisplayTime, NbLoop)
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
proto Text:Update(dt)
.D This funtion launches all updates needed for the current text.
.P dt
Delta time.
]]--
function Text:Update(dt)
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
proto Text:ToString(NoTitle)
.D This function display all variables containing in the current Text instance (tables and functions are excluded).
.P NoTitle
Indicates if the title must be displayed (false) or not (true).
]]--
function Text:ToString(NoTitle)
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
Text.__tostring = function(Text, NoTitle) return Text:ToString(NoTitle) end
Text.__index = Text
return Text