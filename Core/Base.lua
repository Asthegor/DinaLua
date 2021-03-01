local Base = {
  _TITLE       = 'Dina Game Engine - Base element',
  _VERSION     = '2.0.3',
  _URL         = 'https://dina.lacombedominique.com/documentation/core/base/',
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

--[[
proto const Base.new(X, Y)
.D This function creates a new Base element object.
.P X
Coordonate on the X-axis.
.P Y
Coordonate on the Y-axis.
.R Return an instance of Base element object.
]]--
function Base.new(X, Y)
  local self = {}
  local id = string.gsub(tostring(self), "table: ", "")
  setmetatable(self, Base)
  self.id = id
  self:setPosition(X, Y)
  self.visible = true
  -- test DLA
  return self
end

--[[
proto Base:getPosition()
.D This function returns the current position of the base element.
.R Position on the X and Y axis of the base element.
]]--
function Base:getPosition()
  return self.x, self.y
end

--[[
proto Base:setPosition(X, Y)
.D This function set the position of the base element.
.P X
X value. If not a number, set to 0.
.P Y
Y value. If not a number, set to 0.
]]--
function Base:setPosition(X, Y)
  self.x = SetDefaultNumber(X, 0)
  self.y = SetDefaultNumber(Y, 0)
end

--[[
proto Base:adjustPosition(OffsetX, OffsetY)
.D This function adjusts the current position by the given offset values.
.P OffsetX
Offset value to add to the X position.
.P OffsetY
Offset value to add to the Y position.
]]--
function Base:adjustPosition(OffsetX, OffsetY)
  if IsNumber(OffsetX) and IsNumber(OffsetY) then
    self.x = self.x + OffsetX
    self.y = self.y + OffsetY
  end
end

--[[
proto Base:getVisible()
.D This function returns the visibility of the base element.
.R
True if the base element is visible; false otherwise.
]]--
function Base:getVisible()
  return self.visible or false
end
--[[
proto Base:setVisible(Visible)
.D This function set the visibility of the base element.
.P Visible
Boolean which indicate if the base element is visible (true) or not (false).
]]--
function Base:setVisible(Visible)
  self.visible = Visible == true and true or false
end

--[[
proto Base:draw()
.D This function indicates only if a Draw function has not been implemented for an element using this base element.
]]--
function Base:draw()
  print("Base - draw : Not implemented") 
end

--[[
proto Base:update()
.D This function indicates only if an Update function has not been implemented for an element using this base element.
]]--
function Base:update()
  print("Base - update : Not implemented")
end

--[[
proto Base:toString(NoTitle)
.D This function display all variables containing in the current Base instance (tables and functions are excluded).
.P NoTitle
Indicates if the title must be displayed (false) or not (true).
]]--
function Base:toString(NoTitle)
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
Base.__tostring = function(Base, NoTitle) return Base:toString(NoTitle) end
Base.__index = Base
Base.__name = "Base"
return Base