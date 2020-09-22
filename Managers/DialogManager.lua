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
.P DIALOGCONTINUE
Texte à afficher pour indiquer comment continuer le dialogue.
.P DIALOGSKIP
Texte à afficher pour le bouton qui permet de passer le dialogue.
.P TITLE (obligatoire)
Titre de la conversation courante.
.P TEXT
Texte de la conversation courante.
.P IMAGE
Image de la conversation courante. Si des coordonnées sont ajoutées après le chemin de l'image, celle-ci s'affichera aux coordonnées renseignées.
.P FONT
Police de caractère de la conversation courante.
.P MUSIC
Musique de la conversation courante.
.P POSITION
Position de la conversation courante.
]]--

local DialogManager = {
  _TITLE       = 'Dina GE Dialog Manager',
  _VERSION     = '2.0.3',
  _URL         = 'https://dina.lacombedominique.com/documentation/managers/dialogmanager/',
  _LICENSE     = [[
    ZLIB Licence

    Copyright (c) 2020 LACOMBE Dominique

    This software is provided 'as-is', without any express or implied warranty. In no event will the authors be held liable for any damages arising from the use of this software.
    Permission is granted to anyone to use this software for any purpose, including commercial applications, and to alter it and redistribute it freely, subject to the following restrictions:
        1. The origin of this software must not be misrepresented; you must not claim that you wrote the original software. If you use this software in a product, an acknowledgment in the product documentation would be appreciated but is not required.
        2. Altered source versions must be plainly marked as such, and must not be misrepresented as being the original software.
        3. This notice may not be removed or altered from any source distribution.
  ]]
}

--[[
proto const DialogManager.New(ActionKey, Width, Border)
.D This function creates a new DialogManager object.
.P ActionKey
Key used to speed up the current text or to go to the next dialog.
.P Width
Width in pixels that all components must not exceed.
.P Margin
Size in pixels for the margin of the text.
.P Padding
Size in pixels for the padding of the text.
.R Return an instance of DialogManager object.
]]--
function DialogManager.New(ActionKey, Width, Height, Margin, Padding)
  local self = setmetatable({}, DialogManager)
  self.GameEngine = require('DinaGE')
  self:SetActionKey(ActionKey)
  self.width = Width or love.graphics.getWidth()
  self.height = Height or love.graphics.getHeight()
  self.margin = SetDefaultNumber(Margin, 0)
  self.padding = SetDefaultNumber(Padding, 0)
  self.canvas = love.graphics.newCanvas(self.width, self.height)
  self.thread = love.thread.newThread("DinaGE/Threads/PlayDialogs.lua")
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
  return self
end

--[[
proto DialogManager:AddComponent(ComponentType, Args...)
.D This function add a new component defined by its given name and type. Can not be as the same type of the manager.
.P ComponentType
Type of the component to add.
.P Args...
Other arguments needed to create the component.
.R Returns a new instance of the component.
]]--
function DialogManager:AddComponent(ComponentType, ...)
  if ComponentType == type(self) then
    return nil
  end
  if not self.components then
    self.components = {}
  end
  local component = self.GameEngine:CreateComponent(ComponentType, ...)
  table.insert(self.components, component)
  return component
end



--[[
proto DialogManager:AddDialogs(File, Name)
.D This function allow to add a new dialog or a group of dialogs. If a name is filled, the new dialog or group of dialog is added using the name key.
.P File
Path and name of a dialog file. Must be with a Lua extension.
.P Name
Name used to store the dialog or group of dialog.
]]--
function DialogManager:AddDialogs(File, Name)
  local newDialog = self:UnpackDialogFile(File)
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
proto MenuManager.CallbackZOrder()
.D This functions is used to ensure that all components are drawn in the right order.
]]--
function DialogManager:CallbackZOrder()
  SortTableByZOrder(self.components)
end

--[[
proto DialogManager:Draw()
.D This function draw the dialog at the right place with the dev's options and applyed the width and border.
]]--
function DialogManager:Draw()
  if self.currentdialog and self.currentdialog.start then
    love.graphics.setColor(1,1,1,1)
    for _, component in pairs(self.components) do
      if component.Draw then
        component:Draw()
      end
    end
    love.graphics.setColor(1,1,1,1)
  end
end

--[[
proto DialogManager:GetDialog()
.D This function retreives the current dialog.
.R Current dialog.
]]--
function DialogManager:GetDialog()
  if self.dialogfinished == false then
    return self.currentdialog[self.numDialog]
  end
end

--[[
proto DialogManager:IsActionKeyPressed()
.D This function indicates if the action key is pressed. The value "mb1" and "mb2" are used for the mouse button left and right.
.R True if the action key or mouse button is pressed; false otherwise.
]]--
function DialogManager:IsActionKeyPressed()
  if string.sub(self.key, 1, 2) == "mb" then
    local numbtn = string.sub(self.key, -1)
    return love.mouse.isDown(tonumber(numbtn))
  end
  return love.keyboard.isDown(self.key)
end

--[[
proto DialogManager:IsDialogFinished()
.D This function indicates if the dialog is finished or not.
.R True if the dialog is finished; false otherwise.
]]--
function DialogManager:IsDialogFinished()
  return self.dialogfinished
end

--[[
proto DialogManager:Play(Name)
.D This function launch the dialog.
.P Name
Name to retreive the dialog.
]]--
function DialogManager:Play(Name)
  if not (self.currentdialog and self.currentdialog.start) then
    local dialog = self.dialogues[Name]
    if dialog and not dialog.start then
      self.currentdialog = dialog
      self.length = #dialog
      self.numDialog = 1
      -- Ajout des composants à afficher
      if self.currentdialog.image then
        self.backgroundImageComponent = self:AddComponent("Panel")
        local img = love.graphics.newImage(self.currentdialog.image.name)
        self.backgroundImageComponent:SetImage(img)
        self.backgroundImageComponent:SetZOrder(-10)
      end
      if self.currentdialog.sound then
        self.backgroundSoundComponent = self:AddComponent("Sound", self.currentdialog.sound.file, self.currentdialog.sound.type)
        self.backgroundSoundComponent:Play()
      end
      self.currentdialogtext = self.currentdialog[self.numDialog].text
      self:SetComponents(self.currentdialog[self.numDialog])

      self.dialogues[Name].start = true
      self.start = true
    end
  end
end

--[[
proto DialogManager:ResetComponents()
.D This function remove all components.
]]--
function DialogManager:ResetComponents()
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
proto DialogManager:RestartComponents()
.D This function resets all components needed to display the dialog.
]]--
function DialogManager:RestartComponents()
  local Dialog = self.currentdialog[self.numDialog]
  -- Background image
  if self.backgroundImageComponent ~= nil then
    local img
    if self.currentdialog.image ~= nil and self.currentdialog.image.name ~= "" then
      img = love.graphics.newImage(self.currentdialog.image.name)
    end
    self.backgroundImageComponent:SetImage(img)
    self.backgroundImageComponent:SetZOrder(-10)
  end
  -- Background sound
  if self.backgroundSoundComponent then
    if not self.backgroundSoundComponent:IsSameSound(self.currentdialog.sound.file, 
      self.currentdialog.sound.type) then
      self.backgroundSoundComponent:SetNewSound(self.currentdialog.sound.file, 
        self.currentdialog.sound.type)
    else
      if not self.backgroundSoundComponent:IsPlaying() then
        self.backgroundSoundComponent:Play()
      end
    end
  elseif self.currentdialog.sound then
    self.backgroundSoundComponent = self:AddComponent("Sound", self.currentdialog.sound.file, self.currentdialog.sound.type)
    if not self.backgroundSoundComponent:IsPlaying() then
      self.backgroundSoundComponent:Play()
    end
  end
  -- Front image
  local img
  if Dialog.image ~= nil and Dialog.image.name ~= "" then
    img = love.graphics.newImage(Dialog.image.name)
  end
  self.imageComponent:SetImage(img)
  -- Title
  if self.titleComponent then
    if Dialog.title then
      if not Dialog.title.text then Dialog.title.text = "" end
      self.titleComponent:SetContent(Dialog.title.text)
      if Dialog.title.font then
        self.titleComponent:SetFont(Dialog.title.font.name,Dialog.title.font.size)
      end
      if Dialog.title.align then
        self.titleComponent:SetAlignments(Dialog.title.align)
      end
    else
      self.titleComponent = nil
    end
  elseif Dialog.title.text then
    self.titleComponent = self:AddComponent("Text", Dialog.title.text)
    self.titleComponent:SetDimensions(self.width-self.border, self.height-self.border)
    self.titleComponent:SetFont(Dialog.title.font.name, Dialog.title.font.size)
    self.titleComponent:SetAlignments(Dialog.title.align)
  end
  -- Text
  if self.textComponent then
    self.textComponent:SetContent("")
    self.textComponent:SetFont(Dialog.font.name,Dialog.font.size)
  elseif Dialog.text then
    self.textComponent = self:AddComponent("Text","")
    self.textComponent:SetDimensions(self.width-self.border, self.height-self.border)
    self.textComponent:SetFont(Dialog.font.name,Dialog.font.size)
  end
  if self.continueComponent then
    self.continueComponent:SetVisible(false)
  else
    self.continueComponent = self:AddComponent("Text", Dialog.continue)
    self.continueComponent:SetTimers(0.8,0.8,-1)
    self.continueComponent:SetFont(Dialog.font.name, Dialog.font.size)
    self.continueComponent:SetDimensions(self.width-self.border*2, self.continueComponent:GetTextHeight())
    self.continueComponent:SetAligments("right")
    self.continueComponent:SetVisible(false)
  end

  if self.soundComponent then
    self.soundComponent:Stop()
    if Dialog.sound then
      self.soundComponent:SetNewSound(Dialog.sound.file)
      self.soundComponent:Play()
    else
      self.soundComponent = nil
    end
  elseif Dialog.sound then
    self.soundComponent = self:AddComponent("Sound", Dialog.sound.file, Dialog.sound.type)
    self.soundComponent:Play()
  end

  self:SetDialogPosition(Dialog)
end

--[[
proto DialogManager:RetreiveDisplayText()
.D This function retreive the text from the thread.
]]--
function DialogManager:RetreiveDisplayText()
  local text = self.channel.text:pop()
  if text then
    self.textComponent:SetContent(text)
  end
end

--[[
proto DialogManager:SetActionKey(Key)
.D This function indicates which key will be used to increase the speed of the text and go to the next dialog text.
.P Key
Code of the key used to increase the speed of the text and go to the next dialog text.
]]--
function DialogManager:SetActionKey(Key)
  self.key = Key
end

function DialogManager:SetBackColor(Color)
  self.backcolor = Color
end
function DialogManager:SetBackColorComponents(Color)
  if self.titleComponent then
    self.titleComponent:SetBackColor(Color)
  end
  if self.textComponent then
    self.textComponent:SetBackColor(Color)
  end
  if self.continueComponent then
    self.continueComponent:SetBackColor(Color)
  end
end
--[[
proto DialogManager:SetComponents(Dialog)
.D This function creates all components needed to the dialog and start the thread.
]]--
function DialogManager:SetComponents(Dialog)
  if Dialog.sound then
    self.soundComponent = self:AddComponent("Sound", Dialog.sound.file, Dialog.sound.type)
    self.soundComponent:Play()
  end
  if self.imageComponent == nil then
    self.imageComponent = self:AddComponent("Panel")
  end
  if Dialog.image ~= nil and Dialog.image.name ~= "" then
    local img = love.graphics.newImage(Dialog.image.name)
    self.imageComponent:SetImage(img)
  else
    self.imageComponent:SetImage()
  end
  if Dialog.title then
    local font = Dialog.title.font or Dialog.font
    self.titleComponent = self:AddComponent("Text",Dialog.title.text)
    self.titleComponent:SetDimensions(self.width-self.border*2, self.height-self.border*2)
    self.titleComponent:SetFont(font.name, font.size)
    self.titleComponent:SetAlignments(Dialog.title.align)
  end
  self.textComponent = self:AddComponent("Text", "")
  self.textComponent:SetDimensions(self.width-self.border*2, self.height-self.border*2)
  self.textComponent:SetFont(Dialog.font.name, Dialog.font.size)

  self.continueComponent = self:AddComponent("Text", Dialog.continue)
  self.continueComponent:SetTimers(0.8,0.8,-1)
  self.continueComponent:SetFont(Dialog.font.name, Dialog.font.size)
  self.continueComponent:SetDimensions(self.width-self.border*2, self.continueComponent:GetTextHeight())
  self.continueComponent:SetAlignments("right")
  self.continueComponent:SetVisible(false)

  self:SetDialogPosition(Dialog)

  if self.backcolor then
    self:SetBackColorComponents(self.backcolor)
  end
  self.thread:start(Dialog.text)
end

--[[
proto DialogManager:SetDialogPosition(Dialog)
.D This function update the position and alignment of all dialog components using the datas from the given dialog.
.P Dialog
Table containing all datas of the current dialog.
]]--
local SCREEN_HEIGHT = love.graphics.getHeight()
function DialogManager:SetDialogPosition(Dialog)
  if Dialog.position then
    -- calcul de toutes les positions des composants
    local x = Dialog.position.x + self.border
    local y = Dialog.position.y
    if self.continueComponent then
      local cy
      if self.height + y > SCREEN_HEIGHT then
        cy = SCREEN_HEIGHT - self.border - self.continueComponent:GetTextHeight()
      else
        cy = y + self.height - self.border - self.continueComponent:GetTextHeight()
      end
      self.continueComponent:SetPosition(x, cy)
    end
    if self.textComponent then
      self.textComponent:SetPosition(x, y)
    end
    if self.titleComponent then
      y = y - self.titleComponent:GetTextHeight() - self.border
      self.titleComponent:SetPosition(x, y)
    end
    if self.imageComponent then
      local ix = Dialog.image.x
      local iy = Dialog.image.y
      local ox = 0
      local oy = 0
      if ix == nil and iy == nil then
        ix = x
        iy = y
        oy = self.imageComponent:GetHeight()
        if self.titleComponent then
          if Dialog.title.align then
            local currentwidth = Dialog.width or self.width
            if Dialog.title.align == "center" then
              ix = (x + currentwidth - self.border)/2
              ox = self.imageComponent:GetWidth() / 2
            elseif Dialog.title.align == "right" then
              ix = currentwidth - self.border
              ox = self.imageComponent:GetWidth()
            end
          end
        end
      end
      self.imageComponent:SetPosition(ix, iy)
      self.imageComponent:SetImageOrigin(ox, oy)
    end
  end
end

--[[
proto DialogManager:Stop()
.D This function stops the current dialog and reset all components.
]]--
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
  self:ResetComponents()
  self.dialogfinished = true
end

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

--[[
proto DialogManager:UnpackDialogFile(File)
.D This function read the given file to extract all datas for the dialogs.
.P File
Name and path of the file containing the dialog.
.R Returns a table containing all datas extracted from the file.
]]--
function DialogManager:UnpackDialogFile(pFile)
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

    elseif line == "STOP" then
      newdialog = false
      -- Traitement du dernier texte
      if next(currsubtext) ~= nil then
        if currsubtext.font or currsubtext.font == nil then
          currsubtext.font = dialogfont or defaultfont
          end
        if currsubtext.music or currsubtext.music == nil then
          currsubtext.music = dialogmusic or defaultmusic
          end
        if currsubtext.position or currsubtext.position == nil then
          currsubtext.position = dialogposition or defaultposition
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
          if currsubtext.font == nil then currsubtext.font = dialogfont or defaultfont end
          if currsubtext.music == nil then currsubtext.music = dialogmusic or defaultmusic end
          if currsubtext.position == nil then currsubtext.position = dialogposition or defaultposition end
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
proto DialogManager:Update(dt)
.D This function update all components and the dialog manager.
.P dt
Delta-time
]]--
function DialogManager:Update(dt)
  for _, component in pairs(self.components) do
    if component.Update then
      component:Update(dt)
    end
  end
  self:UpdateDialogManager(dt)
end

--[[
proto DialogManager:UpdateDialogManager(dt)
.D This function update the dialog text and increase the speed for displaying the text if the ActionKey is pressed. If the dialog text if completely displayed, this function shows the next dialog text.
.P dt
Delta-time
]]--
function DialogManager:UpdateDialogManager(dt)
  if self.currentdialog and self.currentdialog.start then
    if self:IsActionKeyPressed() then
      local running = self.thread:isRunning()
      if running then
        self.keypressed = true
        self.channel.speed:push(true)
        self:RetreiveDisplayText()
        return
      end -- running
      if self.keypressed and self.dialogfinished == false then
        self:RetreiveDisplayText()
        return
      end -- self.keypressed
      self.numDialog = self.numDialog + 1
      if self.numDialog > self.length then
        self.currentdialog.start = false
        self:ResetComponents()
        self.start = false
        self.dialogfinished = true
      else
        self.currentdialogtext = self.currentdialog[self.numDialog].text
--        local text = self.currentdialog[self.numDialog].text
        self.thread:start(self.currentdialogtext)
        self:RestartComponents()
        return
      end
    end -- love.keyboard.isDown(self.key)
    if self.keypressed then
      self.keypressed = false
    end
    -- Récupération du texte à afficher
    self:RetreiveDisplayText()
    if self.textComponent and self.currentdialogtext == self.textComponent:GetContent() then
      self.continueComponent:SetVisible(true)
    end
  end -- self.start
end -- Update(dt)
--
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
DialogManager.__tostring = function(NoTitle) return DialogManager:ToString(NoTitle) end
DialogManager.__index = DialogManager
return DialogManager