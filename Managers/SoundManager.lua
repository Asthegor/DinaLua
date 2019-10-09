local SoundManager = {
  _VERSION     = 'Dina GE Sound Manager v1.3',
  _DESCRIPTION = 'Sounds and Musics Manager in Dina Game Engine',
  _URL         = 'https://dina.lacombedominique.com/documentation/managers/soundmanager/',
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
    table.insert(self.sounds, sound)
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
    sound:ChangeVolume(Volume)
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
  for index = 1, #self.sounds do
    local sound = self.sounds[index]
    if sound.name == Name then
      return sound
    end
  end
  return nil
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