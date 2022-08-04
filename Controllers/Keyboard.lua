local Keyboard = {
  _TITLE       = 'Dina Game Engine Keyboard',
  _VERSION     = '2.0.5',
  _URL         = 'https://dina.lacombedominique.com/documentation/controllers/keyboard/',
  _LICENSE     = [[
Copyright (c) 2021 LACOMBE Dominique
ZLIB Licence
This software is provided 'as-is', without any express or implied warranty. In no event will the authors be held liable for any damages arising from the use of this software.
Permission is granted to anyone to use this software for any purpose, including commercial applications, and to alter it and redistribute it freely, subject to the following restrictions:
    1. The origin of this software must not be misrepresented; you must not claim that you wrote the original software. If you use this software in a product, an acknowledgment in the product documentation would be appreciated but is not required.
    2. Altered source versions must be plainly marked as such, and must not be misrepresented as being the original software.
    3. This notice may not be removed or altered from any source distribution.
]]
}
local Dina = require("Dina")
local Parent = Dina:require("Manager")
setmetatable(Keyboard, {__index = Parent})

local function hook_love_events(self)
  function love.keypressed(key, scancode, isrepeat)
    self.key_state[key] = true
  end
  function love.keyreleased(key, scancode)
    self.key_state[key] = false
  end
end
--[[
proto const Keyboard.new()
]]--
function Keyboard.new()
  local self = setmetatable(Parent.new(), Keyboard)
  self.key_state = {}
  hook_love_events(self)
  return self
end
--[[
proto Keyboard:update(dt)
]]--
function Keyboard:update(dt)
  for key, _ in pairs(self.key_state) do
    self.key_state[key] = nil
  end
end
--[[
proto Keyboard:key_down(key)
]]--
function Keyboard:key_down(key)
  if string.lower(key) == "all" then
    for k,state in pairs(self.key_state) do
      if state then
        return true, 1, k
      end
    end
    return false, 1
  end
  return self.key_state[key], 1
end
--[[
proto Keyboard:key_up(key)
]]--
function Keyboard:key_up(key)
  if string.lower(key) == "all" then
    for k,state in pairs(self.key_state) do
      if state == false then
        return true, 1, k
      end
    end
    return false, 1
  end
  return self.key_state[key] == false, 1
end
--[[
proto Keyboard:key(key)
]]--
function Keyboard:key(key)
  if string.lower(key) == "all" then
    for k,state in pairs(self.key_state) do
      if state or state == false then
        return true, 1, k
      end
    end
    return false, 1
  end
  return love.keyboard.isDown(key), 1
end

-- System functions
Keyboard.__index = Keyboard
Keyboard.__name = "Keyboard"
return Keyboard