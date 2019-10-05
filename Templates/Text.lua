local Text = {
  _VERSION     = 'Dina GE Text Template v1.1',
  _DESCRIPTION = 'Text Template in Dina GE',
  _URL         = 'https://dina.lacombedominique.com/documentation/templates/text/',
  _LICENSE     = [[
    MIT LICENSE

    Copyright (c) 2019 LACOMBE Dominique

    Permission is hereby granted, free of charge, to any person obtaining a
    copy of this software and associated documentation files (the
    "Software"), to deal in the Software without restriction, including
    without limitation the rights to use, copy, modify, merge, publish,
    distribute, sublicense, and/or sell copies of the Software, and to
    permit persons to whom the Software is furnished to do so, subject to
    the following conditions:
    The above copyright notice and this permission notice shall be included
    in all copies or substantial portions of the Software.
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
    OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
    CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
    TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
    SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
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
function Text.New(Content, FontName, FontSize, WaitTime, DisplayTime, NbLoop, X, Y)
  local self = setmetatable({}, Text)

  if type(Content) == "table" then
    self:SetContent(Content["Content"])
    self:SetFont(Content["FontName"], Content["FontSize"])
    self:SetTimers(Content["WaitTime"], Content["DisplayTime"], Content["NbLoop"])
    self:SetPosition(Content["X"], Content["Y"])
    return self
  end

  self:SetContent(Content)
  self:SetFont(FontName, FontSize)
  self:SetTimers(WaitTime, DisplayTime, NbLoop)
  self:SetPosition(X, Y)
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
  self.posX = self.posX + X
  self.posY = self.posY + Y
end

--[[
proto Text:Draw()
.D This function draw the text with the defined font.
]]--
function Text:Draw()
  if self.isVisible == true then
    local oldFont = love.graphics.getFont()
    if self.font then love.graphics.setFont(self.font) end
    love.graphics.print(self.content, self.posX, self.posY)
    if self.font then love.graphics.setFont(oldFont) end
  end
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
proto Text:GetPosition()
.D This function returns the current position of the text.
.R Position on the X and Y axis of the text
]]--
function Text:GetPosition()
  return self.posX, self.posY
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
proto Text:ResetTimers()
.D This function sets the timers to -1 for the display time, 0 for the waiting time ans -1 for the number of loops. Those values display the text without any effect.
]]--
function Text:ResetTimers()
  self:SetTimers(-1, 0, -1)
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
  self.posX = X
  self.posY = Y
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