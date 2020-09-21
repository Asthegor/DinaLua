local Base = {
  _VERSION     = 'Dina GE Base element v1.3.2',
  _DESCRIPTION = 'Base element in Dina Game Engine',
  _URL         = 'https://dina.lacombedominique.com/documentation/core/base/',
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

--[[
proto const Base.New(X, Y)
.D This function creates a new Base element object.
.P X
Coordonate on the X-axis.
.P Y
Coordonate on the Y-axis.
.R Return an instance of Base element object.
]]--
function Base.New(X, Y)
  local self = setmetatable({}, Base)
  self:SetPosition(X, Y)
  self.visible = true
  return self
end

--*************************************************************

--[[
proto Base:ChangePosition(X, Y)
.D This function change the position on the X and Y axis of the base element.
.P X
Add this value to the X axis position.
.P Y
Add this value to the Y axis position.
]]--
function Base:ChangePosition(X, Y)
  self.x = self.x + X
  self.y = self.y + Y
end
--[[
proto Base:GetPosition()
.D This function returns the current position of the base element.
.R Position on the X and Y axis of the base element.
]]--
function Base:GetPosition()
  return self.x, self.y
end
--[[
proto Base:SetPosition(X, Y)
.D This function set the position of the base element.
.P X
X value. If not a number, set to 0.
.P Y
Y value. If not a number, set to 0.
]]--
function Base:SetPosition(X, Y)
  self.x = SetDefaultNumber(X, 0)
  self.y = SetDefaultNumber(Y, 0)
end

--*************************************************************

--[[
proto Base:SetVisible(Visible)
.D This function set the visibility of the base element.
.P Visible
Boolean which indicate if the base element is visible (true) or not (false).
]]--
function Base:SetVisible(Visible)
  self.visible = Visible
end
--[[
proto Base:Visible()
.D This function returns the visibility of the base element.
.R
True if the base element is visible; false otherwise.
]]--
function Base:Visible()
  return self.visible or false
end

--*************************************************************

--[[
proto const Base:Draw()
.D This function indicates only if a Draw function has not been implemented for an element using this base element.
]]--
function Base:Draw()
  print("Base - Draw : Not implemented") 
end
--[[
proto const Base:Update()
.D This function indicates only if an Update function has not been implemented for an element using this base element.
]]--
function Base:Update()
  print("Base - Update : Not implemented")
end

-- Informations système
Base.__index = Base
return Base