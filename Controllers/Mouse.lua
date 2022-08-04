local Mouse = {
  _TITLE       = 'Dina Game Engine Mouse',
  _VERSION     = '3.1.9',
  _URL         = 'https://dina.lacombedominique.com/documentation/controllers/mouse/',
  _LICENSE     = [[
Copyright (c) 2022 LACOMBE Dominique
ZLIB Licence
This software is provided 'as-is', without any express or implied warranty. In no event will the authors be held liable for any damages arising from the use of this software.
Permission is granted to anyone to use this software for any purpose, including commercial applications, and to alter it and redistribute it freely, subject to the following restrictions:
    1. The origin of this software must not be misrepresented; you must not claim that you wrote the original software. If you use this software in a product, an acknowledgment in the product documentation would be appreciated but is not required.
    2. Altered source versions must be plainly marked as such, and must not be misrepresented as being the original software.
    3. This notice may not be removed or altered from any source distribution.
]]
}

-- Work in progress

local Dina = require("Dina")
local Parent = Dina:require("Manager")
setmetatable(Mouse, {__index = Parent})


local function hook_love_events(self)
  function love.mousepressed(x, y, button, istouch, presses)
    self.button_state["button_"..button] = true
  end
  function love.mousereleased(x, y, button, istouch, presses)
    self.button_state["button_"..button] = false
  end
  function love.mousemoved(x, y, dx, dy)
    self.position.x = x
    self.position.y = y
    self.moved = true
  end
  function love.wheelmoved(x, y)
    if y < 0 then
      self.button_state["wheel_down"] = true
    elseif y > 0 then
      self.button_state["wheel_up"] = true
    elseif y == 0 then
      self.button_state["wheel_down"] = false
      self.button_state["wheel_up"] = false
    end
    if x < 0 then
      self.button_state["wheel_right"] = true
    elseif x > 0 then
      self.button_state["wheel_left"] = true
    elseif x == 0 then
      self.button_state["wheel_right"] = false
      self.button_state["wheel_left"] = false
    end
  end
end

--[[
proto const Mouse.new()
]]--
function Mouse.new()
  local self = setmetatable(Parent.new(), Mouse)
  self.button_state = {}
  self.position = {}
  self.wheel = {}
  self.moved = false
  hook_love_events(self)
  return self
end
--[[
proto Mouse:update(dt)
]]--
function Mouse:update(dt)
  for button, _ in pairs(self.button_state) do
    self.button_state[button] = nil
  end
end
--[[
proto Mouse:button_down(button)
]]--
function Mouse:button_down(button)
  if button == "all" then
    for _,state in pairs(self.button_state) do
      if state then
        return true, 1
      end
    end
    return false, 1
  end
  if string.find(button,"button_") ~= nil then
    return self.button_state[button], self.position
  elseif string.find(button,"wheel_") ~= nil then
    return self.button_state[button], 1
  else
    return true, self.position
  end
end
--[[
proto Mouse:button_up(button)
]]--
function Mouse:button_up(button)
  if button == "all" then
    for _,state in pairs(self.button_state) do
      if state == false then
        return true, 1
      end
    end
    return false, 1
  end
  if string.find(button,"button_") ~= nil then
    return self.button_state[button], self.position
  elseif string.find(button,"wheel_") ~= nil then
    return self.button_state[button], 1
  else
    return false, self.position
  end
end
--[[
proto Mouse:button(button)
]]--
function Mouse:button(button)
  if string.lower(button) == "all" then
    for _,state in pairs(self.button_state) do
      if state or state == false then
        return true, 1
      end
    end
    return false, 1
  end
  local mousePos = {}
  mousePos.x, mousePos.y = love.mouse.getPosition()
  if string.find(button,"button_") ~= nil then
    return love.mouse.isDown(string.gsub(button, "button_", "")), mousePos
  elseif string.find(button,"wheel_") ~= nil then
    return true, 1
  else
    return true, self.position
  end
end
--[[
proto Mouse:moved()
]]--
function Mouse:moved()
  if self.moved then
    self.moved = false
    return true, self.position
  end
end

-- System functions
Mouse.__index = Mouse
Mouse.__name = "Mouse"
return Mouse