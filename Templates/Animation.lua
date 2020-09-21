local Animation = {
  _VERSION     = 'Dina GE Animation Template v1.3',
  _DESCRIPTION = 'Animation Template in Dina GE',
  _URL         = 'https://dina.lacombedominique.com/documentation/templates/animation/',
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
setmetatable(Animation, {__index = Parent})

function Animation.New(X, Y, Width, Height, Path, ImgNames, Speed, Z, Loop)
  local self = setmetatable(Parent.New(X, Y, Width, Height, Z), Animation)
  self.loop = Loop
  self.images = {}
  for i = 1, #ImgNames do
    self.images[i] = love.graphics.newImage(Path.."/"..ImgNames[i]..".png")
  end
  self.maxframe = #self.images
  self.frame = 1
  self.speed = Speed or 1
  self.timer = 0
  self:SetScale()
  self:SetFlip()
  return self
end
--
function Animation:Draw()
  if self.visible then
    self:DrawAnimation()
  end
end
--
function Animation:DrawAnimation()
  if self.frame > 0 and self.frame <= self.maxframe then
    love.graphics.setColor(1,1,1,1)
    love.graphics.draw(self.images[self.frame], self.x, self.y, 0, self.scale.x * self.flip.x, self.scale.y * self.flip.y, self.originx, self.originy)
  end
end
--
function Animation:Update(dt)
  if self.run then
    self.timer = self.timer + dt
    if self.timer > self.speed then
      self.frame = self.frame + 1
      if self.frame > #self.images then
        if self.loop then
          self.frame = 1
        else
          self.frame = 0
          self.run = false
        end
      end
      self.timer = 0
    end
  end
end
--
function Animation:GetOrigin()
  return self.originx, self.originy
end
--
function Animation:SetOrigin(OriginX, OriginY)
  self.originx = OriginX
  self.originy = OriginY
end
--
function Animation:SetScale(ScaleX, ScaleY)
  if self.scale == nil then self.scale = {} end
  self.scale.x = ScaleX or 1
  self.scale.y = ScaleY or 1
end
--
function Animation:SetFlip(FlipX, FlipY)
  if self.flip == nil then self.flip = {} end
  self.flip.x = FlipX or 1
  self.flip.y = FlipY or 1
end
--
function Animation:Play()
  self.run = true
  self.frame = 1
end
--
function Animation:Stop()
  self.run = false
end
--
function Animation:IsRunning()
  return self.run
end
--
Animation.__call = function() return Animation.New() end
Animation.__index = Animation
Animation.__tostring = function() return "Animation" end
return Animation