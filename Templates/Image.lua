local Image = {
  _TITLE       = 'Dina GE Image',
  _VERSION     = '2.0.4',
  _URL         = 'https://dina.lacombedominique.com/documentation/templates/image/',
  _LICENSE     = [[
Copyright (c) 2019 LACOMBE Dominique
ZLIB Licence
This software is provided 'as-is', without any express or implied warranty. In no event will the authors be held liable for any damages arising from the use of this software.
Permission is granted to anyone to use this software for any purpose, including commercial applications, and to alter it and redistribute it freely, subject to the following restrictions:
    1. The origin of this software must not be misrepresented; you must not claim that you wrote the original software. If you use this software in a product, an acknowledgment in the product documentation would be appreciated but is not required.
    2. Altered source versions must be plainly marked as such, and must not be misrepresented as being the original software.
    3. This notice may not be removed or altered from any source distribution.
]]
}

-- Parent declaration
local CurrentFile = (...):gsub("^(.*/+)", "")
local CurrentFolder = (...):gsub('%/'..CurrentFile..'$', '')
local Parent = require(CurrentFolder.."/Panel")
setmetatable(Image, {__index = Parent})


--[[
proto const Image.New(File, X, Y, ScaleX, ScaleY, Z)
.D This function creates a new Image object.
.P File
Name and path of the image file.
.P X
Position on the X axis of the image (default: 0).
.P Y
Position on the Y axis of the image (default: 0).
.P ScaleX
Scale on the X axis of the image (default: 1).
.P ScaleY
Scale on the Y axis of the image (default: 1).
.P Z
Z-order of the image (default: 1).
.R Return an instance of Image object.
]]--
function Image.New(File, X, Y, ScaleX, ScaleY, Z)
  local self = setmetatable(Parent.New(X, Y), Image)
  self.filename = File
  self.source = love.graphics.newImage(File)
  self:SetImage(self.source)
  self:SetFlip()
  self:SetImageOrigin()
  self:SetImageRotation()
  self:SetScale(ScaleX, ScaleY)
  self:SetZOrder(Z)
  self.visible = true
  return self
end

--[[
proto Image:Draw()
.D This function draws the image if visible.
]]--
function Image:Draw()
  if self.visible then
    love.graphics.setColor(1,1,1,1)
    love.graphics.draw(self.source, self.x, self.y, self.r, self.sx * self.flip, self.sy * self.flip, self.ox, self.oy)
    love.graphics.setColor(1,1,1,1)
  end
end

--[[
proto Image:GetFlip()
.D This function returns the flip of the image.
.R Returns the flip of the image.
]]--
function Image:GetFlip()
  return self.flip
end

--[[
proto Image:SetFlip(Flip)
.D This functions define on which side the imge must be displayed.
.P Flip
Direction to display the image. 1 for standard and -1 for reverse.
]]--
function Image:SetFlip(Flip)
  self.flip = SetDefaultNumber(Flip, 1)
end

--[[
proto Image:SetNewImage(File)
.D This function change the current image by the given one.
.P File
Path and name of the new image.
]]--
function Image:SetNewImage(File)
  if File == nil then
    File = ""
  end
  if File ~= "" and File ~= self.filename then
    self.filename = File
    self.source = love.graphics.newImage(File)
    self.height = self.source:getHeight()
    self.width = self.source:getWidth()
    self.limit = nil
    self.visible = true
  elseif File == "" then
    self.visible = false
  end
end

--[[
proto Image:GetOrigin()
.D This function returns the position of the origin of the image.
.R Returns the position on the X and Y axis of the image origin.
]]--
function Image:GetOrigin()
  return self.ox, self.oy
end

--[[
proto Image:SetOrigin(OX, OY)
.D This function sets the origin coordonates of the image.
.P OX
Position on the X axis of the image origin (default: 0).
.P OY
Position on the Y axis of the image origin (default: 0).
]]--
function Image:SetOrigin(OX, OY)
  self.ox = SetDefaultNumber(OX, 0)
  self.oy = SetDefaultNumber(OY, 0)
end

--[[
proto Image:ToString(NoTitle)
.D This function display all variables containing in the current Image instance (tables and functions are excluded).
.P NoTitle
Indicates if the title must be displayed (false) or not (true).
]]--
function Image:ToString(NoTitle)
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
Image.__tostring = function(Image, NoTitle) return Image:ToString(NoTitle) end
Image.__index = Image
return Image