local DialogManager = {
  _VERSION     = 'Dina GE Dialog Manager v1.3',
  _DESCRIPTION = 'Dialog Manager in Dina Game Engine',
  _URL         = 'https://dina.lacombedominique.com/documentation/managers/dialogmanager/',
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
proto const DialogManager.New()
.D This function creates a new DialogManager object.
.R Return an instance of DialogManager object.
]]--
function DialogManager.New()
  local self = setmetatable({}, DialogManager)
  self.GameEngine = require('DinaGE')
  return self
end

--[[
proto DialogManager.LoadDialogs(File)
.D This function load all dialogs from the given file.
]]--
function DialogManager.LoadDialogs(File)
  local thread = love.thread.newThread("DinaGE/Threads/LoadDialogs.lua")
  thread:start(File)
end

--[[
proto DialogManager.Play(Name)
.D This function launch the dialog.
.P Name
Name to retreive the dialog.
]]--
function DialogManager.Play(Name)
  local thread = love.thread.newThread("DinaGE/Threads/PlayDialogs.lua")
  thread:start(Name)
end

DialogManager.__call = function() return DialogManager.New() end
DialogManager.__index = DialogManager
DialogManager.__tostring = function() return "DialogManager" end
return DialogManager