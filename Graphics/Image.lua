local Image = {
  _TITLE       = 'Dina Game Engine - Image',
  _VERSION     = '2.0.4',
  _URL         = 'https://dina.lacombedominique.com/documentation/gui/image/',
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
local Dina = require("Dina")
local Parent = Dina:require("Panel")
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
function Image.new(File, X, Y, ScaleX, ScaleY, Z, FlipX, FlipY)
  local self = setmetatable(Parent.new(X, Y), Image)
  self:setImage(File)
  self:setFlip(FlipX, FlipY)
  self:setRotation()
  self:setScale(ScaleX, ScaleY)
  self:setOrigin()
  self:setZOrder(Z)
  self.visible = true
  return self
end

--[[
proto Image:draw()
.D This function draws the image if visible.
]]--
function Image:draw(Color)
  if self.visible then
    if IsColorValid(Color) then
      love.graphics.setColor(Color)
    end
    love.graphics.draw(self.source, self.x, self.y, math.rad(self.r), self.sx * self.flipx, self.sy * self.flipy, self.ox, self.oy)
    love.graphics.setColor(1,1,1,1)
  end
end

--[[
proto Image:getFlip()
.D This function returns the flips of the image.
.R Returns the flips of the image.
]]--
function Image:getFlip()
  return self.flipx, self.flipy
end

--[[
proto Image:setFlip(FlipX, FlipY)
.D This functions define on which side the imge must be displayed.
.P FlipX
Direction to display the image. 1 for standard and -1 for reverse.
.P FlipY
Direction to display the image. 1 for standard and -1 for reverse.
]]--
function Image:setFlip(FlipX, FlipY)
  if FlipX ~= 1 and FlipX ~= -1 then
    FlipX = 1
  end
  if FlipY ~= 1 and FlipY ~= -1 then
    FlipY = 1
  end
  self.flipx = FlipX
  self.flipy = FlipY
  if self.flipx < 0 then
    local x, y = self:getPosition()
    local w, h = self:getDimensions()
    self:setPosition(x + w, y)
  end
  if self.flipy < 0 then
    local x, y = self:getPosition()
    local w, h = self:getDimensions()
    self:setPosition(x, y + h)
  end
end

--[[
proto Image:setImage(File)
.D This function change the current image by the given one.
.P File
Path and name of the new image.
]]--
function Image:setImage(File)
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
proto Image:getOrigin()
.D This function returns the position of the origin of the image.
.R Returns the position on the X and Y axis of the image origin.
]]--
function Image:getOrigin()
  return self.ox, self.oy
end

--[[
proto Image:setOrigin(OX, OY)
.D This function sets the origin coordonates of the image.
.P OX
Position on the X axis of the image origin (default: 0).
.P OY
Position on the Y axis of the image origin (default: 0).
]]--
function Image:setOrigin(OX, OY)
  self.ox = SetDefaultNumber(OX, 0)
  self.oy = SetDefaultNumber(OY, 0)
end

--[[
proto Imge:centerOrigin()
.D This function sets the origin on the center of the image.
]]--
function Image:centerOrigin()
  local osx, osy = self:getScale()
  self:setScale(1,1)
  self:setOrigin(self.width / 2, self.height / 2)
  self:setScale(osx, osy)
end

--[[
proto Image:getRotation()
.D Cette fonction retourne l'angle de rotation en degrés de l'image.
]]--
function Image:getRotation()
  return self.r
end

--[[
proto Image:setRotation(Rotation)
.D Cette fonction applique une rotation en degrés à l'image.
]]--
function Image:setRotation(Rotation)
  self.r = SetDefaultNumber(Rotation, 0)
end

--[[
proto Image:toString(NoTitle)
.D This function display all variables containing in the current Image instance (tables and functions are excluded).
.P NoTitle
Indicates if the title must be displayed (false) or not (true).
]]--
function Image:toString(NoTitle)
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
Image.__tostring = function(Image, NoTitle) return Image:toString(NoTitle) end
Image.__index = Image
Image.__name = "Image"
return Image