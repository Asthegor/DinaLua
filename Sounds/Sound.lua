local Sound = {
  _TITLE       = 'Dina Game Engine - Sound',
  _VERSION     = '2.0.4',
  _URL         = 'https://dina.lacombedominique.com/documentation/sounds/sound/',
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

-- REQUIRES


--[[
proto const Sound.new(File, Type, NbLoop, Volume)
.D This fonction create a new Sound object.
.P File
Path of the sound file.
.P Type
Type of sound; could only be 'stream', 'static' or 'queue' (Löve2D requirements).
.P NbLoop
Number of time the sound could be played. -1 to indicate infinite.
.P Volume
Volume of the sound. Normal sound is 1 (default).
.R Returns an instance of Sound object
]]--
function Sound.new(File, Type, NbLoop, Volume)
  local self = setmetatable({}, Sound)
  self.filename = File
  self.type = Type
  if not self.type or self.type == "" then
    self.type = "stream"
  end
  self.source = love.audio.newSource(self.filename, self.type)
  self:setLooping(NbLoop)
  self:setVolume(SetDefaultNumber(Volume, 1))
  self.paused = false
  return self
end

--[[
proto Sound:changeVolume(Volume)
.D This function increase or decrease the volume of the sound.
.P Volume
Add this value to the current volume.
]]--
function Sound:changeVolume(Volume)
  self.volume = self.volume + Volume
end

--[[
proto Sound:isPlaying()
.D This function returns true if the sound is playing; false otherwise.
.R Returns true if the sound is playing; false otherwise.
]]--
function Sound:isPlaying()
  if self.source then
    return self.source:isPlaying()
  end
  return false
end

--[[
proto Sound:isSameSound()
.D This function returns true if the sound is the same name and type as the given one; false otherwise.
.R Returns true if the sound is the same name and type as the given one; false otherwise.
]]--
function Sound:isSameSound(File, Type)
  return self.filename == File and self.type == Type
end

--[[
proto Sound:pause()
.D Pause the current sound or play it if paused.
]]--
function Sound:pause()
  if not self.paused then
    self.source:pause()
  else
    self.source:play()
  end
  self.paused = not self.paused
end

--[[
proto Sound:play()
.D Play the current sound at its defined volume only if it is positive.
]]--
function Sound:play()
  if self.volume then
    self.source:setVolume(self.volume)
  end
  self.source:play()
end

--[[
proto Sound:setLooping(NbLoop)
.D Define the number of times the sound can be played; none by default.
.P NbLoop
Number of time the sound can be played. -1 for infinite and 0 for none.
]]--
function Sound:setLooping(NbLoop)
  NbLoop = SetDefaultNumber(NbLoop, 0)
  if NbLoop < 0 then NbLoop = -1 end
  self.nbloop = NbLoop
end

--[[
proto Sound:setNewSound(File)
.D This function sets a new sound. If the current sound is playing, stop it and then change the sound.
.P File
Path and name of the sound file
.P Type
Type of sound; could only be 'stream', 'static' or 'queue' (Löve2D requirements).
]]--
function Sound:setNewSound(File, Type)
  if File then
    local nbLoop = self.nbloop
    local volume = self.volume
    self:stop()
    if not Type or Type == "" then
      Type = "stream"
    end
    self.source = love.audio.newSource(File, Type)
    self:setLooping(nbLoop)
    self:setVolume(volume)
  end
end

--[[
proto Sound:setVolume(Volume)
.D This function sets the sound volume. If negative or not defined, set it to 0.
.P Volume
Volume value.
]]--
function Sound:setVolume(Volume)
  Volume = SetDefaultNumber(Volume, 0)
  if Volume < 0 then Volume = 0 end
  self.volume = Volume
end

--[[
proto Sound:stop()
.D This function stops the sound.
]]--
function Sound:stop()
  self.source:stop()
end

--[[
proto Sound:update(dt)
.D This function updates the number of loops already done. if nbloop < 0, the sound is always played.
.P dt
Delta time.
]]--
function Sound:update(dt)
  if not self.paused and not self:isPlaying() then
    if self.nbloop < 0 then
      self:play()
    elseif self.nbloop > 0 then
      self.nbloop = self.nbloop - 1
      self:play()
    end
  end
end

function Sound:toString(NoTitle)
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
Sound.__tostring = function(Sound, NoTitle) return Sound:toString(NoTitle) end
Sound.__index = Sound
Sound.__name = "Sound"
return Sound