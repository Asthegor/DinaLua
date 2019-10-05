local SoundManager = {
  _VERSION     = 'Dina GE Sound Manager v1.1',
  _DESCRIPTION = 'Sounds and Musics Manager in Dina Game Engine',
  _URL         = 'https://dina.lacombedominique.com/documentation/managers/soundmanager/',
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
  self.GameEngine = require("DinaGE")
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
  local sound = GameEngine.AddComponent(Name, "Sound", File, Type)
  if sound then
    self.sounds[Name] = sound
  end
end

--[[
proto SoundManager:ChangeVolume(Volume)
.D This function increase or decrease the volume for all the sound.
.P Volume
Add this value to the current volume.
]]--
function SoundManager:ChangeVolume(Volume)
  for _, sound in pairs(self.sounds) do
    sound:ChangeeVolume(Volume)
  end
end

--[[
proto SoundManager:PauseSound()
.D This function pauses all sounds.
]]--
function SoundManager:PauseSounds()
  for _, sound in pairs(self.sounds) do
    sound:Pause()
  end
end

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
proto SoundManager:SetVolume(Volume)
.D This function sets a new volume value for all sounds.
.P Volume
New volume to apply to all sounds. Normal volume: 1.
]]--
function SoundManager:SetVolume(Volume)
  for _, sound in pairs(self.sounds) do
    sound:SetVolume(Volume)
  end
end

-- STOP ALL
--[[
proto SoundManager:StopAll()
.D This function stops all musics and sounds.
]]--
function SoundManager:StopAll()
  for _, sound in pairs(self.sounds) do
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
  for _, sound in pairs(self.sounds) do
    sound:Update(dt)
  end
end

SoundManager.__call = function() return SoundManager.New() end
SoundManager.__index = SoundManager
SoundManager.__tostring = function() return "SoundManager" end
return SoundManager