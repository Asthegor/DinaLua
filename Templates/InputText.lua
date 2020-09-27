local InputText = {
  _TITLE       = 'Dina GE InputText',
  _VERSION     = '2.0.3',
  _URL         = 'https://dina.lacombedominique.com/documentation/templates/inputtext/',
  _LICENSE     = [[
    ZLIB Licence

    Copyright (c) 2020 LACOMBE Dominique

    This software is provided 'as-is', without any express or implied warranty. In no event will the authors be held liable for any damages arising from the use of this software.
    Permission is granted to anyone to use this software for any purpose, including commercial applications, and to alter it and redistribute it freely, subject to the following restrictions:
        1. The origin of this software must not be misrepresented; you must not claim that you wrote the original software. If you use this software in a product, an acknowledgment in the product documentation would be appreciated but is not required.
        2. Altered source versions must be plainly marked as such, and must not be misrepresented as being the original software.
        3. This notice may not be removed or altered from any source distribution.
  ]]
}

-- Déclaration du parent
local CurrentFile = (...):gsub("^(.*/+)", "")
local CurrentFolder = (...):gsub('%/'..CurrentFile..'$', '')
local Parent = require(CurrentFolder.."/Panel")
setmetatable(InputText, {__index = Parent})

-- Déclaration des éléments supplémentaires
local Text = require(CurrentFolder.."/Text")

function InputText.New(X, Y, Width, Height, TextColor, FontName, FontSize, BorderColor, BackColor, MaxLength)
  local self = setmetatable(Parent.New(X, Y, Width, Height, BorderColor, BackColor), InputText)
  self.data = Text.New("", X, Y, Width, Height, TextColor, FontName, FontSize)
  self.cursor = Text.New("_", X, Y, Width, Height, TextColor, FontName, FontSize, 1, 0.5, 0.5, -1)
  self:SetMaxLength(MaxLength)
  return self
end

function InputText:Update(dt)
  if self.visible then
    self:UpdateInputText(dt)
  end
end

function InputText:UpdateInputText(dt)
  dt = math.min(dt, 1/60)
  self.cursor:Update(dt)
end

function InputText:Draw()
  if self.visible then
    self:DrawInputText()
  end
end
function InputText:DrawInputText()
  self.data:Draw()
  self.cursor:Draw()
end

--[[
proto InputText:SetFont(FontName, FontSize)
.D This function sets the font and size of the text. If the FontName is nil, no font is set. The width and height of the text are updated.
.P FontName
Path and name of the font to use to display the text. Should not be nil.
.P FontSize
Font size of the text.
]]--
function InputText:SetFont(FontName, FontSize)
  if FontName ~= nil then
    self.data:SetFont(FontName, FontSize)
    self.cursor:SetFont(FontName, FontSize)
  end
end
--[[
proto InputText:SetFontSize(Size)
.D This function changes the font size of the text. If no font has been set, the current text size will remain. The width and height of the text are updated.
.P Size
New font size.
]]--
function InputText:SetFontSize(Size)
  self.data:SetFontSize(Size)
  self.cursor:SetFontSize(Size)
end

function InputText:SetTextColor(Color)
  self.data:SetTextColor(Color)
  self.cursor:SetColor(Color)
end

function InputText:SetMaxLength(MaxLength)
  self.maxlength = MaxLength or -1
end

function InputText:KeyPress(key)
  if key and (string.len(key) == 1 or key == "backspace") then
    local len = string.len(self.data:GetContent())
    if key == "backspace" then
      if len > 0 then
        if len <= self.maxlength then
          self.cursor:SetVisible(true)
          self.cursor:SetTimers(0.5,0.5,-1)
        end
        self.data:SetContent(string.sub(self.data:GetContent(), 1, len-1))
      else
        self.data:SetContent("")
      end
    -- Check which key is pressed
    elseif len >= self.maxlength then
      return
    elseif IsInLimits(string.byte(key), 32, 126) then
      if len+1 >= self.maxlength then
        self.cursor:SetVisible(false)
        self.cursor:SetTimers(0,0,0)
      end
      self.data:SetContent(self.data:GetContent() .. key)
    end
    -- Change cursor position
    local tx, ty = self.data:GetPosition()
    local w = self.data:GetTextWidth()
    self.cursor:SetPosition(tx + w, ty)
  end
end

function InputText:ToString(NoTitle)
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
InputText.__tostring = function(InputText, NoTitle) return InputText:ToString(NoTitle) end
InputText.__index = InputText
return InputText