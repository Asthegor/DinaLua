local InputText = {
  _TITLE       = 'Dina Game Engine - InputText',
  _VERSION     = '2.0.4',
  _URL         = 'https://dina.lacombedominique.com/documentation/gui/inputtext/',
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
setmetatable(InputText, {__index = Parent})

-- Déclaration des éléments supplémentaires
local Text = Dina:require("Text")

-- Function invert the focus or not on the inputtext
local function Focus(InputText)
  InputText.focus = not InputText.focus
end


--[[
proto const InputText.new(X, Y, Width, Height, TextColor, FontName, FontSize, BorderColor, BackColor, MaxLength, PlaceHolder, PlacerHolderColor)
.D This function create a new instance of an ImputText object.
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
.P BorderColor
Color of the border.
.P BackColor
Color of the back
.P MaxLength
Number maximum of characters authorized.
.P PlaceHolder
Placeholder text (text to display when the content is empty).
.P PlaceHolderColor
Color of the placeholder text.
.R New instance of an InputText object.
]]--
function InputText.new(X, Y, Width, Height, TextColor, FontName, FontSize, BorderColor, BackColor, MaxLength, PlaceHolder, PlaceHolderColor)
  local self = setmetatable(Parent.new(X, Y, Width, Height, BorderColor, BackColor), InputText)
  self.data = Text.new("", X, Y, Width, Height, TextColor, FontName, FontSize)
  self.cursor = Text.new("_", X, Y, Width, Height, TextColor, FontName, FontSize, 1, 0.5, 0.5, -1)
  self:setMaxLength(MaxLength)
  self.placeholder = Text.new(PlaceHolder, X, Y, Width, Height, PlaceHolderColor, FontName, FontSize)
  self.focus = false
  self:setEvent("pressed", Focus)
  return self
end

--[[
proto InputText:update(dt)
.D This function triggers the action for the pressed event and update the cursor if the inputtext has the focus and is visible.
.P dt
Delta time.
]]--
function InputText:update(dt)
  if self.visible then
    self:updatePanel(dt)
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
    if self.focus then
      self.cursor:update(dt)
    end
  end
end

--[[
proto InputText:draw()
.D This function draw the input text if define as visible.
]]--
function InputText:draw()
  if self.visible then
    if self.data:getContent() == "" then
      self.placeholder:draw()
    end
    self.data:draw()
    if self.focus then
      self.cursor:draw()
    end
  end
end

--[[
proto InputText:setFont(FontName, FontSize)
.D This function sets the font and size of the text. If the FontName is nil, no font is set. The width and height of the text are updated.
.P FontName
Path and name of the font to use to display the text. Should not be nil.
.P FontSize
Font size of the text.
]]--
function InputText:setFont(FontName, FontSize)
  if FontName ~= nil then
    self.data:setFont(FontName, FontSize)
    self.cursor:setFont(FontName, FontSize)
  end
end
--[[
proto InputText:setFontSize(Size)
.D This function changes the font size of the text. If no font has been set, the current text size will remain. The width and height of the text are updated.
.P Size
New font size.
]]--
function InputText:setFontSize(Size)
  self.data:setFontSize(Size)
  self.cursor:setFontSize(Size)
end

--[[
proto InputText:setTextColor(Color)
.D This function set the color of the text and cursor.
.P Color
Color of the text and cursor.
]]--
function InputText:setTextColor(Color)
  self.data:setTextColor(Color)
  self.cursor:setColor(Color)
end

--[[
proto InputText:setMaxLength(MaxLength)
.D This function defines the maximum number of characters which can contain the input text.
.P MaxLength
Maximum number of characters admitted.
]]--
function InputText:setMaxLength(MaxLength)
  self.maxlength = MaxLength or -1
end

--[[
proto InputText:setPlaceholder(Placeholder)
.D This function sets the place holder text with 50% of transparency.
.P Placeholder
Text of the place holder.
]]--
function InputText:setPlaceholder(Placeholder)
  self.placeholder:setContent(Placeholder)
  local color = self.data:getTextColor()
  color[4] = 0.5
  self.placeholder:setTextColor(color)
end

--[[
proto InputText:keyPressed(key)
.D This function add the pressed keys to the focused input text. Only alphabetical characters and ponctuation are authorized.
.P key
Key pressed.
]]--
function InputText:keyPressed(key)
  if self.focus then
    if key and (string.len(key) == 1 or key == "backspace") then
      -- Rendre visible le curseur
      local len = string.len(self.data:getContent())
      if key == "backspace" then
        if len > 0 then
          if len <= self.maxlength then
            self.cursor:setVisible(true)
            self.cursor:setTimers(0.5,0.5,-1)
          end
          self.data:setContent(string.sub(self.data:getContent(), 1, len-1))
        else
          self.data:setContent("")
        end
        -- Check which key is pressed
      elseif len >= self.maxlength then
        return
      elseif IsInLimits(string.byte(key), 32, 126) then
        if len+1 >= self.maxlength then
          self.cursor:setVisible(false)
          self.cursor:setTimers(0,0,0)
        end
        self.data:setContent(self.data:getContent() .. key)
      end
      -- Change cursor position
      local tx, ty = self.data:getPosition()
      local w = self.data:getTextWidth()
      self.cursor:getPosition(tx + w, ty)
    end
  end
end

--[[
proto InputText:toString(NoTitle)
.D This function display all variables containing in the current InputText instance (tables and functions are excluded).
.P NoTitle
Indicates if the title must be displayed (false) or not (true).
]]--
function InputText:toString(NoTitle)
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
InputText.__tostring = function(InputText, NoTitle) return InputText:toString(NoTitle) end
InputText.__index = InputText
InputText.__name = "ImputText"
return InputText