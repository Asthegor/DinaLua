local Controller = {
  _TITLE       = 'Dina Game Engine Controller',
  _VERSION     = '2.0.6',
  _URL         = 'https://dina.lacombedominique.com/documentation/controllers/controller/',
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

-- Declaration of the parent
local Dina = require("Dina")
local Parent = Dina:require("Manager")
setmetatable(Controller, {__index = Parent})

-- Local functions
local function GetObjectId(Object)
  local id = Object.id
  if id == nil or id == "" then
    id = string.gsub(tostring(Object), "table: ", "")
  end
  Object.id = id
  return id
end
local function IsJoystickAssociate(Controller, JoystickId)
  for k,v in pairs(Controller.objassoc) do
    if v == JoystickId then
      return true
    end
  end
  return false
end
local function GetNextJoystickId(Controller)
  local joysticks = love.joystick.getJoysticks()
  for _, joystick in pairs(joysticks) do
    local jid = joystick:getID()
    if not IsJoystickAssociate(Controller, jid) then
      return jid
    end
  end
  return nil
end


--[[
proto const ControllerManager.new()
]]--
function Controller.new()
  local self = setmetatable(Parent.new(), Controller)
  self.keyboard = Dina("Keyboard")
  Dina:removeComponent(self.keyboard)
  self.gamepad = Dina("Gamepad")
  Dina:removeComponent(self.gamepad)
  self.mouse = Dina("Mouse")
  Dina:removeComponent(self.mouse)
  self.actions = {}
  self.objassoc = {}
  return self
end

--[[
proto Controller:setActionKeys(UID, Key, ...)
--]]
function Controller:setActionKeys(UID, Key, ...)
  assert(UID ~= nil and UID ~= "", "ERROR: UID parameter must be filled.")
  assert(type(Key) == "table", "ERROR: the Key parameter must be a table.")
  assert(string.lower(Key[1]) == "keyboard" or string.lower(Key[1]) == "gamepad" or string.lower(Key[1]) == "mouse", 
    "ERROR: the first value in the Key parameter must be 'keyboard' , 'gamepad' or 'mouse'")
  if not self.actions[UID].Keys then
    self.actions[UID].Keys = {}
  end
  table.insert(self.actions[UID].Keys, { ctl = string.lower(Key[1]), key = string.lower(Key[2]), dir = Key[3] or 0 })
  if (...) then
    self:setActionKeys(UID, ...)
  end
end

--[[
proto Controller:associate(Object, FctName, State)
--]]
function Controller:associate(Object, FctName, State)
  State = string.lower(State)
  assert(State == "pressed" or State == "released" or State == "continuous",
    "ERROR: State must be 'pressed', 'released' or 'continuous'.")
  assert(type(Object) == "table", "ERROR: Object must be a table.")
  local fct = Object[FctName]
  assert(type(fct) == "function", "ERROR: '"..FctName.."' must refer to the name of a function.")

  local objId = GetObjectId(Object)
  local UID = objId .. "_" .. FctName
  self.actions[UID] = {}
  self.actions[UID].ObjectId = objId
  self.actions[UID].Object = Object
  self.actions[UID].FctName = FctName
  self.actions[UID].State = State

  if not self.objassoc[objId] then
    local joyId = GetNextJoystickId(self)
    self.objassoc[objId] = joyId
  end
  return UID
end

--[[
proto Controller:dissociate()
--]]
function Controller:dissociate()
  self.objassoc = {}
  self.actions = {}
  if self.gamepad then
    self.gamepad:reset()
  end
end
--[[
proto Controller:update(dt)
--]]
function Controller:update(dt)
  --Looking if a key or button has been pressed
  local res = false
  local dir = 0
  local keybtn = nil
  for name,action in pairs(self.actions) do
    for _,k in pairs(action.Keys) do
      if k.ctl == "keyboard" then
        if action.State == "pressed" then
          res, dir, keybtn = self.keyboard:key_down(k.key)
        elseif action.State == "released" then
          res, dir, keybtn = self.keyboard:key_up(k.key)
        else
          res, dir, keybtn = self.keyboard:key(k.key)
        end
      elseif k.ctl == "gamepad" then
        local joyId = self.objassoc[action.ObjectId]
        if joyId then
          if action.State == "pressed" then
            res, dir, keybtn = self.gamepad:button_down(joyId, k.key, k.dir)
          elseif action.State == "released" then
            res, dir, keybtn = self.gamepad:button_up(joyId, k.key, k.dir)
          else
            res, dir, keybtn = self.gamepad:button(joyId, k.key, k.dir)
          end
        end
      end
      if res then
        action.Object[action.FctName](action.Object, dir, dt, keybtn)
        res = false
      end
    end
  end
  self.keyboard:update(dt)
  self.gamepad:update(dt)
end

function Controller:toString(NoTitle)
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
Controller.__tostring = function(Controller, NoTitle) return Controller:toString(NoTitle) end
Controller.__index = Controller
Controller.__name = "Controller"
return Controller