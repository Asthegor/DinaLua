local LevelManager = {
  _TITLE       = 'Dina GE Level Manager',
  _VERSION     = '2.0.4',
  _URL         = 'https://dina.lacombedominique.com/documentation/managers/levelmanager/',
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

function LevelManager.New()
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
  return self
end

--*************************************************************
--* Loadings
--*************************************************************
function LevelManager:loadTileset(Tileset)
  local ttw = Tileset.tilewidth
  local tth = Tileset.tileheight
  local tiw = Tileset.imagewidth
  local tih = Tileset.imageheight
  local tm = Tileset.margin
  local ts = Tileset.spacing
  local path = self.path .. Tileset.image
  while string.find(path, "%.%.") ~= nil do
    path = string.sub(path, string.find(path, "%.%.") + 3)
  end
  table.insert(self.images, love.graphics.newImage(path))
  table.insert(self.tilesets, Tileset)
  for i = 1, Tileset.tilecount do
    self.tileids[Tileset.firstgid + i - 1] = true
  end

  local nbRows = math.ceil((tih - (tm * 2)) / (tth + ts))
  local nbCols = math.ceil((tiw - (tm * 2)) / (ttw + ts))
  local x, y
  for r = 1, nbRows do
    for c = 1, nbCols do
      x = (c - 1) * (ttw + ts) + tm
      y = (r - 1) * (tth + ts) + tm
      local squad = {}
      squad.obj = love.graphics.newQuad(x, y, ttw, tth, tiw, tih)
      squad.width = ttw
      squad.height = tth
      squad.numimg = #self.images
      table.insert(self.squads, squad)
    end
  end
end
function LevelManager:loadObjects(Layer)
  for i = 1, #Layer.objects do
    local object = Layer.objects[i]
    local _,_,tw,th = self:getDimensions()
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
    table.insert(self.objects, object)
  end
end
function LevelManager:loadLayer(Layer)
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
      self:loadLayer(currLayer)
    end

  elseif Layer.type == "imagelayer" then
    local path = self.path..Layer.image
    while string.find(path, "%.%.") ~= nil do
      path = string.sub(path, string.find(path, "%.%.") + 3)
    end
    table.insert(self.images, love.graphics.newImage(path))
    Layer.numImg = #self.images
    table.insert(self.layers, Layer)

  elseif Layer.type == "tilelayer" then
    table.insert(self.layers, Layer)

  elseif Layer.type == "objectgroup" then
    self:loadObjects(Layer)
  end
end
--[[
proto LevelManager:Load(File)
.D This function loads a given map file.
.P File
Path and name of the map to load.
]]--
function LevelManager:Load(File)
  self.file = require(File)
  local fname = File:gsub("^(.*/+)", "")
  if File == fname then
    self.path = ""
  else
    self.path = File:gsub('%/'..fname..'$', '') .. "/"
  end

  for i = 1, #self.file.tilesets do
    self:loadTileset(self.file.tilesets[i])
  end

  for i = 1, #self.file.layers do
    self:loadLayer(self.file.layers[i])
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
function LevelManager:drawLayer(Layer, OffsetX, OffsetY, ScaleX, ScaleY)
  if not self:isDrawable(Layer) then
    return
  end
  local w, h, tw, th = self:getDimensions()
  local offsetX = (Layer.offsetx - OffsetX) * ScaleX
  local offsetY = (Layer.offsety - OffsetY) * ScaleY
  local x = 0
  local y = 0

  love.graphics.setColor(1,1,1,Layer.opacity)
  for row = 1, h do
    for col = 1, w do
      local posTile = (row - 1) * Layer.width + col
      local data = Layer.data[posTile]
      if data ~= nil and data ~= 0 then
        local numTile, r, sx, sy = GetRotation(data)
        local numimg = self.squads[numTile].numimg
        local image = self.images[numimg]
        local quad = self.squads[numTile].obj
        local qw = self.squads[numTile].width
        local qh = self.squads[numTile].height
        local diffh = qh - th
        local ox, oy = 0, 0
        x = (col-1) * tw * ScaleX
        y = (row-1) * th * ScaleY
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
        love.graphics.draw(image, quad, x+offsetX, y+offsetY, r, sx*ScaleX, sy*ScaleY, ox, oy)
      end
    end
  end
  love.graphics.setColor(1,1,1,1)
end
function LevelManager:drawImage(Layer, OffsetX, OffsetY, ScaleX, ScaleY)
  if not self:isDrawable(Layer) then
    return
  end
  local x = (Layer.offsetx - OffsetX) * ScaleX
  local y = (Layer.offsety - OffsetY) * ScaleY

  -- TODO: rotation ?

  love.graphics.setColor(1,1,1,Layer.opacity)
  local image = self.images[Layer.numImg]
  love.graphics.draw(image, x, y, 0, ScaleX, ScaleY)
  love.graphics.setColor(1,1,1,1)
end
function LevelManager:drawObjectTile(Object, OffsetX, OffsetY, Alpha, ScaleX, ScaleY)
  local numTile, r, sx, sy = GetRotation(Object.gid)
  if numTile > 0 then
    local numimg = self.squads[numTile].numimg
    local image = self.images[numimg]
    local quad = self.squads[numTile].obj
    local _, _, tw, th = self:getDimensions()
    local x = (Object.x - OffsetX) * ScaleX
    local y = (Object.y - OffsetY) * ScaleY
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
    love.graphics.draw(image, quad, x, y, r, sx * ScaleX, sy * ScaleY, ox, oy)
    love.graphics.setColor(1,1,1,1)
  end
end
function LevelManager:drawObjectForm(Object, OffsetX, OffsetY, Alpha, ScaleX, ScaleY)
  -- Nothing to draw
end
function LevelManager:drawObject(Object, OffsetX, OffsetY, ScaleX, ScaleY)
  if not self:isDrawable(Object) then
    return
  end
  if Object.gid ~= nil then
    self:drawObjectTile(Object, OffsetX, OffsetY, Object.opacity, ScaleX, ScaleY)
  else
    self:drawObjectForm(Object, OffsetX, OffsetY, Object.opacity, ScaleX, ScaleY)
  end
end
--[[
proto LevelManager:Draw(OffsetX, OffsetY, ScaleX, ScaleY)
.D This function draws the map with a given offset and scale.
.P OffsetX
.P OffsetY
.P ScaleX
.P ScaleY
]]--
function LevelManager:Draw(OffsetX, OffsetY, ScaleX, ScaleY)
  OffsetX = OffsetX or 0
  OffsetY = OffsetY or 0
  if self.oldOffsetX ~= OffsetX then
    self.oldOffsetX = OffsetX
  end
  if self.oldOffsetY ~= OffsetY then
    self.oldOffsetY = OffsetY
  end

  ScaleX = ScaleX or 1
  ScaleY = ScaleY or ScaleX or 1
  if self.oldScaleX ~= ScaleX then
    self.oldScaleX = ScaleX
    self.updatecanvas = true
  end
  if self.oldScaleY ~= ScaleY then
    self.oldScaleY = ScaleY
    self.updatecanvas = true
  end
  if ScaleX ~= 1 and ScaleY ~= 1 then
    local drawWidth = self.file.width * self.file.tilewidth * ScaleX
    local drawHeight = self.file.height * self.file.tileheight * ScaleY
    if drawWidth ~= self.canvas:getWidth() or drawHeight ~= self.canvas:getHeight() then
      self.canvas = love.graphics.newCanvas(drawWidth, drawHeight)
    end
  end
  if self.updatecanvas then
    love.graphics.setCanvas(self.canvas)
    love.graphics.clear()
    -- Affichage des calques de tiles et d'images
    for i = 1, #self.layers do
      local layer = self.layers[i]
      if layer.type == "tilelayer" then
        self:drawLayer(layer, 0, 0, ScaleX, ScaleY)
      elseif layer.type == "imagelayer" then
        self:drawImage(layer, 0, 0, ScaleX, ScaleY)
      end
    end
    -- Affichage des objets
    for i = 1, #self.objects do
      self:drawObject(self.objects[i], 0, 0, ScaleX, ScaleY)
    end
    love.graphics.setCanvas()
  end
  love.graphics.draw(self.canvas, OffsetX * -1, OffsetY * -1)
  self.updatecanvas = false
end

--*************************************************************
--* Opacity
--*************************************************************
--[[
proto LevelManager:getItemOpacity(Item)
.D This function returns the opacity of a given item (layer or object).
.P Item
Item (layer or object) to get the opacity.
.R Returns the opacity of the given item (layer or object).
]]--
function LevelManager:getItemOpacity(Item)
  return Item.opacity or 0
end
--[[
proto LevelManager:setItemOpacity(Item, Alpha)
.D This function set the opacity of the given item (layer or object).
.P Item
Item (layer or object) on which the opacity is modified.
.P Alpha
New value of opacity to apply.
]]--
function LevelManager:setItemOpacity(Item, Alpha)
  if Object ~= nil then
    if Object.originalOpacity == nil then
      if Object.originalOpacity ~= Object.opacity then
        self.updatecanvas = true
      end
      Object.originalOpacity = Object.opacity
    end
    Object.opacity = Alpha
    if Object.opacity > 1 then
      Object.opacity = 1
    elseif Object.opacity < 0 then
      Object.opacity = 0
    end
  end
end
--[[
proto LevelManager:adjustItemOpacity(Item, Adjust)
.D This function adjusts the opacity of a given item (layer or object) by the given adjust value.
.P Item
Item (layer or object) on which opacity is modified.
.P Adjust
Value to add to the item (layer or object) opacity.
]]--
function LevelManager:adjustItemOpacity(Item, Adjust)
  if Item ~= nil then
    if Item.originalOpacity == nil then
      if Item.originalOpacity ~= Item.opacity then
        self.updatecanvas = true
      end
      Item.originalOpacity = Item.opacity
    end
    Item.opacity = Item.opacity + Adjust
    if Item.opacity > 1 then
      Item.opacity = 1
    elseif Item.opacity < 0 then
      Item.opacity = 0
    end
  end
end
--[[
proto LevelManager:restoreItemOpacity(Item)
.D This function restores the opacity of the given item (layer or object).
.P Item
Item (layer or object) on which opacity is restored.
]]--
function LevelManager:restoreItemOpacity(Item)
  if Item.originalOpacity ~= nil then
    self.updatecanvas = true
    Item.opacity = Item.originalOpacity
  end
end
--[[
proto LevelManager:setOpacity(Opacity)
.D This function sets the opacity of all layers and objects to the given value.
.P Opacity
New value of opacity.
]]--
function LevelManager:setOpacity(Opacity)
  for _,v in ipairs(self.layers) do
    self:setItemOpacity(v, Opacity)
  end
  for _,v in ipairs(self.objects) do
    self:setItemOpacity(v, Opacity)
  end
end
--[[
proto LevelManager:restoreOpacity()
.D This function restores the opacity of all layers and objects.
]]--
function LevelManager:restoreOpacity()
  for _,v in ipairs(self.layers) do
    self:restoreItemOpacity(v)
  end
  for _,v in ipairs(self.objects) do
    self:restoreItemOpacity(v)
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
--[[
proto LevelManager:getAllObjectsBy(Type, Value)
.D This function retreives an object according to the given type and value. If no object corresponds to the given type and value, nothing is returned.
.P Type
Type of the object. Can be "type" or "shape".
.P Value
Value of the given type.
.R Returns all objects matching the given type and value.
]]--
function LevelManager:getAllObjectsBy(Type, Value)
  local objects = {}
  for i = 1, #self.objects do
    local object = self.objects[i]
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
  return self:getAllObjectsBy("type", Type)
end
--[[
proto LevelManager:getAllObjectsByShape(Shape)
.D This function is a shortcu to retreive all objects of the given shape.
.P Shape
Shape of object to retreive.
.R Returns all objects of the given shape.
]]--
function LevelManager:getAllObjectsByShape(Shape)
  return self:getAllObjectsBy("shape", Shape)
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
proto LevelManager:getLayerTileIdAtPos(Layer, Row, Col)
.D This function returns the tile id at the given coordonate in the given layer.
.P Layer
Layer to retreive the id.
.P Row
Row of the cell.
.P Col
Col of the cell.
.R Returns the tile id at the given coordonate in the given layer.
]]--
function LevelManager:getLayerTileIdAtPos(Layer, Row, Col)
  local mw, _ = self:getDimensions()
  local id = Layer.data[(Row-1) * mw + Col]
  return id or 0
end
--[[
proto LevelManager:backupLayerDatas(Layer)
.D This function creates a backup of all datas for the given layer.
.P Layer
Layer to backup.
]]--
function LevelManager:backupLayerDatas(Layer)
  if type(Layer.data) ~= "table" then
    return
  end
  Layer.originalData = {}
  setmetatable(Layer.originalData, getmetatable(Layer.data))
  for k,v in pairs(Layer.data) do
    Layer.originalData[k] = v
  end
end
--[[
proto LevelManager:restoreLayerDatas(Layer)
.D This function restores all datas from the backup.
.P Layer
Layer to restore.
]]--
function LevelManager:restoreLayerDatas(Layer)
  if Layer.originalData == nil then
    return
  end
  for k,v in pairs(Layer.originalData) do
    Layer.data[k] = v
  end
end
--[[
proto LevelManager:changeLayerTileIdAtPos(Layer, Row, Col, ImgId, Force)
.D This function change the tile id at the given cell coordonate on the given layer by the given id. Must be forced if the new id is 0.
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
function LevelManager:changeLayerTileIdAtPos(Layer, Row, Col, ImgId, Force)
  if Force or self:isValidImgId(ImgId) then
    local posTile = (Row - 1) * Layer.width + Col
    if Layer.originalData == nil then
      self:backupLayerDatas(Layer)
    end
    if Force or self:isValidImgId(ImgId) then
      Layer.data[posTile] = ImgId
    end
    self.updatecanvas = true
  end
end
--[[
proto LevelManager:restoreLayerTileIdAtPos(Layer, Row, Col)
.D This function restores the tile id at the given cell coordonate on the given layer.
.P Layer
Layer to restore.
.P Row
Row of the cell.
.P Col
Col of the cell.
]]--
function LevelManager:restoreLayerTileIdAtPos(Layer, Row, Col)
  local posTile = (Row - 1) * Layer.width + Col
  Layer.data[posTile] = Layer.originalData[posTile]
  self.updatecanvas = true
end
--[[
proto LevelManager:changeObjectImageId(Object, ImgId)
.D This function change the image id of the given object by the given image id if the image id is valid.
.P Object
Object to change the image.
.P ImgId
New image id for the object.
]]--
function LevelManager:changeObjectImageId(Object, ImgId)
  if self:isValidImgId(ImgId) then
    Object.gid = ImgId
    self.updatecanvas = true
  end
end
--[[
proto LevelManager:restoreObjectImageId(Object)
.D This function restores the image id of the given object.
.P Object
Object to restore.
]]--
function LevelManager:restoreObjectImageId(Object)
  if Object.originalGid ~= nil then
    Object.gid = Object.originalGid
    self.updatecanvas = true
  end
end

--[[
proto LevelManager:isDrawable(Item)
.D This function checks if the item is visible and its opacity is greater than 0.
.P Item
Item (layer or object) to check.
.R Returns true if the item is visible and its opacity is greater than 0; false, otherwise.
]]--
function LevelManager:isDrawable(Item)
  return Item.visible == true and Item.opacity > 0
end
--[[
proto LevelManager:isValidImgId(ImgId)
.D This function checks if the given id is existing in the tile id list.
.P ImgId
Id to control.
.R Returns true if the give id if presents in the tile id list; false, otherwise.
]]--
function LevelManager:isValidImgId(ImgId)
  return self.tileids[ImgId] and true or false
end
--[[
proto LevelManager:ConvertRowColToCoord(Row, Col)
.D This function converts the given cel coordonate to X,Y coordonate.
.P Row
Row of the cell.
.P Col
Column of the cell.
.R Returns the X,Y coordonate from the cell coordonate.
]]--
function LevelManager:ConvertRowColToCoord(Row, Col)
  local mw, mh, tw, th = self:getDimensions()
  if Row < 0 or Row > mh or Col < 0 and Col > mw then
    return nil, nil
  end
  local x = (Col - 1) * tw
  local y = (Row - 1) * th
  return x, y
end
--[[
proto LevelManager:ConvertCoordAndSizeToRowCol(X, Y)
.D This function converts a X,Y coordonate to cell coordonate.
.P X
Position on the X-axis.
.P Y
Position on the Y-axis.
.R Returns the row and column of the cell at the given X,Y coordonate.
]]--
function LevelManager:ConvertCoordAndSizeToRowCol(X, Y)
  local mw, mh, tw, th = self:getDimensions()
  if X < 0 or X > mw * tw or Y < 0 or Y > mh * th then
    return nil, nil
  end
  local col = math.floor(X / tw) + 1
  local row = math.floor(Y / th)
  return row, col
end
--[[
proto LevelManager:reload()
.D This function reloads all datas of all layers and objects.
]]--
function LevelManager:reload()
  for _,layer in ipairs(self.layers) do
    self:restoreLayerOpacity(layer)
    self:restoreLayerDatas(layer)
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
    self:restoreObjectOpacity(object)
  end
end

--[[
proto LevelManager:ToString(NoTitle)
.D This function display all variables containing in the current LevelManager instance (tables and functions are excluded).
.P NoTitle
Indicates if the title must be displayed (false) or not (true).
]]--
function LevelManager:ToString(NoTitle)
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
LevelManager.__tostring = function(NoTitle) return LevelManager:ToString(NoTitle) end
LevelManager.__index = LevelManager
return LevelManager