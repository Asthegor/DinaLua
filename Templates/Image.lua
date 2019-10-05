local Image = {
  _VERSION     = 'Dina GE Image Template v1.0',
  _DESCRIPTION = 'Image Template in Dina GE',
  _URL         = 'https://dina.lacombedominique.com/documentation/templates/image/',
  _LICENSE     = [[
    MIT LICENSE

    Copyright (c) 2019 LACOMBE Dominique

    Permission is hereby granted, free of charge, to any person obtaining a
    copy of this software and associated documentation files (the
    "Software"), to deal in the Software without restriction, including
    without limitation the rights to use, copy, modify, merge, publish,
    distribute, sublicense, and/or sell copies of the Software, and to
    permit persons to whom the Software is furnished to do so, subject to
    the following conditions:
    The above copyright notice and this permission notice shall be included
    in all copies or substantial portions of the Software.
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
    OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
    CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
    TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
    SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
  ]]
}

-- REQUIRES

--[[
proto const Image.New(File, X, Y, OX, OY, ScaleX, ScaleY, Z)
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
--[[
proto const Image.New(ParamTable)
.D This function creates a new Image object.
.P ParamTable
Table containing all parameters which names are the same as the standard constructor. See the standard constructor for further details.
.R Return an instance of Image object.
]]--
function Image.New(File, X, Y, ScaleX, ScaleY, Z)
  local self = setmetatable({}, Image)

  if type(File) == "table" then
    if File["File"] then
      self.source = love.graphics.newImage(File["File"])
      self.height = self.source:getHeight()
      self.width = self.source:getWidth()
      self:SetFlip()
      self:SetOrigin()
      self:SetPosition(File["X"], File["Y"])
      self:SetScale(File["ScaleX"], File["ScaleY"])
      self:SetZOrder(File["Z"])
      return self
    end
    return nil
  end

  if File then
    self.source = love.graphics.newImage(File)
    self.height = self.source:getHeight()
    self.width = self.source:getWidth()
    self:SetFlip()
    self:SetOrigin()
    self:SetPosition(X, Y)
    self:SetScale(ScaleX, ScaleY)
    self:SetZOrder(Z)
    return self
  end
  return nil
end

--[[
proto Image:Draw(SpriteBatch)
.D This function draws the image.
]]--
function Image:Draw()
  love.graphics.draw(self.source, self.x, self.y, self.r, self.sx * self.flip, self.sy * self.flip, self.ox, self.oy)
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
proto Image:GetHeight()
.D This function returns the height of the image.
.R Returns the height of the image.
]]--
function Image:GetHeight()
  return self.height
end

--[[
proto Image:GetOrigin()
.D This function returns the position of the origin of the image.
.R Returns the position on the X and Y axis of the image origin.
]]
function Image:GetOrigin()
  return self.ox, self.oy
end

--[[
proto Image:GetWidth()
.D This function returns the width of the image.
.R Returns the width of the image.
]]--
function Image:GetWidth()
  return self.width
end

--[[
proto Image:GetZOrder()
.D This function returns the Z-Order of the image.
.R Returns the Z-order of the image.
]]--
function Image:GetZOrder()
  return self.z
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
proto Image:SetPosition(X, Y)
.D This function sets the position of the image.
.P X
Position on the X axis of the image (default: 0).
.P Y
Position on the Y axis of the image (default: 0).
]]--
function Image:SetPosition(X, Y)
  self.x = SetDefaultNumber(X, 0)
  self.y = SetDefaultNumber(Y, 0)
end

--[[
proto Image:SetRotation(Rotation, Unit)
.D This function defines the rotation of the image.
.P Rotation
Rotation value in radians by default.
.P Unit
Unit determining if the value need to be converted. If "deg", convert the Rotation into radians; otherwise, the value stay unchanged.
]]--
function Image:SetRotation(Rotation, Unit)
  if Rotation then
    if Unit == "deg" then
      Rotation = math.rad(Rotation)
    end
    self.r = Rotation
  end
end

--[[
proto Image:SetScale(ScaleX, ScaleY)
.D This function define the scales of the image.
.P ScaleX
Scale on the X axis of the image (default: 1).
.P ScaleY
Scale on the Y axis of the image (default: 1).
]]--
function Image:SetScale(ScaleX, ScaleY)
  self.sx = SetDefaultNumber(ScaleX, 1)
  self.sy = SetDefaultNumber(ScaleY, 1)
end

--[[
proto Image:SetZOrder(Z)
.D This function sets the z-order of the image.
.P Z
Z-order of the image (default: 1).
]]--
function Image:SetZOrder(Z)
  self.z = SetDefaultNumber(Z, 1)
end


Image.__call = function() return Image.New() end
Image.__index = Image
Image.__tostring = function() return "Image" end
return Image