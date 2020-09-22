local CheckBox = {
  _TITLE       = 'Dina GE CheckBox',
  _VERSION     = '2.0.3',
  _URL         = 'https://dina.lacombedominique.com/documentation/templates/checkbox/',
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

function CheckBox:ToString(NoTitle)
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
CheckBox.__tostring = function(NoTitle) return CheckBox:ToString(NoTitle) end
CheckBox.__index = CheckBox
return CheckBox