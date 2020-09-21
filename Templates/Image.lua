local Image = {
  _VERSION     = 'Dina GE Image Template v1.3',
  _DESCRIPTION = 'Image Template in Dina GE',
  _URL         = 'https://dina.lacombedominique.com/documentation/templates/image/',
  _LICENSE     = [[
    ZLIB Licence

    Copyright (c) 2019 LACOMBE Dominique

    This software is provided 'as-is', without any express or implied warranty. In no event will the authors be held liable for any damages arising from the use of this software.
    Permission is granted to anyone to use this software for any purpose, including commercial applications, and to alter it and redistribute it freely, subject to the following restrictions:
        1. The origin of this software must not be misrepresented; you must not claim that you wrote the original software. If you use this software in a product, an acknowledgment in the product documentation would be appreciated but is not required.
        2. Altered source versions must be plainly marked as such, and must not be misrepresented as being the original software.
        3. This notice may not be removed or altered from any source distribution.
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
  self.GameEngine = require('DinaGE')

  if type(File) == "table" then
    if File["File"] then
      self.filename = File["File"]
      self.source = love.graphics.newImage(File["File"])
      self.height = self.source:getHeight()
      self.width = self.source:getWidth()
      self:SetFlip()
      self:SetOrigin()
      self:SetPosition(File["X"], File["Y"])
      self:SetScale(File["ScaleX"], File["ScaleY"])
      self:SetZOrder(File["Z"])
      self.visible = true
      return self
    end
    return nil
  end

  if File then
    self.filename = File
    self.source = love.graphics.newImage(File)
    self.height = self.source:getHeight()
    self.width = self.source:getWidth()
    self:SetFlip()
    self:SetOrigin()
    self:SetPosition(X, Y)
    self:SetScale(ScaleX, ScaleY)
    self:SetZOrder(Z)
    self.visible = true
    return self
  end
  return nil
end

--[[
proto Image:ChangePosition(X, Y)
.D This function change the position on the X and Y axis of the image.
.P X
Add this value to the X axis position.
.P Y
Add this value to the Y axis position.
]]--
function Image:ChangePosition(X, Y)
  self.x = self.x + X
  self.y = self.y + Y
end

--[[
proto Image:Draw()
.D This function draws the image within the Limit. If the size exceed the given limit, the scale is automatically adjusted to fit within the limit The new scale do not deform the image.
.P Limit
Limit in pixels that the image can not exceed.
]]--
function Image:Draw()
  if self.visible then
    self:DrawImage()
  end
end
function Image:DrawImage()
  love.graphics.setColor(1,1,1,1)
  love.graphics.draw(self.source, self.x, self.y, self.r, self.sx * self.flip, self.sy * self.flip, self.ox, self.oy)
  love.graphics.setColor(1,1,1,1)
end

--[[
proto Image:GetDimensions()
.D This function returns the width and height of the image.
.R Returns the width and height of the image.
]]--
function Image:GetDimensions()
  return self.width, self.height
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
]]--
function Image:GetOrigin()
  return self.ox, self.oy
end

--[[
proto Image:GetName()
.D This function returns the name of the image.
.R Returns the name of the image.
]]--
function Image:GetName()
  return self.name
end


--[[
proto Image:GetPosition()
.D This function returns the position of the image.
.R Returns the position on the X and Y axis of the image.
]]--
function Image:GetPosition()
  return self.x, self.y
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
  self.filename = File
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
proto Image:SetScaleFromLimit(LimitX, LimitY)
.D This function define the scales of the image from the given limits.
.P LimitX
Limit on the X axis not to exceed.
.P ScaleY
Limit on the Y axis not to exceed. If not defined, use the limit on the X axis instead.
]]--
function Image:SetScaleFromLimit(LimitX, LimitY)
  local scaleX = LimitX / self:GetWidth()
  if not LimitY then LimitY = LimitX end
  local scaleY = LimitY / self:GetHeight()
  local scale = math.max(scaleX, scaleY)
  self:SetScale(scale, scale)
end

--[[
proto Image:SetZOrder(Z)
.D This function sets the z-order of the image.
.P Z
Z-order of the image (default: 1).
]]--
function Image:SetZOrder(Z)
  local zorder = self.z
  self.z = SetDefaultNumber(Z, 1)
  if Z ~= zorder then
    self.GameEngine.CallbackZOrder()
  end
end


Image.__call = function() return Image.New() end
Image.__index = Image
Image.__tostring = function() return "Image" end
return Image