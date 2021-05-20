local LevelManager = {
  _TITLE       = 'Dina Level Manager',
  _VERSION     = '2.3',
  _URL         = 'https://dina.lacombedominique.com/documentation/levels/levelmanager/',
  _LICENSE     = [[
Copyright (c) 2019-2021 LACOMBE Dominique
ZLIB Licence
This software is provided 'as-is', without any express or implied warranty. In no event will the authors be held liable for any damages arising from the use of this software.
Permission is granted to anyone to use this software for any purpose, including commercial applications, and to alter it and redistribute it freely, subject to the following restrictions:
    1. The origin of this software must not be misrepresented; you must not claim that you wrote the original software. If you use this software in a product, an acknowledgment in the product documentation would be appreciated but is not required.
    2. Altered source versions must be plainly marked as such, and must not be misrepresented as being the original software.
    3. This notice may not be removed or altered from any source distribution.
]]
}

--[[
proto LevelManager.new(ToDraw)
.D This function create a new instance of LevelManager.
.P ToDraw
Indicate if the loaded level should be visible (true or nil) or not (false)
.R Returns an instance of LevelManager.
]]--
function LevelManager.new(ToDraw)
  local self = setmetatable({}, LevelManager)
  self.file = {}
  self.images = {}
  self.squads = {}
  self.layers = {}
  self.objects = {}
  self.tilesets = {}
  self.tileids = {}
  self.path = ""
  self.updatecanvas = false
  self.canvas = {}
  self:setVisible(true)
  self:setScale()
  self:setOffset()
  if ToDraw == false then
    self:setVisible(false)
  end
  return self
end

--*************************************************************
--* Loadings
--*************************************************************
local function LoadTileset(LevelManager, Tileset)
  local ttw = Tileset.tilewidth
  local tth = Tileset.tileheight
  local tiw = Tileset.imagewidth
  local tih = Tileset.imageheight
  local tm = Tileset.margin
  local ts = Tileset.spacing
  local sid = Tileset.firstgid
  local path = LevelManager.path .. Tileset.image
  while string.find(path, "%.%.") ~= nil do
    path = string.sub(path, string.find(path, "%.%.") + 3)
    local lmp = LevelManager.path
    if string.find(lmp, "/", -1) then
      lmp = string.sub(lmp, 1, #lmp - 1)
    end
    if string.find(lmp, "/") then
      lmp = string.sub(lmp, 1, #lmp - string.find(string.reverse(lmp), "/") + 1)
    end
    LevelManager.path = lmp .. (string.find(lmp, "/", -1) and "" or "/")
  end
  path = LevelManager.path .. path
  table.insert(LevelManager.images, love.graphics.newImage(path))
  table.insert(LevelManager.tilesets, Tileset)
  for i = 1, Tileset.tilecount do
    LevelManager.tileids[Tileset.firstgid + i - 1] = true
  end
  local nbCols = Tileset.columns
  local nbRows = Tileset.tilecount / nbCols
  local x, y, r, c
  for r = 1, nbRows do
    for c = 1, nbCols do
      x = (c - 1) * (ttw + ts) + tm
      y = (r - 1) * (tth + ts) + tm
      if x + ttw <= tiw and y + tth <= tih then
        local squad = {}
        squad.obj = love.graphics.newQuad(x, y, ttw, tth, tiw, tih)
        squad.width = ttw
        squad.height = tth
        squad.numimg = #LevelManager.images
        LevelManager.squads[sid] = squad
        sid = sid + 1
      end
    end
  end
end
local function LoadObjects(LevelManager, Layer)
  for i = 1, #Layer.objects do
    local object = Layer.objects[i]
    local _,_,tw,th = LevelManager:getDimensions()
    if object.originalX == nil then
      object.originalX = object.x
    end
    if object.originalY == nil then
      object.originalY = object.y
    end
    object.col = math.floor(object.x / tw) + 1
    if object.originalCol == nil then
      object.originalCol = object.col
    end
    object.row = math.floor(object.y / th) + 1
    if object.originalRow == nil then
      object.originalRow = object.row
    end
    object.offsetx = Layer.offsetx
    object.offsety = Layer.offsety
    object.opacity = Layer.opacity
    object.name = object.name .. (object.name == "" and object.id or "")
    object.path = Layer.path or ""
    if object.originalGid == nil then
      object.originalGid = object.gid
    end
    table.insert(LevelManager.objects, object)
  end
end
local function LoadLayer(LevelManager, Layer)
  if Layer.type == "group" then
    for i = 1, #Layer.layers do
      local currLayer = Layer.layers[i]
      if Layer.path == nil or Layer.path == "" then
        currLayer.path = Layer.name .. "/"
      else
        currLayer.path = Layer.path .. Layer.name .. "/"
      end
      currLayer.opacity = currLayer.opacity * Layer.opacity
      currLayer.offsetx = currLayer.offsetx + Layer.offsetx
      currLayer.offsety = currLayer.offsety + Layer.offsety
      LoadLayer(LevelManager, currLayer)
    end

  elseif Layer.type == "imagelayer" then
    local path = LevelManager.path..Layer.image
    while string.find(path, "%.%.") ~= nil do
      path = string.sub(path, string.find(path, "%.%.") + 3)
    end
    table.insert(LevelManager.images, love.graphics.newImage(path))
    Layer.numImg = #LevelManager.images
    table.insert(LevelManager.layers, Layer)

  elseif Layer.type == "tilelayer" then
    table.insert(LevelManager.layers, Layer)

  elseif Layer.type == "objectgroup" then
    LoadObjects(LevelManager, Layer)
  end
end
--[[
proto LevelManager:load(File)
.D This function loads a given map file.
.P File
Path and name of the map to load.
]]--
function LevelManager:load(File)
  self.file = require(File)
  local fname = File:gsub("^(.*/+)", "")
  if File == fname then
    self.path = ""
  else
    self.path = File:gsub('%/'..fname..'$', '') .. "/"
  end

  for i = 1, #self.file.tilesets do
    LoadTileset(self, self.file.tilesets[i])
  end

  for i = 1, #self.file.layers do
    LoadLayer(self, self.file.layers[i])
  end
  self.canvas = love.graphics.newCanvas(self.file.width * self.file.tilewidth, self.file.height * self.file.tileheight)
end

--*************************************************************
--* Drawings
--*************************************************************
-- Internal function
local function GetRotation(pNum)
  local FLIPH = 0x80000000
  local FLIPV = 0x40000000
  local FLIPD = 0x20000000
  local numTile = pNum
  local r, sx, sy = 0, 1, 1
  local flipX, flipY, flipD = false, false, false
  if numTile > FLIPH then
    numTile = numTile - FLIPH
    flipX = true
  end
  if numTile > FLIPV then
    numTile = numTile - FLIPV
    flipY = true
  end
  if numTile > FLIPD then
    numTile = numTile - FLIPD
    flipD = true
  end
  if flipX then
    if flipY and flipD then
      r  = math.rad(-90)
      sy = -1
    elseif flipY then
      sx = -1
      sy = -1
    elseif flipD then
      r = math.rad(90)
    else
      sx = -1
    end
  elseif flipY then
    if flipD then
      r = math.rad(-90)
    else
      sy = -1
    end
  elseif flipD then
    r  = math.rad(90)
    sy = -1
  end
  return numTile, r, sx, sy
end

local function IsDrawable(Item)
  return Item.visible == true and Item.opacity > 0
end
local function IsValidImgId(LevelManager, ImgId)
  return LevelManager.tileids[ImgId] and true or false
end


local function DrawLayer(LevelManager, Layer)
  if not IsDrawable(Layer) then
    return
  end
  local w, h, tw, th = LevelManager:getDimensions()
  local lmsx, lmsy = LevelManager:getScale()
  local offsetX = Layer.offsetx * lmsx
  local offsetY = Layer.offsety * lmsy
  local x = 0
  local y = 0

  love.graphics.setColor(1,1,1,Layer.opacity)
  for row = 1, h do
    for col = 1, w do
      local posTile = (row - 1) * Layer.width + col
      local data = Layer.data[posTile]
      if data ~= nil and data ~= 0 then
        local numTile, r, sx, sy = GetRotation(data)
        if LevelManager.squads[numTile] == nil then
          for k, v in pairs(LevelManager.squads) do
            print(k, v)
          end
          print("error")
        end
        local numimg = LevelManager.squads[numTile].numimg
        local image = LevelManager.images[numimg]
        local quad = LevelManager.squads[numTile].obj
        local qw = LevelManager.squads[numTile].width
        local qh = LevelManager.squads[numTile].height
        local diffh = qh - th
        local ox, oy = 0, 0
        x = (col-1) * tw * lmsx
        y = (row-1) * th * lmsy
        if r > 0 then
          -- rotation  90° on the right
          ox = ox + qw - tw
          oy = oy + qh
        elseif r < 0 then
          -- rotation 270° on the right
          ox = ox + tw
        elseif sx < 0 and sy < 0 then
          -- rotation 180° on the right
          ox = ox + qw
          oy = oy + th
        else
          -- no rotation
          oy = oy + math.abs(diffh) > 0 and diffh or 0
        end
        love.graphics.draw(image, quad, x+offsetX, y+offsetY, r, sx*lmsx, sy*lmsy, ox, oy)
      end
    end
  end
  love.graphics.setColor(1,1,1,1)
end
local function DrawImage(LevelManager, Layer)
  if not IsDrawable(Layer) then
    return
  end
  local lmsx, lmsy = LevelManager:getScale()
  local x = Layer.offsetx * lmsx
  local y = Layer.offsety * lmsy

  love.graphics.setColor(1,1,1,Layer.opacity)
  local image = LevelManager.images[Layer.numImg]
  love.graphics.draw(image, x, y, 0, lmsx, lmsy)
  love.graphics.setColor(1,1,1,1)
end
local function DrawObjectTile(LevelManager, Object, Alpha)
  local numTile, r, sx, sy = GetRotation(Object.gid)
  if numTile > 0 then
    local numimg = LevelManager.squads[numTile].numimg
    local image = LevelManager.images[numimg]
    local quad = LevelManager.squads[numTile].obj
    local _, _, tw, th = LevelManager:getDimensions()
    local lmsx, lmsy = LevelManager:getScale()
    local x = Object.x * lmsx
    local y = Object.y * lmsy
    local oh = Object.height
    local ow = Object.width
    local ox, oy = 0, oh
    if r > 0 then
      oy = oy + th
      ox = ox + ow - tw
    elseif r < 0 then
      ox = ox + ow - tw
      oy = oy - th
    end
    if sx < 0 then
      ox = ox + ow
    end
    if r == 0 and math.abs(Object.rotation) > 0 then
      local ro = Object.rotation
      if ro >= 180 then
        ro = ro - 360
      end
      oy = Object.height
      r = math.rad(ro)
    end
    love.graphics.setColor(1,1,1,Alpha)
    love.graphics.draw(image, quad, x, y, r, sx * lmsx, sy * lmsy, ox, oy)
    love.graphics.setColor(1,1,1,1)
  end
end
local function DrawObjectForm(LevelManager, Object, Alpha)
  -- Nothing to draw
end
local function DrawObject(LevelManager, Object)
  if not IsDrawable(Object) then
    return
  end
  if Object.gid ~= nil then
    DrawObjectTile(LevelManager, Object, Object.opacity)
  else
    DrawObjectForm(LevelManager, Object, Object.opacity)
  end
end
--[[
proto LevelManager:draw(OffsetX, OffsetY, ScaleX, ScaleY)
.D This function draws the map with a given offset and scale.
.P OffsetX
.P OffsetY
.P ScaleX
.P ScaleY
]]--
function LevelManager:draw()
  if self.visible then
    local lmox, lmoy = self:getOffset()
    local lmsx, lmsy = self:getScale()

    if self.oldScaleX ~= lmsx then
      self.oldScaleX = lmsx
      self.updatecanvas = true
    end
    if self.oldScaleY ~= lmsy then
      self.oldScaleY = lmsy
      self.updatecanvas = true
    end
    if lmsx ~= 1 and lmsy ~= 1 then
      local drawWidth = self.file.width * self.file.tilewidth * lmsx
      local drawHeight = self.file.height * self.file.tileheight * lmsy
      if drawWidth ~= self.canvas:getWidth() or drawHeight ~= self.canvas:getHeight() then
        self.canvas = love.graphics.newCanvas(drawWidth, drawHeight)
        self.updatecanvas = true
      end
    end
    if self.updatecanvas then
      love.graphics.setCanvas(self.canvas)
      love.graphics.clear()
      -- Affichage des calques de tiles et d'images
      for i = 1, #self.layers do
        local layer = self.layers[i]
        if layer.type == "tilelayer" then
          DrawLayer(self, layer)
        elseif layer.type == "imagelayer" then
          DrawImage(self, layer)
        end
      end
      -- Affichage des objets
      for i = 1, #self.objects do
        DrawObject(self, self.objects[i])
      end
      love.graphics.setCanvas()
    end
    love.graphics.draw(self.canvas, lmox * -1, lmoy * -1)
    self.updatecanvas = false
  end
end

--*************************************************************
--* Opacity
--*************************************************************
--[[
proto LevelManager:getOpacity(Item)
.D This function returns the opacity of a given item (layer or object).
.P Item
Item (layer or object) to get the opacity.
.R Returns the opacity of the given item (layer or object).
]]--
function LevelManager:getOpacity(Item)
  return Item.opacity or 0
end
--[[
proto LevelManager:setOpacity(Item, Alpha)
.D This function set the opacity of the given item (layer or object).
.P Item
Item (layer or object) on which the opacity is modified.
.P Alpha
New value of opacity to apply.
]]--
function LevelManager:setOpacity(Item, Alpha)
  if Item ~= nil then
    if Item.originalOpacity == nil then
      if Item.originalOpacity ~= Item.opacity then
        self.updatecanvas = true
      end
      Item.originalOpacity = Item.opacity
    end
    Item.opacity = Alpha
    if Item.opacity > 1 then
      Item.opacity = 1
    elseif Item.opacity < 0 then
      Item.opacity = 0
    end
  end
end
--[[
proto LevelManager:restoreOpacity(Item)
.D This function restores the opacity of the given item (layer or object).
.P Item
Item (layer or object) on which opacity is restored.
]]--
function LevelManager:restoreOpacity(Item)
  if Item.originalOpacity ~= nil then
    self.updatecanvas = true
    Item.opacity = Item.originalOpacity
  end
end
--[[
proto LevelManager:setAllOpacity(Opacity)
.D This function sets the opacity of all layers and objects to the given value.
.P Opacity
New value of opacity.
]]--
function LevelManager:setAllOpacity(Opacity)
  for _,v in ipairs(self.layers) do
    self:setOpacity(v, Opacity)
  end
  for _,v in ipairs(self.objects) do
    self:setOpacity(v, Opacity)
  end
end
--[[
proto LevelManager:restoreAllOpacity()
.D This function restores the opacity of all layers and objects.
]]--
function LevelManager:restoreAllOpacity()
  for _,v in ipairs(self.layers) do
    self:restoreOpacity(v)
  end
  for _,v in ipairs(self.objects) do
    self:restoreOpacity(v)
  end
end
--*************************************************************
--* Retreivings
--*************************************************************
--[[
proto LevelManager:getLayerByName(Name)
.D This function returns a layer found by its name. Do not work with a name of a group.
.P Name
Name of the layer.
.R Returns a layer found by its name; nil otherwise. Do not work with a name of a group.
]]--
function LevelManager:getLayerByName(Name)
  for i = 1, #self.layers do
    local layer = self.layers[i]
    if layer.name == Name then
      return layer
    end
  end
  return nil
end
--[[
proto LevelManager:getLayersByGroup(GroupName)
.D This function returns all layers of a group found by its name.
.P Name
Name of a group.
.R Returns all layers of a group found by its name.
]]--
function LevelManager:getLayersByGroup(GroupName)
  local layerGroup = {}
  for i = 1, #self.layers do
    local layer = self.layers[i]
    if string.find(layer.path, GroupName .. "/") ~= nil then
      table.insert(layerGroup, layer)
    end
  end
  return layerGroup
end
--[[
proto LevelManager:getObjectByName(Name)
.D This function returns an object found by its name.
.P Name
Name of the object to find.
.R Returns an object found by its name; nil otherwise.
]]--
function LevelManager:getObjectByName(Name)
  for i = 1, #self.objects do
    local object = self.objects[i]
    if object.name == Name then
      return object
    end
  end
  return nil
end

local function GetAllObjectsBy(LevelManager, Type, Value)
  local objects = {}
  for i = 1, #LevelManager.objects do
    local object = LevelManager.objects[i]
    if object[Type] == Value then
      table.insert(objects, object)
    end
  end
  return objects
end
--[[
proto LevelManager:getAllObjectsByType(Type)
.D This function is a shortcut to retreive all objects of the given type.
.P Type
Type of object to retreive.
.R Returns all objects of the given type.
]]--
function LevelManager:getAllObjectsByType(Type)
  return GetAllObjectsBy(self, "type", Type)
end
--[[
proto LevelManager:getAllObjectsByShape(Shape)
.D This function is a shortcu to retreive all objects of the given shape.
.P Shape
Shape of object to retreive.
.R Returns all objects of the given shape.
]]--
function LevelManager:getAllObjectsByShape(Shape)
  return GetAllObjectsBy(self, "shape", Shape)
end
--[[
proto LevelManager:getObjectsInGroup(GroupName)
.D This function returns all objects of a group retreived by the given name.
.P GroupName
Name of the group.
.R Returns all objects of a group retreived by the given name.
]]--
function LevelManager:getObjectsInGroup(GroupName)
  local objects = {}
  for i = 1, #self.objects do
    local object = self.objects[i]
    if string.find(object.path, GroupName .. "/") ~= nil then
      table.insert(objects, object)
    end
  end
  return objects
end
--[[
proto LevelManager:getObjectsOnGrid(Row, Col)
.D This function returns all objects at the given cell coordonates. Row and Col should be inside the grid.
.P Row
Row of the cell.
.P Col
Column of the cell.
.R Returns all objects at the given cell coordonates.
]]--
function LevelManager:getObjectsOnGrid(Row, Col)
  local objects = {}
  for i = 1, #self.objects do
    local object = self.objects[i]
    if object.row == Row and object.col == Col then
      table.insert(objects, object)
    end
  end
  return objects
end

--[[
proto LevelManager:getDimensions()
.D This function returns the number of columns and rows of the grid and the width (in pixels) and height (in pixels) of each cell.
.R Returns the number of columns, the number of rows of the grid, the width (in pixels) and height (in pixels) of each cell.
]]--
function LevelManager:getDimensions()
  return self.file.width, self.file.height, self.file.tilewidth, self.file.tileheight
end

--*************************************************************
--* Utils
--*************************************************************
--[[
proto LevelManager:getTileIdAtPos(Layer, Row, Col)
.D This function returns the tile id at the given coordonate in the given layer.
.P Layer
Layer to retreive the id.
.P Row
Row of the cell.
.P Col
Col of the cell.
.R Returns the tile id at the given coordonate in the given layer.
]]--
function LevelManager:getTileIdAtPos(Layer, Row, Col)
  if Layer ~= nil then
    local mw, _ = self:getDimensions()
    local id = Layer.data[(Row-1) * mw + Col]
    return id or 0
  end
end

local function BackupLayerDatas(Layer)
  if type(Layer.data) ~= "table" then
    return
  end
  Layer.originalData = {}
  setmetatable(Layer.originalData, getmetatable(Layer.data))
  for k,v in pairs(Layer.data) do
    Layer.originalData[k] = v
  end
end
local function RestoreLayerDatas(Layer)
  if Layer.originalData == nil then
    return
  end
  for k,v in pairs(Layer.originalData) do
    Layer.data[k] = v
  end
end

--[[
proto LevelManager:setTileIdAtPos(Layer, Row, Col, ImgId, Force)
.D This function sets the tile id at the given cell coordonate on the given layer by the given id. Must be forced if the new id is 0.
.P Layer
Layer to modify
.P Row
Row of the cell.
.P Col
Col of the cell.
.P ImgId
Id of the new image inside one of the tilesets.
.P Force
Force the change of the id. Mandatory if the new id is 0.
]]--
function LevelManager:setTileIdAtPos(Layer, Row, Col, ImgId, Force)
  if Force or IsValidImgId(self, ImgId) then
    local posTile = (Row - 1) * Layer.width + Col
    if Layer.originalData == nil then
      BackupLayerDatas(Layer)
    end
    if Force or IsValidImgId(self, ImgId) then
      Layer.data[posTile] = ImgId
    end
    self.updatecanvas = true
  end
end
--[[
proto LevelManager:restoreTileIdAtPos(Layer, Row, Col)
.D This function restores the tile id at the given cell coordonate on the given layer.
.P Layer
Layer to restore.
.P Row
Row of the cell.
.P Col
Col of the cell.
]]--
function LevelManager:restoreTileIdAtPos(Layer, Row, Col)
  local posTile = (Row - 1) * Layer.width + Col
  Layer.data[posTile] = Layer.originalData[posTile]
  self.updatecanvas = true
end
--[[
proto LevelManager:setImageId(Object, ImgId)
.D This function sets the image id of the given object by the given image id if the image id is valid.
.P Object
Object to set the image.
.P ImgId
New image id for the object.
]]--
function LevelManager:setImageId(Item, ImgId)
  if IsValidImgId(self, ImgId) then
    Item.gid = ImgId
    self.updatecanvas = true
  end
end
--[[
proto LevelManager:restoreObjectImageId(Object)
.D This function restores the image id of the given object.
.P Object
Object to restore.
]]--
function LevelManager:restoreImageId(Object)
  if Object.originalGid ~= nil then
    Object.gid = Object.originalGid
    self.updatecanvas = true
  end
end

--[[
proto LevelManager:setOffset(OffsetX, OffsetY)
.D This function set the offsets.
.P OffsetX
OffsetX
.P OffsetY
OffsetY
]]--
function LevelManager:setOffset(OffsetX, OffsetY)
  self.offsetx = OffsetX or 0
  self.offsety = OffsetY or 0
end
--[[
proto LevelManager:getOffset()
.D This function returns the offsets.
.R Returns the offsets.
]]--
function LevelManager:getOffset()
  return self.offsetx, self.offsety
end
--[[
proto LevelManager:setScale(ScaleX, ScaleY)
.D This function sets the scales.
.P ScaleX
ScaleX
.P ScaleY
ScaleY
]]--
function LevelManager:setScale(ScaleX, ScaleY)
  self.scalex = ScaleX or 1
  self.scaley = ScaleY or 1
end
--[[
proto LevelManager:getScale()
.D This function returns the scale.
.R Returns the scale.
]]--
function LevelManager:getScale()
  return self.scalex, self.scaley
end

--[[
proto LevelManager:setVisible(Visible)
.D This function set the level visible (true) or not (false).
]]--
function LevelManager:setVisible(Visible)
  self.visible = Visible == true and true or false
end
--[[
proto LevelManager:getVisible()
.D This function returns if the level is visible (true) or not (false).
.R Returns if the level is visible (true) or not (false).
]]--
function LevelManager:getVisible()
  return self.visible
end

--[[
proto LevelManager:convertRowColToCoord(Row, Col)
.D This function converts the given cell coordonate to X,Y coordonate.
.P Row
Row of the cell.
.P Col
Column of the cell.
.R Returns the X,Y coordonate from the cell coordonate.
]]--
function LevelManager:convertRowColToCoord(Row, Col)
  local mw, mh, tw, th = self:getDimensions()
  if Row < 0 or Row > mh or Col < 0 and Col > mw then
    return nil, nil
  end
  local x = (Col - 1) * tw
  local y = (Row - 1) * th
  return x, y
end
--[[
proto LevelManager:convertCoordToRowCol(X, Y)
.D This function converts a X,Y coordonate to cell coordonate.
.P X
Position on the X-axis.
.P Y
Position on the Y-axis.
.R Returns the row and column of the cell at the given X,Y coordonate.
]]--
function LevelManager:convertCoordToRowCol(X, Y)
  local mw, mh, tw, th = self:getDimensions()
  local col = math.floor(X / tw) + 1
  local row = math.floor(Y / th)
  if X < 0 or X > mw * tw then
    col = nil
  end
  if Y < 0 or Y > mh * th then
    row = nil
  end
  return row, col
end
--[[
proto LevelManager:reload()
.D This function reloads all datas of all layers and objects.
]]--
function LevelManager:reload()
  for _,layer in ipairs(self.layers) do
    self:restoreOpacity(layer)
    RestoreLayerDatas(layer)
  end
  self:resetObjects()
  self.updatecanvas = true
end

--[[
proto LevelManager:resetObjects()
.D This function restore all objects at their original values.
]]--
function LevelManager:resetObjects()
  for i = 1, #self.objects do
    local object = self.objects[i]
    object.x = object.originalX or 0
    object.y = object.originalY or 0
    object.row = object.originalRow or 0
    object.col = object.originalCol or 0
    self:restoreObjectImageId(object)
    self:restoreOpacity(object)
  end
end

--[[
proto LevelManager:toString(NoTitle)
.D This function display all variables containing in the current LevelManager instance (tables and functions are excluded).
.P NoTitle
Indicates if the title must be displayed (false) or not (true).
]]--
function LevelManager:toString(NoTitle)
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
LevelManager.__tostring = function(LevelManager, NoTitle) return LevelManager:toString(NoTitle) end
LevelManager.__index = LevelManager
LevelManager.__name = "LevelManager"

return LevelManager