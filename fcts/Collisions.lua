local Fct_Collision = {
  _VERSION     = '1.2',
  _TITLE       = 'Dina GE Collision Functions',
  _URL         = 'https://dina.lacombedominique.com/documentation/functions/collisions/',
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
proto Collide(XA, YA, XB, YB, Width, Height)
.D This function checks if a point is in a given rectangle.
.P XA
Coordonnates on the X-axis of the point.
.P YA
Coordonnates on the Y-axis of the point.
.P XB
Coordonnates on the X-axis of the upper-left corner of the rectangle.
.P YB
Coordonnates on the Y-axis of the upper-left corner of the rectangle.
.P Width
Width of the rectangle.
.P Height
Height of the rectangle
.R True if the point is inside of the given rectangle; false otherwise.
]]--
function Collide(XA, YA, XB, YB, WidthB, HeightB)
  return XA >= XB and XA <= XB + WidthB and
         YA >= YB and YA <= YB + HeightB
end