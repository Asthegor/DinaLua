local TranslatorManager = {
  _TITLE       = 'Dina Game Engine - Translator Manager',
  _VERSION     = '1.0.0',
  _URL         = 'https://dina.lacombedominique.com/documentation/translation/translatormanager/',
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

-- Declaration of the parent
local Dina = require("Dina")
local Parent = Dina:require("Manager")
setmetatable(TranslatorManager, {__index = Parent})

-- Local functions
local function UnpackLine(Line, Sep)
  local key, value
  local posSep = string.find(Line, Sep)
  if posSep then
    key = string.sub(Line, 1, posSep - 1)
    value = string.sub(Line, posSep + 1)
  end
  return key, value
end

--[[
proto const TranslatorManager.load()
.D This function load the module for the translation.
]]--
function TranslatorManager.new()
  local self = setmetatable(Parent.new(), TranslatorManager)
  self.mainlanguage = ""
  self.translations = {}
  self.currentlanguage = nil
  return self
end
--

--[[
proto TranslatorManager:loadFile(Language, File)
.D This function stores the translated values of the given file as the given language.
.P Language
Code of the language (or name of the language)
.P File
File containing the translations of the given language.
]]--
function TranslatorManager:loadFile(Language, File)
  if not self.currentlanguage then
    self.currentlanguage = Language
  end
  self.translations[Language] = {}
  local key, value
  for line in love.filesystem.lines(File) do
    key, value = UnpackLine(line, "=")
    if key then
      self.translations[Language][key] = value
    end
  end
end

function TranslatorManager:isValidLanguage(Language)
  return self.translations[Language] and true or false
end

function TranslatorManager:getTranslation(Language, Key)
  return self.translations[Language][Key]
end

function TranslatorManager:getFirstLanguage()
  return next(self.translations)
end

function TranslatorManager:getLanguage()
  return self.currentlanguage
end

function TranslatorManager:setLanguage(Language)
  if self:isValidLanguage(Language) then
    self.currentlanguage = Language
    return true
  end
  return false
end

function TranslatorManager:getNextLanguage()
  local language = next(self.translations)
  local found = false
  while language do
    if language == self.currentlanguage then
      found = true
    end
    language = next(self.translations, language)
    if found then break end
  end
  if not language then
    language = self:getFirstLanguage()
  end
  return language
end

TranslatorManager.__index = TranslatorManager
return TranslatorManager