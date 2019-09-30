local SoundManager = {
  _VERSION     = 'Love2D Game Engine Sound Manager v1.1.0',
  _DESCRIPTION = 'Sounds and Musics Manager in Love2D Game Engine',
  _URL         = 'https://love2dge.lacombedominique.com/documentation/managers/soundmanager/',
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

--[[
proto const SoundManager.New()
.D This function creates a new SoundManager object.
.R Return an instance of SoundManager object.
]]--
function SoundManager.New()
  local self = setmetatable({}, SoundManager)
  self.GameEngine = require("L2DGE")
  self.sounds = {}
  return self
end

--[[
proto SoundManager:AddSound(Name, File, Type)
.D This function create and add a sound to the sound table.
.P Name
Name of the sound.
.P File
Path of the file containing the sound.
.P Type
Type of the sound : 'static', 'stream' or 'queue'
]]--
function SoundManager:AddSound(Name, File, Type)
  local sound = GameEngine.GetComponent("Sound", Name, File, Type)
  if sound ~= nil then
    self.sounds[Name] = sound
  end
end

-- PAUSE
--[[
proto SoundManager:PauseSound(Name)
.D This function look into the sound table for the given sound name and put it on pause if found.
.P Name
Name of the sound.
]]--
function SoundManager:PauseSound(Name)
  local sound = self:SearchSoundByName(Name)
  if sound ~= nil then
    sound:Pause()
  end
end

-- PLAY
--[[
proto SoundManager:PlaySound(Name, NbLoop)
.D This function sets the number of playing loops and plays a sound found by the given name.
.P Name
Name of the sound.
.P NbLoop
Number of playing loops.
.R Return true if the sound is played; false otherwise.
]]--
function SoundManager:PlaySound(Name, NbLoop)
  if NbLoop == 0 then return false end
  local sound = self:SearchSoundByName(Name)
  if sound ~= nil then
    sound:SetLooping(NbLoop - 1)
    return sound:Play()
  end
  return false
end

-- SEARCH
--[[
proto SoundManager:SearchSoundByName(Name)
.D This function search into the sound table to find a sound with the given name.
.P Name
Name of the sound to find.
.R Return the sound object if found; nil otherwise.
]]--
function SoundManager:SearchSoundByName(Name)
  return self.sounds[Name]
end

--[[
proto SoundManager:SetLooping(Name, NbLoop)
.D This function sets the number of playing loops for the given sound name.
.P Name
Name of the sound.
.P NbLoop
Number of loops to proceed.
]]--
function SoundManager:SetLooping(Name, NbLoop)
  local sound = self:SearchSoundByName(Name)
  if sound ~= nil then
    sound:SetLooping(NbLoop)
  end
end

-- VOLUME
--[[
proto SoundManager:SetVolume(Name, Volume)
.D This function sets the volume for the music or sound identified by the given name.
.P Name
Name of the music or sound.
.P Volume
Volume to apply. Normal volume: 1.
]]--
function SoundManager:SetVolume(Name, Volume)
  local sound = self:SearchSoundByName(Name)
  if sound ~= nil then
    sound:SetVolume(Volume)
  end
end

-- STOP ALL
--[[
proto SoundManager:StopAll()
.D This function stops all musics and sounds.
]]--
function SoundManager:StopAll()
  for name, sound in pairs(self.sounds) do
    sound:Stop()
  end
end
-- STOP
--[[
proto SoundManager:StopSound(Name)
.D This function stops a sound identified by the given name.
.P Name
Name of the sound.
]]--
function SoundManager:StopSound(Name)
  local sound = self:SearchSoundByName(Name)
  if sound ~= nil then
    sound:Stop()
  end
end

--[[
proto SoundManager:Update(dt)
.D This function launch the Update function on all sounds.
.P dt
Delta time.
]]--
function SoundManager:Update(dt)
  for name, sound in pairs(self.sounds) do
    sound:Update(dt)
  end
end

SoundManager.__index = SoundManager
SoundManager.__call = function() return SoundManager.New() end
SoundManager.__tostring = function() return "SoundManager" end
return SoundManager