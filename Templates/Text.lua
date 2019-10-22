local Text = {
  _VERSION     = 'Dina GE Text Template v1.3',
  _DESCRIPTION = 'Text Template in Dina GE',
  _URL         = 'https://dina.lacombedominique.com/documentation/templates/text/',
  _LICENSE     = [[
    ZLIB Licence

    Copyright (c) 2019 LACOMBE Dominique

    This software is provided 'as-is', without any express or implied warranty. In no event will the authors be held liable for any damages arising from the use of this software.
    Permission is granted to anyone to use this software for any purpose, including commercial applications, and to alter it and redistribute it freely, subject to the following restrictions:
        1. The origin of this software must not be misrepresented; you must not claim that you wrote the original software. If you use this software in a product, an acknowledgment in the product documentation would be appreciated but is not required.
        2. Altered source versions must be plainly marked as such, and must not be misrepresented as being the original software.
        3. This notice may not be removed or altered from any source distribution.
  ]]
}

-- REQUIRES

--[[
proto const Text.New(Content, FontName, FontSize, WaitTime, DisplayTime, NbLoop, X, Y)
.D This function creates a new Text object.
.P Content
Content of the Text component.
.P FontName
Name and path of the font file.
.P FontSize
Size of the text.
.P WaitTime
Duration before displaying the text.
.P DisplayTime
Duration for showing the text.
.P NbLoop
Number of time the text will be shown (all durations will also be repeat).
.P X
Position on the X axis of the text.
.P Y
Position on the Y axis of the text.
.R Return an instance of Text object.
]]--
--[[
proto const Text.New(ParamTable)
.D This function creates a new Text object.
.P ParamTable
Table containing all parameters which names are the same as the standard constructor. See the MinimalMenu example for further details.
.R Return an instance of Text object.
]]--
function Text.New(Name, Content, FontName, FontSize, WaitTime, DisplayTime, NbLoop, X, Y)
  local self = setmetatable({}, Text)
  self.name = Name
  self.GameEngine = require('DinaGE')

  if type(Content) == "table" then
    self:SetContent(Content["Content"])
    self:SetFont(Content["FontName"], Content["FontSize"])
    self:SetTimers(Content["WaitTime"], Content["DisplayTime"], Content["NbLoop"])
    self:SetPosition(Content["X"], Content["Y"])
    self:SetZOrder()
    self:SetColor()
    return self
  end

  self:SetContent(Content)
  self:SetFont(FontName, FontSize)
  self:SetTimers(WaitTime, DisplayTime, NbLoop)
  self:SetPosition(X, Y)
  self:SetZOrder()
  self:SetColor()
  return self
end

--[[
proto Text:ChangePosition(X, Y)
.D This function change the position on the X and Y axis of the text.
.P X
Add this value to the X axis position.
.P Y
Add this value to the Y axis position.
]]--
function Text:ChangePosition(X, Y)
  self.x = self.x + X
  self.y = self.y + Y
end

--[[
proto Text:Draw()
.D This function draw the text with the defined font.The text can be align within the given limit.
.P Limit
Limit in pixels that the text can not exceed.
.P Alignment
Alignment of the text.
]]--
function Text:Draw(Limit, Alignment)
  if self.isVisible == true then
    love.graphics.setColor(self.color)
    local oldFont = love.graphics.getFont()
    if self.font then love.graphics.setFont(self.font) end
    love.graphics.printf(self.content, self.x, self.y, Limit or self:GetWidth(), self.alignment)
    if self.font then love.graphics.setFont(oldFont) end
    love.graphics.setColor(Colors.WHITE)
  end
end

--[[
proto Text:Getcolor()
.D This functions returns the color of the text.
.R Returns the color of the text.
]]--
function Text:GetColor()
  return self.color
end


--[[
proto Text:GetDimensions()
.D This functions returns the width and height of the text, depending on the font used.
.R Returns the width and height of the text.
]]--
function Text:GetDimensions()
  return self:GetWidth(), self:GetHeight()
end


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
proto Text:GetHeight()
.D This function returns the height of the text
.R Height of the text
]]--
function Text:GetHeight()
  if not self.content then
    return 0
  end
  local font = self:GetFont()
  return font:getHeight()
end

--[[
proto Text:GetName()
.D This function returns the name of the text.
.R Returns the name of the text.
]]
function Text:GetName()
  return self.name
end

--[[
proto Text:GetPosition()
.D This function returns the current position of the text.
.R Position on the X and Y axis of the text
]]--
function Text:GetPosition()
  return self.x, self.y
end

--[[
proto Text:GetWidth()
.D This function returns the width of the text
.R Width of the text
]]--
function Text:GetWidth()
  if not self.content then
    return 0
  end
  local font = self:GetFont()
  return font:getWidth(self.content)
end

--[[
proto Text:GetZOrder()
.D This function returns the z-order of the text.
.R Returns the z-order of the text.
]]--
function Text:GetZOrder()
  return self.z
end

--[[
proto Text:ResetTimers()
.D This function sets the timers to -1 for the display time, 0 for the waiting time ans -1 for the number of loops. Those values display the text without any effect.
]]--
function Text:ResetTimers()
  self:SetTimers(-1, 0, -1)
end

--[[
proto Text:SetAlignment(Alignment)
.D This function sets the alignment of the text.
.P Alignment
Alignment of the text. (default: "left")
]]--
function Text:SetAlignment(Alignment)
  self.alignment = Alignment
end

--[[
proto Text:SetColor(Color)
.D This function sets the color of the text.
.P Color
Color of the text. See file Functions/Enum_Colors for a list of some colors
]]--
function Text:SetColor(Color)
  if not IsColorValid(Color) then
    Color = Colors.WHITE
  end
  self.color = Color
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
  if Content == "" then
    self:ResetTimers()
  end
  self.content = Content
end

--[[
proto Text:SetFont(FontName, FontSize)
.D This function sets the font and size of the text. If the FontName is nil, no font is set.
.P FontName
Path and name of the font to use to display the text. Should not be nil.
.P FontSize
Font size of the text.
]]--
function Text:SetFont(FontName, FontSize)
  if FontName then
    self.fontname = FontName
    self.fontsize = FontSize
    self.font = love.graphics.newFont(FontName, FontSize)
  end
end

--[[
proto Text:SetNewSize(Size)
.D This function changes the font size of the text. If no font has been set, the current text size will remain.
.P Size
New font size.
]]--
function Text:SetFontSize(Size)
  if self.fontname then
    self.fontsize = Size
    self.font = love.graphics.newFont(self.fontname, Size)
  end
end

--[[
proto Text:SetPosition(X, Y)
.D This function set the position of the text.
.P X
X value. If not a number, set to 0.
.P Y
Y value. If not a number, set to 0.
]]--
function Text:SetPosition(X, Y)
  X = SetDefaultNumber(X, 0) 
  Y = SetDefaultNumber(Y, 0)
  self.x = X
  self.y = Y
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
]]
function Text:SetTimers(WaitTime, DisplayTime, NbLoop)
  -- waiting time before display
  self.waitTime = SetDefaultNumber(WaitTime, -1)
  self.timerWait = self.waitTime
  -- display time
  self.displayTime = SetDefaultNumber(DisplayTime, -1)
  self.timerDisplay = self.displayTime
  -- number of loops
  self.nbloop = SetDefaultNumber(NbLoop, -1)

  if DisplayTime ~= 0 and NbLoop ~= 0 then
    self.isVisible = true
  end
end

--[[
proto Text:SetZOrder(Z)
.D This function sets the z-order of the text.
.P Z
Z-order of the text (default: 1).
]]--
function Text:SetZOrder(Z)
  local zorder = self.z
  self.z = SetDefaultNumber(Z, 1)
  if Z ~= zorder then
    self.GameEngine.CallbackZOrder()
  end
end

--[[
proto Text:Update(dt)
.D This funtion launches all updates needed for the current text
.P dt
Delta time.
]]
function Text:Update(dt)
  self:UpdateVisibility(dt)
end

--[[
proto Text:UpdateVisibility(dt)
.D This funtion defines if and when the text should be displayed based on the number of loops reminded and the duration before and for displaying the text.
.P dt
Delta time.
]]
function Text:UpdateVisibility(dt)
  self.isVisible = false
  if self.nbloop == 0 then
    return
  end
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
      end --self.nbloop > 0
      self.timerWait = self.waitTime
      self.timerDisplay = self.displayTime
    end --self.timerDisplay < 0
  else --self.waitTime > 0
    self.timerWait = self.timerWait - dt
    if self.timerWait < 0 then
      self.isVisible = true
      if self.displayTime >= 0 then
        self.timerDisplay = self.timerDisplay - dt
        if self.timerDisplay < 0 then
          self.isVisible = false
          if self.nbloop > 0 then
            self.nbloop = self.nbloop - 1
          end --self.nbloop > 0
          self.timerWait = self.waitTime
          self.timerDisplay = self.displayTime
        end --self.timerDisplay < 0
      end --self.displayTime >= 0
    end --self.timerWait < 0
  end --self.waitTime <= 0 and self.displayTime < 0
end

Text.__call = function() return Text.New() end
Text.__index = Text
Text.__tostring = function() return "Text" end
return Text