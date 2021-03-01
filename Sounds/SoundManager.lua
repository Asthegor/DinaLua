local SoundManager = {
  _VERSION     = '2.0.3',
  _TITLE       = 'Dina Game Engine - Sound Manager',
  _URL         = 'https://dina.lacombedominique.com/documentation/sounds/soundmanager/',
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

-- Declaration of the parent
local Dina = require("Dina")
local Parent = Dina:require("Manager")
setmetatable(SoundManager, {__index = Parent})

--[[
proto const SoundManager.New()
.D This function creates a new SoundManager object.
.R Return an instance of SoundManager object.
]]--
function SoundManager.new()
  local self = setmetatable(Parent.new(), SoundManager)
  self.sounds = {}
  return self
end

--[[
proto SoundManager:add(File, Type)
.D This function create and add a sound to the sound table.
.P File
Path of the file containing the sound.
.P Type
Type of the sound : 'static', 'stream' or 'queue'
]]--
local Dina = require("Dina")
function SoundManager:add(File, Type)
  local sound = Dina("Sound", File, Type)
  if sound then
    table.insert(self.sounds, sound)
  end
end

--[[
proto SoundManager:changeVolume(Volume)
.D This function increase or decrease the volume for all the sound.
.P Volume
Add this value to the current volume.
]]--
function SoundManager:changeVolume(Volume)
  for _, sound in pairs(self.sounds) do
    sound:changeVolume(Volume)
  end
end

--[[
proto SoundManager:pauseSound()
.D This function pauses all sounds.
]]--
function SoundManager:pauseSounds()
  for _, sound in pairs(self.sounds) do
    sound:pause()
  end
end

--[[
proto SoundManager:setVolume(Volume)
.D This function sets a new volume value for all sounds.
.P Volume
New volume to apply to all sounds. Normal volume: 1.
]]--
function SoundManager:setVolume(Volume)
  for _, sound in pairs(self.sounds) do
    sound:setVolume(Volume)
  end
end

-- STOP ALL
--[[
proto SoundManager:stopAll()
.D This function stops all musics and sounds.
]]--
function SoundManager:stopAll()
  for _, sound in pairs(self.sounds) do
    sound:stop()
  end
end

--[[
proto SoundManager:update(dt)
.D This function launch the Update function on all sounds.
.P dt
Delta time.
]]--
function SoundManager:update(dt)
  for _, sound in pairs(self.sounds) do
    sound:update(dt)
  end
end

function SoundManager:toString(NoTitle)
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
SoundManager.__tostring = function(SoundManager, NoTitle) return SoundManager:toString(NoTitle) end
SoundManager.__index = SoundManager
SoundManager.__name = "SoundManager"

return SoundManager