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
.D Cette fonction verifie si un point donne est a l'interieur d'un rectangle donne
.P XA
Coordonnees sur l'axe des X du point
.P YA
Coordonnees sur l'axe des Y du point
.P XB
Coordonnees sur l'axe des X du rectangle
.P YB
Coordonnees sur l'axe des Y du rectangle
.P Width
Largeur du rectangle
.P Height
Hauteur du rectangle
.R Retourne vrai si le point est a l'interieur du rectangle
]]--
function CollidePointRect(XA, YA, XB, YB, WidthB, HeightB)
  return XA >= XB and XA <= XB + WidthB and
  YA >= YB and YA <= YB + HeightB
end

--[[
proto CollideRectRect(XA, YA, WidthA, HeightA, XB, YB, WidthB, HeightB)
.D Cette fonction verifie si 2 rectangles collisionnent entre eux
.P XA
Coordonnees sur l'axe des X du premier rectangle
.P YA
Coordonnees sur l'axe des Y du premier rectangle
.P WidthA
Largeur du rectangle
.P HeightA
Hauteur du rectangle
.P XB
Coordonnees sur l'axe des X du second rectangle
.P YB
Coordonnees sur l'axe des Y du second rectangle
.P Width
Largeur du second rectangle
.P Height
Hauteur du second rectangle
.R Retourne vrai si les deux rectangles se touchent ou se supperposent; sinon retourne faux
]]--
function CollideAABB(XA, YA, WidthA, HeightA, XB, YB, WidthB, HeightB)
  if ((XB >= XA + WidthA) or       -- trop a droite
      (XB + WidthB <= XA) or       -- trop a gauche
      (YB >= YA + HeightA) or      -- trop en bas
      (YB + HeightB <= YA)) then   -- trop en haut
    return false;
  end
  return true; 
end

--[[
proto CollidePointCircle(XA, YA, XB, YB, RB)
.D Cette fonction permet de verifier si un point donne est a l'interieur d'un cercle donne
.P XA
Coordonnees sur l'axe des X du point
.P YA
Coordonnees sur l'axe des Y du point
.P XB
Coordonnees sur l'axe des X du centre du cercle
.P YB
Coordonnees sur l'axe des Y du centre du cercle
.P RB
Rayon du cercle
.R Retourne vrai si le point est a l'interieur du cercle
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
.D Cette fonction permet de verifier si 2 cercles se touchent
.P XA
Coordonnees sur l'axe des X du centre du premier cercle
.P YA
Coordonnees sur l'axe des Y du centre du premier cercle
.P RA
Rayon du premier cercle
.P XB
Coordonnees sur l'axe des X du centre du second cercle
.P YB
Coordonnees sur l'axe des Y du centre du second cercle
.P RB
Rayon du second cercle
]]--
function CollideCircleCircle(XA, YA, RA, XB, YB, RB)
  local dist = (XA - XB) * (XA - XB) + (YA - YB) * (YA - YB)
  if dist > (RA + RB) * (RA + RB) then
    return false
  end
  return true
end
