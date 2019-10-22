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
proto const DialogManager.New(Name, ActionKey, Limit, Border)
.D This function creates a new DialogManager object.
.P Name
Name of the component in Dina Game Engine.
.P ActionKey
Key used to speed up the current text or to go to the next dialog.
.P Limit
Limit in pixels that all components must not exceed.
.P Border
Size in pixels for the border.
.R Return an instance of DialogManager object.
]]--
function DialogManager.New(Name, ActionKey, Limit, Border)
  local self = setmetatable({}, DialogManager)
  self.name = Name
  self.IndexComponents = {}
  self.GameEngine = require('DinaGE')
  self.canvas = love.graphics.newCanvas(GameEngine.ScreenWidth, GameEngine.ScreenHeight)
  if ActionKey and Limit then
    self:SetActionKey(ActionKey)
    self.limit = Limit
    self.border = SetDefaultNumber(Border, 0)
    self.thread = love.thread.newThread("DinaGE/Threads/PlayDialogs.lua")
    self.channel = {}
    self.channel.text = love.thread.getChannel('NewText')
    self.channel.speed = love.thread.getChannel('Speed')
    self.start = false
    self.currentdialog = nil
    self.numDialog = 0
    self.currenttext = ""
    self.Components = {}
    self.keypressed = false
    return self
  end
  return nil
end

--[[
proto DialogManager:AddComponent(ComponentName, ComponentType, ...)
.D This function add a new component defined by its given name and type. Can not be as the same type of the manager.
.P ComponentName
Name of the component to add.
.P ComponentType
Type of the component to add.
.P ...
Other arguments needed to create the component.
.R Returns a new instance of the component.
]]--
function DialogManager:AddComponent(ComponentName, ComponentType, ...)
  if ComponentType == type(self) then
    return nil
  end
  if not self.Components then
    self.Components = {}
  end
  local component = self.GameEngine.AddComponent(ComponentName, ComponentType, ...)
  table.insert(self.Components, component)
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
  local newDialog = require(File)
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
  SortTableByZOrder(self.Components)
end

--[[
proto DialogManager:Draw()
.D This function draw the dialog at the right place with the dev's options and applyed the limit and border.
]]
function DialogManager:Draw()
  if self.currentdialog and self.currentdialog.start then
    for key, component in pairs(self.Components) do
      if component.Draw then
        component:Draw(self.limit - self.border*2)
      end
    end
  end
end

--[[
proto DialogManager:GetName()
.D This function returns the name of the dialog manager.
.R returns the name of the dialog manager.
]]--
function DialogManager:GetName()
  return self.name
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
        self.backgroundImageComponent = self:AddComponent("BackgroundImage", "Image", self.currentdialog.image)
        self.backgroundImageComponent:SetZOrder(-10)
        self.backgroundImageComponent:SetScaleFromLimit(self.GameEngine.ScreenWidth, self.GameEngine.ScreenHeight)
      end
      if self.currentdialog.sound then
        self.backgroundSoundComponent = self:AddComponent("BackgroundSound", "Sound", self.currentdialog.sound.file, self.currentdialog.sound.type)
        self.backgroundSoundComponent:Play()
      end
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
  for i=#self.Components, 1, -1 do
    table.remove(self.Components, i)
  end
  self.backgroundImageComponent = nil
  self.backgroundSoundComponent = nil
  self.imageComponent = nil
  self.titleComponent = nil
  self.textComponent = nil
end

--[[
proto DialogManager:RestartComponents()
.D This function resets all components needed to display the dialog.
]]--
function DialogManager:RestartComponents()
  local Dialog = self.currentdialog[self.numDialog]
  -- Background image
  if self.backgroundImageComponent then
    self.backgroundImageComponent:SetNewImage(self.currentdialog.image)
    self.backgroundImageComponent:SetScaleFromLimit(self.GameEngine.ScreenWidth, self.GameEngine.ScreenHeight)
  elseif self.currentdialog.image then
    self.backgroundImageComponent = self:AddComponent("BackgroundImage", "Image", self.currentdialog.image)
    self.backgroundImageComponent:SetZOrder(-10)
    self.backgroundImageComponent:SetScaleFromLimit(self.GameEngine.ScreenWidth, self.GameEngine.ScreenHeight)
  end
  -- Background sound
  if self.backgroundSoundComponent then
    self.backgroundSoundComponent:SetNewSound(self.currentdialog.sound.file, self.currentdialog.sound.type)
    self.backgroundSoundComponent:Play()
  elseif self.currentdialog.sound then
    self.backgroundSoundComponent = self:AddComponent("BackgroundSound", "Sound", self.currentdialog.sound.file, self.currentdialog.sound.type)
    self.backgroundSoundComponent:Play()
  end
  -- Front image
  if self.imageComponent then
    if Dialog.image then
      self.imageComponent:SetNewImage(Dialog.image)
    else
      self:RemoveComponent(self.imageComponent)
      self.imageComponent = nil
    end
  elseif Dialog.image then
    self.imageComponent = self:AddComponent("Image", "Image", Dialog.image)
  end
  -- Title
  if self.titleComponent then
    if Dialog.title then
      if not Dialog.title.text then Dialog.title.text = "" end
      self.titleComponent:SetContent(Dialog.title.text)
      if Dialog.title.font then
        self.titleComponent:SetFont(Dialog.title.font.name,Dialog.title.font.size)
      end
      if Dialog.title.align then
        self.titleComponent:SetAlignment(Dialog.title.align)
      end
    else
      self:RemoveComponent(self.titleComponent)
      self.titleComponent = nil
    end
  elseif Dialog.title.text then
    self.titleComponent = self:AddComponent("Title","Text",Dialog.title.text,Dialog.title.font.name,Dialog.title.font.size)
    self.titleComponent:SetAlignment(Dialog.title.align)
  end
  -- Text
  if self.textComponent then
    self.textComponent:SetContent("")
    self.textComponent:SetFont(Dialog.font.name,Dialog.font.size)
  elseif Dialog.text then
    self.textComponent = self:AddComponent("Text","Text","",Dialog.font.name,Dialog.font.size)
  end

  if self.soundComponent then
    self.soundComponent:Stop()
    if Dialog.sound then
      self.soundComponent:SetNewSound(Dialog.sound.file)
      self.soundComponent:Play()
    else
      self:RemoveComponent(self.soundComponent)
      self.soundComponent = nil
    end
  elseif Dialog.sound then
    self.soundComponent = self:AddComponent("Sound", "Sound", Dialog.sound.file, Dialog.sound.type)
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

--[[
proto DialogManager:SetComponents(Dialog)
.D This function creates all components needed to the dialog and start the thread.
]]--
function DialogManager:SetComponents(Dialog)
  if Dialog.sound then
    self.soundComponent = self:AddComponent("Sound", "Sound", Dialog.sound.file, Dialog.sound.type)
    self.soundComponent:Play()
  end
  if Dialog.image then
    self.imageComponent = self:AddComponent("Image", "Image", Dialog.image)
  end
  if Dialog.title then
    self.titleComponent = self:AddComponent("Title","Text",Dialog.title.text,Dialog.title.font.name,Dialog.title.font.size)
    self.titleComponent:SetAlignment(Dialog.title.align)
  end
  self.textComponent = self:AddComponent("Text","Text",{FontName=Dialog.font.name,FontSize=Dialog.font.size,Content=""})
  self:SetDialogPosition(Dialog)
  self.thread:start(Dialog.text)
end

--[[
proto DialogManager:SetDialogPosition(Dialog)
.D This function update the position and alignment of all dialog components using the datas from the given dialog.
.P Dialog
Table containing all datas of the current dialog.
]]--
function DialogManager:SetDialogPosition(Dialog)
  if Dialog.position then
    -- calcul de toutes les positions des composants
    local x = Dialog.position.x + self.border
    local y = Dialog.position.y
    if self.textComponent then
      self.textComponent:SetPosition(x, y)
    end
    if self.titleComponent then
      y = y - self.titleComponent:GetHeight()
      self.titleComponent:SetPosition(x, y)
    end
    if self.imageComponent then
      local ix = x
      local iy = y
      local ox = 0
      local oy = self.imageComponent:GetHeight()
      if self.titleComponent then
        if Dialog.title.align then
          if Dialog.title.align == "center" then
            ix = (x + self.limit - self.border)/2
            ox = self.imageComponent:GetWidth() / 2
          elseif Dialog.title.align == "right" then
            ix = self.limit - self.border
            ox = self.imageComponent:GetWidth()
          end
        end
      end
      self.imageComponent:SetPosition(ix, iy)
      self.imageComponent:SetOrigin(ox, oy)
    end
  end
end

--[[
proto DialogManager:Update(dt)
.D This function update the dialog text and increase the speed for displaying the text if the ActionKey is pressed.
.P dt
Delta-time
]]
function DialogManager:Update(dt)
  if self.currentdialog and self.currentdialog.start then
    if love.keyboard.isDown(self.key) then
      local running = self.thread:isRunning()
      if running then
        self.keypressed = true
        self.channel.speed:push(true)
        self:RetreiveDisplayText()
        return
      end -- running
      if self.keypressed then
        self:RetreiveDisplayText()
        return
      end -- self.keypressed
      self.numDialog = self.numDialog + 1
      if self.numDialog > self.length then
        self.currentdialog.start = false
        self:ResetComponents()
        self.start = false
      else
        local text = self.currentdialog[self.numDialog].text
        self.thread:start(text)
        self:RestartComponents()
        return
      end
    end -- love.keyboard.isDown(self.key)
    if self.keypressed then
      self.keypressed = false
    end
    -- Récupération du texte à afficher
    self:RetreiveDisplayText()
  end -- self.start
end -- Update(dt)


DialogManager.__call = function() return DialogManager.New() end
DialogManager.__index = DialogManager
DialogManager.__tostring = function() return "DialogManager" end
return DialogManager