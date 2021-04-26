local Gamepad = {
  _TITLE       = 'Dina Game Engine - Gamepad',
  _VERSION     = '2.0.5',
  _URL         = 'https://dina.lacombedominique.com/documentation/controllers/gamepad/',
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
setmetatable(Gamepad, {__index = Parent})

local function hook_love_events(self)
  function love.joystickadded(joystick)
    local jid = joystick:getID()
    self.states[jid] = {}
    self.axebuttondown[jid] = {}
    self.joysticks[jid] = joystick
  end
  function love.joystickremoved(joystick)
    local jid = joystick:getID()
    self.states[jid] = nil
    self.joysticks[jid] = nil
  end
  function love.gamepadaxis(joystick, axis, value)
    local jid = joystick:getID()
    self.states[jid][axis] = (value ~= 0)
    local dir = ((value > 0 and 1) or (value < 0 and -1) or 0)
    if dir == 0 then
      self.axebuttondown[jid][axis] = false
    end
  end
  function love.gamepadpressed(joystick, button)
    local jid = joystick:getID()
    self.states[jid][button] = true
  end
  function love.gamepadreleased(joystick, button)
    local jid = joystick:getID()
    self.states[jid][button] = false
  end
end
-- TODO: proto
function Gamepad.new()
  local self = setmetatable(Parent.new(), Gamepad)
  self.states = {}
  self.joysticks = {}
  self.axebuttondown = {}
  hook_love_events(self)
  return self
end
-- TODO: proto
function Gamepad:reset()
  for joyId,_ in pairs(self.states) do
    for button, _ in pairs(self.states[joyId]) do
      self.states[joyId][button] = nil
    end
    for button, _ in pairs(self.axebuttondown[joyId]) do
      self.axebuttondown[joyId][button] = nil
    end
  end
end

-- TODO: proto
function Gamepad:button_down(JoystickId, Button, Direction)
  local joystick = self.joysticks[JoystickId]
  if not joystick then
    return false, 0
  end
  if string.lower(Button) == "all" then
    for _, state in pairs(self.states[JoystickId]) do
      if state then
        return true, 1
      end
    end
  end
  local state = self.states[JoystickId][Button]
  local pcall_res, value = pcall(joystick.getGamepadAxis, joystick, Button)
  if pcall_res then
    -- Traitement des axes
    if value ~= 0 and not self.axebuttondown[JoystickId][Button] then
      if state and Direction ~= 0 then
        if (Direction < 0 and value > 0) or (Direction > 0 and value < 0) then
          state = false
          value = 0
        else
          self.axebuttondown[JoystickId][Button] = true
        end
      end --state and Direction ~= 0
    else
      state = false
      value = 0
    end --value ~= 0
  end --pcall_res
  return state, value
end
-- TODO: proto
function Gamepad:button_up(JoystickId, Button, Direction)
  local joystick = self.joysticks[JoystickId]
  if not joystick then
    return false, 0
  end
  if string.lower(Button) == "all" then
    for _, state in pairs(self.states[JoystickId]) do
      if state == false then
        return true, 1
      end
    end
  end
  local state = (self.states[JoystickId][Button] == false)
  local pcall_res, value = pcall(joystick.getGamepadAxis, joystick, Button)
  if pcall_res then
    if value ~= 0 then
      state = self.states[JoystickId][Button]
      if state and Direction ~= 0 then
        if (Direction < 0 and value > 0) or (Direction > 0 and value < 0) then
          state = false
          value = 0
        end
      end --state and Direction ~= 0
    end --value ~= 0
  end --pcall_res
  return state, value
end

-- TODO: proto
function Gamepad:button(JoystickId, Button, Direction)
  local joystick = self.joysticks[JoystickId]
  if not joystick then
    return false, 0
  end
  if string.lower(Button) == "all" then
    for _, btn in pairs(self.states[JoystickId]) do
      if btn then
        return true, 1
      end
    end
    return false, 0
  end
  local pcall_res, isDown = pcall(joystick.isGamepadDown, joystick, Button)
  local value = 1
  if not pcall_res then
    value = joystick:getGamepadAxis(Button)
    isDown = (value ~= 0)
    if (Direction < 0 and value > 0) or (Direction > 0 and value < 0) then
      isDown = false
      value = 0
    end
  end
  return isDown, value
end

-- TODO: proto
function Gamepad:update(dt)
  for joyId,_ in pairs(self.states) do
    for button, _ in pairs(self.states[joyId]) do
      self.states[joyId][button] = nil
    end
  end
end

function Gamepad:toString(NoTitle)
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
Gamepad.__tostring = function(Gamepad, NoTitle) return Gamepad:toString(NoTitle) end
Gamepad.__index = Gamepad
Gamepad.__name = "Gamepad"
return Gamepad