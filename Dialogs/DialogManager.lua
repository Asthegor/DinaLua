--[[
proto Liste des entrées possibles dans un fichier de dialogue.
.D Chaque entrée doit obligatoirement être suivie du signe = sans aucun espace avant.\nLes entrées minimales pour un dialogue sont les suivantes (dans l'ordre) :\nDEFAULTFONT, START, NAME, TITLE*, TEXT*, STOP\nLes entrées signalées par une * peuvent être répétées.\n\nLa liste ci-dessous vous énumère toutes les entrées prises en compte dans la version courante.
.P DEFAULTFONT (obligatoire)
Police de caractère par défaut à utiliser pour tous les dialogues.
.P DEFAULTMUSIC
Musique par défaut à jouer pour tous les dialogues.
.P DEFAULTPOSITION
Position d'affichage à utiliser pour tous les dialogues.
.P START (obligatoire)
Indique le début d'un dialogue.
.P NAME (obligatoire)
Nom du dialogue pour pouvoir l'identifier lors de son appel.
.P DIALOGFONT
Police de caractère par défaut du dialogue courant.
.P DIALOGMUSIC
Musique par défaut du dialogue courant.
.P DIALOGPOSITION
Position par défaut du dialogue courant.
.P TITLE (obligatoire)
Titre de la conversation courante.
.P TEXT
Texte de la conversation courante.
.P IMAGE
Image de la conversation courante. Elle se place toujours au-dessus du texte.
.P FONT
Police de caractère de la conversation courante.
.P MUSIC
Musique de la conversation courante.
.P POSITION
Position de la conversation courante.
]]--

local DialogManager = {
  _TITLE       = 'Dina Game Engine - Dialog Manager',
  _VERSION     = '3.1.6',
  _URL         = 'https://dina.lacombedominique.com/documentation/dialogs/dialogmanager/',
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

local Dina = require('Dina')

-- Fonctions locales
local function UnpackLine(pLine, pKey, pSep)
  pLine = pLine:gsub(pKey, "")
  local tdeb = 0
  local tend
  local result = {}
  repeat
    tend = pLine:find(pSep,tdeb+1)
    local val = pLine:sub(tdeb,tend):gsub(pSep, "")
    table.insert(result, val)
    tdeb = tend
  until (tend == nil)
  return result
end

local function UnpackDialogFile(pFile)
  local dialogs = {}

  local defaultfont = {}
  local defaultmusic = {}
  local defaultposition = {}
  local defaultwidth = nil

  local currentdialog = {}
  local newdialog = false

  local dialogfont = {}
  local dialogmusic = {}
  local dialogposition = {}
  local dialogwidth = nil
  local dialogcontinue = {}
  local dialogskip = {}
  local currsubtext = {}
  local dialogname = ""

  for line in love.filesystem.lines(pFile) do
    if line:find("DEFAULTFONT=", 1) then
      local font = UnpackLine(line, "DEFAULTFONT=", "|")
      if font[1] ~= "" then
        defaultfont =  { name = font[1],  size = tonumber(font[2]) }
      end

    elseif line:find("DEFAULTMUSIC=", 1) then
      local sound = UnpackLine(line, "DEFAULTMUSIC=", "|")
      if sound[1] ~= "" then
        defaultmusic = { file = sound[1], type = sound[2] or "stream" }
      end

    elseif line:find("DEFAULTPOSITION=", 1) then
      local position = UnpackLine(line, "DEFAULTPOSITION=", "|")
      if position[1] ~= "" then
        defaultposition = { x = tonumber(position[1]), y = tonumber(position[2]) }
      end

    elseif line:find("DEFAULTWIDTH=", 1) then
      defaultwidth = tonumber(UnpackLine(line, "DEFAULTWIDTH=", "|")[1])

    elseif line == "START" then
      newdialog = true
      currentdialog = {}
      currsubtext = {}

    elseif line == "STOP" then
      newdialog = false
      -- Traitement du dernier texte
      if next(currsubtext) ~= nil then
        if currsubtext.font or currsubtext.font == nil then
          currsubtext.font = next(dialogfont) ~= nil and dialogfont or defaultfont
          end
        if currsubtext.music or currsubtext.music == nil then
          currsubtext.music = dialogmusic or defaultmusic
          end
        if currsubtext.position or currsubtext.position == nil then
          currsubtext.position = next(dialogposition) ~= nil and dialogposition or defaultposition
        end
        if currsubtext.width or currsubtext.width == nil then
          currsubtext.width = dialogwidth or defaultwidth
          end
        if currsubtext.skip ~= nil and (currsubtext.skip.font or currsubtext.skip.font == nil) then
            currsubtext.skip.font = dialogfont or defaultfont
        end
        table.insert(currentdialog, currsubtext)
        currsubtext = {}
      end

      -- Préparation de l'entrée dans la table
      dialogs[dialogname] = {}
      -- Ajout du dialogue
      dialogs[dialogname] = currentdialog
      dialogname = ""

    elseif newdialog then

      if line:find("NAME=", 1) then
        dialogname = UnpackLine(line, "NAME=", "|")[1]

      elseif line:find("DIALOGFONT=", 1) then
        local font = UnpackLine(line, "DIALOGFONT=", "|")
        if font[1] ~= "" then
          dialogfont =  { name = font[1],  size = tonumber(font[2]) }
        end

      elseif line:find("DIALOGMUSIC=", 1) then
        local sound = UnpackLine(line, "DIALOGMUSIC=", "|")
        if sound[1] ~= "" then
          dialogmusic = { file = sound[1], type = sound[2] or "stream" }
        end

      elseif line:find("DIALOGPOSITION=", 1) then
        local position = UnpackLine(line, "DIALOGPOSITION=", "|")
        if position[1] ~= "" then
          dialogposition = { x = tonumber(position[1]), y = tonumber(position[2]) }
        end

      elseif line:find("DIALOGWIDTH=", 1) then
        dialogwidth = tonumber(UnpackLine(line, "DIALOGWIDTH=", "|")[1])

      elseif line:find("DIALOGCONTINUE=", 1) then
        dialogcontinue = UnpackLine(line, "DIALOGCONTINUE=", "|")[1]

      elseif line:find("DIALOGSKIP=", 1) then
        local skip = UnpackLine(line, "DIALOGSKIP=", "|")
        if skip and skip[1] ~= "" then
          dialogskip = {}
          dialogskip.text = skip[1]
          dialogskip.font = { name = skip[2],  size = tonumber(skip[3]) }
        end

      elseif line:find("TITLE=", 1) then

        -- Ajout du sous-dialogue précédent
        if next(currsubtext) ~= nil then
          if currsubtext.font == nil then currsubtext.font = next(dialogfont) ~= nil and dialogfont or defaultfont end
          if currsubtext.music == nil then currsubtext.music = dialogmusic or defaultmusic end
          if currsubtext.position == nil then currsubtext.position = next(dialogposition) ~= nil and dialogposition or defaultposition end
          table.insert(currentdialog, currsubtext)
        end

        local title = UnpackLine(line, "TITLE=", "|")
        currsubtext = {}
        currsubtext.title = {}
        -- Texte du titre
        currsubtext.title.text = title[1]
        -- Police de caractères du titre
        currsubtext.title.font = dialogfont or defaultfont or {}
        if title[2] and title[2] ~= "" then currsubtext.title.font =  { name = title[2],  size = tonumber(title[3]) } end
        -- Alignement du titre
        currsubtext.title.align = "left"
        if title[4] and title[4] ~= "" then currsubtext.title.align = string.lower(title[4]) end

        currsubtext.continue = {}
        currsubtext.continue = dialogcontinue
        currsubtext.skip = {}
        currsubtext.skip = dialogskip

      elseif line:find("TEXT=", 1) then
        currsubtext.text = UnpackLine(line, "TEXT=", "|")[1]

      elseif line:find("IMAGE=", 1) then
        local image = UnpackLine(line, "IMAGE=", "|")
        currsubtext.image = {}
        currsubtext.image.name = image[1]
        currsubtext.image.x = image[2]
        currsubtext.image.y = image[3]

      elseif line:find("MUSIC=", 1) then
        local sound = UnpackLine(line, "MUSIC=", "|")
        if sound[1] ~= "" then
          currsubtext.music = { file = sound[1], type = sound[2] or "stream" }
        end

      elseif line:find("POSITION=", 1) then
        local position = UnpackLine(line, "POSITION=", "|")
        if position[1] ~= "" then 
          currsubtext.position = { x = tonumber(position[1]), y = tonumber(position[2]) }
        end

      elseif line:find("WIDTH=", 1) then
        currsubtext.width = tonumber(UnpackLine(line, "WIDTH=", "|")[1])

      end
    end
  end
  return dialogs
end


--[[
proto const DialogManager.New(Name, ActionKey, Width, Border)
.D This function creates a new DialogManager object.
.P Name
Name of the component in Dina Game Engine.
.P ActionKey
Key used to speed up the current text or to go to the next dialog.
.P Width
Width in pixels that all components must not exceed.
.P Border
Size in pixels for the border.
.R Return an instance of DialogManager object.
]]--
function DialogManager.new(ActionKey, Width, Height, Border)
  local self = setmetatable({}, DialogManager)
  self:setActionKey(ActionKey)
  self.width = Width or Dina.width
  if self.width + Border*2 > Dina.width then
    self.width = self.width - Border * 2
  end
  self.height = Height or Dina.height
  if self.height + Border*2 > Dina.height then
    self.height = self.height - Border * 2
  end
  self.border = SetDefaultNumber(Border, 0)
  self.canvas = love.graphics.newCanvas(self.width, self.height)
  self.thread = love.thread.newThread("Dina/Threads/PlayDialogs.lua")
  self.channel = {}
  self.channel.text = love.thread.getChannel('NewText')
  self.channel.speed = love.thread.getChannel('Speed')
  self.channel.stop = love.thread.getChannel('Stop')
  self.start = false
  self.currentdialog = nil
  self.numDialog = 0
  self.currentdialogtext = ""
  self.components = {}
  self.keypressed = false
  self.dialogfinished = false
  self.backcolor = nil
  self.continuedialog = false
  return self
end

--[[
proto DialogManager:addComponent(ComponentName, ComponentType, Args...)
.D This function add a new component defined by its given name and type. Can not be as the same type of the manager.
.P ComponentName
Name of the component to add.
.P ComponentType
Type of the component to add.
.P Args...
Other arguments needed to create the component.
.R Returns a new instance of the component.
]]--
function DialogManager:addComponent(ComponentType, ...)
  if ComponentType == type(self) then
    return nil
  end
  if not self.components then
    self.components = {}
  end
  local component = Dina(ComponentType, ...)
  Dina:removeComponent(component)
  
  table.insert(self.components, component)
  return component
end



--[[
proto DialogManager:addDialogs(File, Name)
.D This function allow to add a new dialog or a group of dialogs. If a name is filled, the new dialog or group of dialog is added using the name key.
.P File
Path and name of a dialog file. Must be with a Lua extension.
.P Name
Name used to store the dialog or group of dialog.
]]--
function DialogManager:addDialogs(File, Name)
  -- Read dialog file to extract datas
  local newDialog = UnpackDialogFile(File)
--  local newDialog = require(File)
  if not self.dialogues then
    self.dialogues = {}
  end
  if Name then
    self.dialogues[Name] = newDialog
  else
    for key, value in pairs(newDialog) do
      self.dialogues[key] = value
    end
  end
end

--[[
proto MenuManager:callbackZOrder()
.D This functions is used to ensure that all components are drawn in the right order.
]]--
function DialogManager:callbackZOrder()
  SortTableByZOrder(self.components)
end

--[[
proto DialogManager:draw()
.D This function draw the dialog at the right place with the dev's options and applyed the width and border.
]]--
function DialogManager:draw()
  if self.currentdialog and self.currentdialog.start then
    local currentwidth = self.currentdialog.width or self.width
    love.graphics.setColor(1,1,1,1)
    for key, component in pairs(self.components) do
      if component.draw then
        component:draw()
      end
    end
    love.graphics.setColor(1,1,1,1)
  end
end

function DialogManager:getDialog()
  if self.dialogfinished == false then
    return self.currentdialog[self.numDialog]
  end
end

--[[
proto DialogManager:getName()
.D This function returns the name of the dialog manager.
.R returns the name of the dialog manager.
]]--
function DialogManager:getName()
  return self.name
end

function DialogManager:isActionKeyPressed()
  if self.key == "mb1" then
    return love.mouse.isDown(1)
  end
  return love.keyboard.isDown(self.key)
end
function DialogManager:isDialogFinished()
  return self.dialogfinished
end

function DialogManager:continueDialog()
  self.continuedialog = true
end

--[[
proto DialogManager:play(Name)
.D This function launch the dialog.
.P Name
Name to retreive the dialog.
]]--
function DialogManager:play(Name)
  if not (self.currentdialog and self.currentdialog.start) then
    local dialog = self.dialogues[Name]
    if dialog and not dialog.start then
      self.currentdialog = dialog
      self.length = #dialog
      self.numDialog = 1
      -- Ajout des composants à afficher
      if self.currentdialog.image then
        self.backgroundImageComponent = self:addComponent("Image")
        local img = love.graphics.newImage(self.currentdialog.image.name)
        self.backgroundImageComponent:setImage(img)
        self.backgroundImageComponent:setZOrder(-10)
      end
      if self.currentdialog.sound then
        self.backgroundSoundComponent = self:addComponent("Sound", self.currentdialog.sound.file, self.currentdialog.sound.type)
        self.backgroundSoundComponent:play()
      end
      self.currentdialogtext = self.currentdialog[self.numDialog].text
      self:setComponents(self.currentdialog[self.numDialog])

      self.dialogues[Name].start = true
      self.start = true
    end
  end
end

--[[
proto DialogManager:resetComponents()
.D This function remove all components.
]]--
function DialogManager:resetComponents()
  for i=#self.components, 1, -1 do
    table.remove(self.components, i)
  end
  self.backgroundImageComponent = nil
  self.backgroundSoundComponent = nil
  self.imageComponent = nil
  self.titleComponent = nil
  self.textComponent = nil
  self.continueComponent = nil
end

--[[
proto DialogManager:restartComponents()
.D This function resets all components needed to display the dialog.
]]--
function DialogManager:restartComponents()
  local Dialog = self.currentdialog[self.numDialog]
  -- Background image
  if self.backgroundImageComponent then
    local img
    if self.currentdialog.image ~= nil and self.currentdialog.image.name ~= "" then
      img = love.graphics.newImage(self.currentdialog.image.name)
    end
    self.backgroundImageComponent:setImage(img)
    self.backgroundImageComponent:setZOrder(-10)
  end
  -- Background sound
  if self.backgroundSoundComponent then
    if not self.backgroundSoundComponent:isSameSound(self.currentdialog.sound.file, 
      self.currentdialog.sound.type) then
      self.backgroundSoundComponent:setNewSound(self.currentdialog.sound.file, 
        self.currentdialog.sound.type)
    else
      if not self.backgroundSoundComponent:isPlaying() then
        self.backgroundSoundComponent:play()
      end
    end
  elseif self.currentdialog.sound then
    self.backgroundSoundComponent = self:addComponent("Sound", self.currentdialog.sound.file, self.currentdialog.sound.type)
    if not self.backgroundSoundComponent:isPlaying() then
      self.backgroundSoundComponent:play()
    end
  end
  -- Front image
  local img
  if next(Dialog.image) ~= nil and Dialog.image.name ~= "" then
    img = love.graphics.newImage(Dialog.image.name)
  end
  self.imageComponent:setImage(img)
  -- Title
  if self.titleComponent then
    if Dialog.title and next(Dialog.title) ~= nil then
      if not Dialog.title.text then Dialog.title.text = "" end
      self.titleComponent:setContent(Dialog.title.text)
      if Dialog.title.font then
        self.titleComponent:setFont(Dialog.title.font.name,Dialog.title.font.size)
      end
      if Dialog.title.align then
        self.titleComponent:setAlignments(Dialog.title.align)
      end
    else
      self.titleComponent = nil
    end
  elseif Dialog.title.text then
    self.titleComponent = self:addComponent("Text", Dialog.title.text)
    self.titleComponent:setDimensions(self.width-self.border, self.height-self.border)
    self.titleComponent:setFont(Dialog.title.font.name, Dialog.title.font.size)
    self.titleComponent:setAlignments(Dialog.title.align)
  end
  -- Text
  if self.textComponent then
    self.textComponent:setContent("")
    self.textComponent:setFont(Dialog.font.name,Dialog.font.size)
  elseif Dialog.text and next(Dialog.text) ~= nil then
    self.textComponent = self:addComponent("Text","")
    self.textComponent:setDimensions(self.width-self.border, self.height-self.border)
    self.textComponent:setFont(Dialog.font.name,Dialog.font.size)
  end
  if self.continueComponent then
    self.continueComponent:setVisible(false)
  elseif Dialog.continue and next(Dialog.continue) ~= nil then
    self.continueComponent = self:addComponent("Text", Dialog.continue)
    self.continueComponent:setTimers(0.8,0.8,-1)
    self.continueComponent:setFont(Dialog.font.name, Dialog.font.size)
    self.continueComponent:setDimensions(self.width-self.border*2, self.continueComponent:GetTextHeight())
    self.continueComponent:setAligments("right")
    self.continueComponent:setVisible(false)
  end

  if self.soundComponent then
    self.soundComponent:stop()
    if Dialog.sound and next(Dialog.sound) ~= nil then
      self.soundComponent:setNewSound(Dialog.sound.file)
      self.soundComponent:play()
    else
      self.soundComponent = nil
    end
  elseif Dialog.sound and next(Dialog.sound) ~= nil then
    self.soundComponent = self:addComponent("Sound", Dialog.sound.file, Dialog.sound.type)
    self.soundComponent:play()
  end

  self:setDialogPosition(Dialog)
end

--[[
proto DialogManager:retreiveDisplayText()
.D This function retreive the text from the thread.
]]--
function DialogManager:retreiveDisplayText()
  local text = self.channel.text:pop()
  if text then
    self.textComponent:setContent(text)
    self.textComponent:setDimensions(self.width, self.height)
  end
end

--[[
proto DialogManager:setActionKey(Key)
.D This function indicates which key will be used to increase the speed of the text and go to the next dialog text.
.P Key
Code of the key used to increase the speed of the text and go to the next dialog text.
]]--
function DialogManager:setActionKey(Key)
  self.key = Key
end

function DialogManager:setBackColor(Color)
  self.backcolor = Color
end
function DialogManager:setBackColorComponents(Color)
  if self.titleComponent then
    self.titleComponent:setBackColor(Color)
  end
  if self.textComponent then
    self.textComponent:setBackColor(Color)
  end
  if self.continueComponent then
    self.continueComponent:setBackColor(Color)
  end
end
--[[
proto DialogManager:setComponents(Dialog)
.D This function creates all components needed to the dialog and start the thread.
]]--
function DialogManager:setComponents(Dialog)
  if Dialog.sound then
    self.soundComponent = self:addComponent("Sound", Dialog.sound.file, Dialog.sound.type)
    self.soundComponent:play()
  end
  if self.imageComponent == nil then
    self.imageComponent = self:addComponent("Image")
  end
  if Dialog.image ~= nil and Dialog.image.name ~= "" then
    local img = love.graphics.newImage(Dialog.image.name)
    self.imageComponent:setImage(img)
  else
    self.imageComponent:setImage()
  end
  if Dialog.title then
    local font = Dialog.title.font or Dialog.font
    self.titleComponent = self:addComponent("Text",Dialog.title.text)
    self.titleComponent:setDimensions(self.width-self.border*2, self.height-self.border*2)
    self.titleComponent:setFont(font.name, font.size)
    self.titleComponent:setAlignments(Dialog.title.align)
  end
  self.textComponent = self:addComponent("Text", "")
  self.textComponent:setFont(Dialog.font.name, Dialog.font.size)
  self.textComponent:setDimensions(self.width-self.border*2, self.height-self.border*2)

  if next(Dialog.continue) ~= nil then
    self.continueComponent = self:addComponent("Text", Dialog.continue)
    self.continueComponent:setTimers(0.8,0.8,-1)
    self.continueComponent:setFont(Dialog.font.name, Dialog.font.size)
    self.continueComponent:setDimensions(self.width-self.border*2, self.continueComponent:getTextHeight())
    self.continueComponent:setAlignments("right")
    self.continueComponent:setVisible(false)
  end
  self:setDialogPosition(Dialog)

  if self.backcolor then
    self:setBackColorComponents(self.backcolor)
  end
  self.thread:start(Dialog.text)
end

--[[
proto DialogManager:setDialogPosition(Dialog)
.D This function update the position and alignment of all dialog components using the datas from the given dialog.
.P Dialog
Table containing all datas of the current dialog.
]]--
function DialogManager:setDialogPosition(Dialog)
  if next(Dialog.position) ~= nil then
    -- calcul de toutes les positions des composants
    local x = Dialog.position.x + self.border
    local y = Dialog.position.y
    if self.continueComponent then
      local cy
      if self.height + y > Dina.height then
        cy = Dina.height - self.border - self.continueComponent:getTextHeight()
      else
        cy = y + self.height - self.border - self.continueComponent:getTextHeight()
      end
      self.continueComponent:setPosition(x, cy)
    end
    if self.textComponent then
      self.textComponent:setPosition(x, y)
    end
    if self.titleComponent then
      y = y - self.titleComponent:getTextHeight() - self.border
      self.titleComponent:setPosition(x, y)
    end
    if self.imageComponent then
      local ix = Dialog.image.x
      local iy = Dialog.image.y
      local ox = 0
      local oy = 0
      if ix == nil and iy == nil then
        ix = x
        iy = y
        oy = self.imageComponent:getHeight()
        if self.titleComponent then
          if Dialog.title.align then
            local currentwidth = Dialog.width or self.width
            if Dialog.title.align == "center" then
              ix = (x + currentwidth - self.border)/2
              ox = self.imageComponent:getWidth() / 2
            elseif Dialog.title.align == "right" then
              ix = currentwidth - self.border
              ox = self.imageComponent:getWidth()
            end
          end
        end
      end
      self.imageComponent:setPosition(ix, iy)
      self.imageComponent:setOrigin(ox, oy)
    end
  end
end

function DialogManager:Stop()
  self.channel.stop:push(true)
  self.channel.text = nil
  self.channel.speed = nil
  self.start = false
  self.currentdialog.start = false
  self.currentdialog = nil
  self.numDialog = 0
  self.currentdialogtext = ""
  self.channel = nil
  self.thread = nil
  self:resetComponents()
  self.dialogfinished = true
end


--[[
proto DialogManager:update(dt)
.D This function update the dialog text and increase the speed for displaying the text if the ActionKey is pressed.
.P dt
Delta-time
]]--
function DialogManager:update(dt)
  for key, component in pairs(self.components) do
    if component.update then
      component:update(dt)
    end
  end
  self:updateDialogManager(dt)
end

function DialogManager:updateDialogManager(dt)
  if self.currentdialog and self.currentdialog.start then
    if self:isActionKeyPressed() or self.continuedialog then
      self.continuedialog = false
      local running = self.thread:isRunning()
      if running then
        self.keypressed = true
        self.channel.speed:push(true)
        self:retreiveDisplayText()
        return
      end -- running
      if self.keypressed and self.dialogfinished == false then
        self:retreiveDisplayText()
        return
      end -- keypressed
      self.numDialog = self.numDialog + 1
      if self.numDialog > self.length then
        self.currentdialog.start = false
        self:resetComponents()
        self.start = false
        self.dialogfinished = true
      else
        self.currentdialogtext = self.currentdialog[self.numDialog].text
        self.thread:start(self.currentdialogtext)
        self:restartComponents()
        return
      end
    end -- love.keyboard.isDown(self.key)
    if self.keypressed then
      self.keypressed = false
    end
    -- Récupération du texte à afficher
    self:retreiveDisplayText()
    if self.textComponent and self.currentdialogtext == self.textComponent:getContent() then
      if self.continueComponent then
        self.continueComponent:setVisible(true)
      end
    end
  end -- self.start
end -- Update(dt)


--[[
proto DialogManager:ToString(NoTitle)
.D This function display all variables containing in the current DialogManager instance (tables and functions are excluded).
.P NoTitle
Indicates if the title must be displayed (false) or not (true).
]]--
function DialogManager:ToString(NoTitle)
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
DialogManager.__tostring = function(DialogManager, NoTitle) return DialogManager:ToString(NoTitle) end
DialogManager.__index = DialogManager
DialogManager.__name = "DialogManager"
return DialogManager