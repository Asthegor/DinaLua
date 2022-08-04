local Fct_Collision = {
  _VERSION     = '1.2',
  _TITLE       = 'Dina Game Engine - Collision Functions',
  _URL         = 'https://dina.lacombedominique.com/documentation/functions/collisions/',
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
proto CollidePointRect(XA, YA, XB, YB, Width, Height)
.D This function checks if the given point is inside the given rectangle.
.P XA
X-axis coordinate of the point
.P YA
Y-axis coordinate of the point
.P XB
X-axis coordinate of the rectangle
.P YB
Y-axis coordinate of the rectangle
.P Width
Width of the rectangle
.P Height
Height of the rectangle
.R Return true if the point is inside the rectangle.
]]--
function CollidePointRect(XA, YA, XB, YB, WidthB, HeightB)
  return XA >= XB and XA <= XB + WidthB and
  YA >= YB and YA <= YB + HeightB
end

--[[
proto CollideRectRect(XA, YA, WidthA, HeightA, XB, YB, WidthB, HeightB)
.D This function checks if 2 rectangles collide.
.P XA
X-axis coordinate of the first rectangle
.P YA
Y-axis coordinate of the first rectangle
.P WidthA
Width of the first rectangle
.P HeightA
Height of the first rectangle
.P XB
X-axis coordinate of the second rectangle
.P YB
Y-axis coordinate of the second rectangle
.P Width
Width of the second rectangle
.P Height
Height of the second rectangle
.R Returns true if the two rectangles touch or overlap; otherwise returns false.
]]--
function CollideAABB(XA, YA, WidthA, HeightA, XB, YB, WidthB, HeightB)
  if ((XB >= XA + WidthA) or (XB + WidthB <= XA) or (YB >= YA + HeightA) or (YB + HeightB <= YA)) then
    return false
  end
  return true
end

--[[
proto CollidePointCircle(XA, YA, XB, YB, RB)
.D This function allows to check if a given point is inside a given circle.
.P XA
X-axis coordinate of the point
.P YA
Y-axis coordinate of the point
.P XB
X-axis coordinate of the center of the circle
.P YB
Y-axis coordinate of the center of the circle
.P RB
Radius of the circle
.R Return true if the point is inside the circle.
]]--
function CollidePointCircle(XA, YA, XB, YB, RB)
  local dist = (XA - XB) * (XA - XB) + (YA - YB) * (YA - YB)
  if dist > RB * RB then
    return false
  end
  return true
end


--[[
proto CollideCircleCircle(XA, YA, RA, XB, YB, RB)
.D This function allows to check if 2 circles touch each other.
.P XA
X-axis coordinate of the center of the first circle
.P YA
Y-axis coordinate of the center of the first circle
.P RA
Radius of the first circle
.P XB
X-axis coordinate of the center of the second circle
.P YB
Y-axis coordinate of the center of the second circle
.P RB
Radius of the second circle
]]--
function CollideCircleCircle(XA, YA, RA, XB, YB, RB)
  local dist = (XA - XB) * (XA - XB) + (YA - YB) * (YA - YB)
  if dist > (RA + RB) * (RA + RB) then
    return false
  end
  return true
end
