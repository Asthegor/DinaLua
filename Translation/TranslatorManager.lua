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
local function IsValidLanguage(TranslatorManager, Language)
  return TranslatorManager.translations[Language] and true or false
end

--[[
proto const TranslatorManager.new()
.D This function creates an instance of TranslatorManager object.
.R Returns an instance of TranslatorManager object.
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

--[[
proto TranslatorManager:getTranslation(Language, Key)
.D This function returns the translation in the given language of the text defined by the given key.
.P Language
Language to use for the translation.
.P Key
Key to retreive the translated text.
,R Returns the translation in the given language of the text defined by the given key.
]]--
function TranslatorManager:getTranslation(Language, Key)
  return self.translations[Language][Key]
end

--[[
proto TranslatorManager:getFirstLanguage()
.D This function retreives the first language.
.R Returns the first language code (defined using the function loadFile).
]]--
function TranslatorManager:getFirstLanguage()
  return next(self.translations)
end

--[[
proto TranslatorManager:getLanguage()
.D This function returns the current language code.
.R Returns the current language code.
]]--
function TranslatorManager:getLanguage()
  return self.currentlanguage
end

--[[
proto TranslatorManager:setLanguage(Language)
.D This function defines the current language. Must be loaded by the lodFile function.
.P Language
Language to use for the translation.
.R Returns true if the language is one of the languages loaded by the lodFile function; otherwise false.
]]--
function TranslatorManager:setLanguage(Language)
  if IsValidLanguage(self, Language) then
    self.currentlanguage = Language
    return true
  end
  return false
end

--[[
proto TranslatorManager:getNextLanguage()
.D This function returns the next language available.
.D If it was the last language, return the first one.
.R Returns the next language available.
]]--
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

-- System functions
TranslatorManager.__index = TranslatorManager
return TranslatorManager