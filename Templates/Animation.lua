local Animation = {
  _TITLE       = 'Dina GE Animation',
  _VERSION     = '2.0.3',
  _URL         = 'https://dina.lacombedominique.com/documentation/templates/animation/',
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

-- Déclaration du parent
local CurrentFile = (...):gsub("^(.*/+)", "")
local CurrentFolder = (...):gsub('%/'..CurrentFile..'$', '')
local Parent = require(CurrentFolder.."/Panel")
setmetatable(Animation, {__index = Parent})

--[[
proto Animation.New(X, Y, Width, Height, Path, ImgNames, Speed, Z, Loop)
]]--
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
--[[
proto Animation:Draw()
]]--
function Animation:Draw()
  if self.visible then
    if self.frame > 0 and self.frame <= self.maxframe then
      love.graphics.setColor(1,1,1,1)
      love.graphics.draw(self.images[self.frame], self.x, self.y, 0, self.scale.x * self.flip.x, self.scale.y * self.flip.y, self.originx, self.originy)
    end
  end
end
--[[
proto Animation:Update(dt)
]]--
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
--[[
proto Animation:GetOrigin()
]]--
function Animation:GetOrigin()
  return self.originx, self.originy
end
--[[
proto Animation:SetOrigin(OriginX, OriginY)
]]--
function Animation:SetOrigin(OriginX, OriginY)
  self.originx = OriginX
  self.originy = OriginY
end
--[[
proto Animation:SetScale(ScaleX, ScaleY)
]]--
function Animation:SetScale(ScaleX, ScaleY)
  if self.scale == nil then self.scale = {} end
  self.scale.x = ScaleX or 1
  self.scale.y = ScaleY or 1
end
--[[
proto Animation:SetFlip(FlipX, FlipY)
]]--
function Animation:SetFlip(FlipX, FlipY)
  if self.flip == nil then self.flip = {} end
  self.flip.x = FlipX or 1
  self.flip.y = FlipY or 1
end
--[[
proto Animation:Play()
]]--
function Animation:Play()
  self.run = true
  self.frame = 1
end
--[[
proto Animation:Pause()
]]--
function Animation:Pause()
  self.run = not self.run
end
--[[
proto Animation:Stop()
]]--
function Animation:Stop()
  self.run = false
  self.frame = 1
end
--[[
proto Animation:IsRunning()
]]--
function Animation:IsRunning()
  return self.run
end
--[[
proto Animation:ToString(NoTitle)
.D This function display all variables containing in the current Animation instance (tables and functions are excluded).
.P NoTitle
Indicates if the title must be displayed (false) or not (true).
]]--
function Animation:ToString(NoTitle)
  local str = ""
  if not NoTitle then
    str = str .. self._TITLE .. " (".. self._VERSION ..")\n" .. self._URL
  end
  str = str .. Parent:ToString(true)
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
Animation.__tostring = function(Animation, NoTitle) return Animation:ToString(NoTitle) end
Animation.__index = Animation
return Animation