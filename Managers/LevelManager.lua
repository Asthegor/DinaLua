local LevelManager = {
  _TITLE       = 'Dina GE Level Manager',
  _VERSION     = '2.0.3',
  _URL         = 'https://dina.lacombedominique.com/documentation/managers/levelmanager/',
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
  local image = love.graphics.newImage(path)
  table.insert(self.images, image)
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
      if object.gid then
        object.y = object.y - object.height
      end
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
    local image = love.graphics.newImage(path)
    table.insert(self.images, image)
    Layer.numImg = #self.images
    table.insert(self.layers, Layer)

  elseif Layer.type == "tilelayer" then
    table.insert(self.layers, Layer)

  elseif Layer.type == "objectgroup" then
    self:loadObjects(Layer)
  end
end
function LevelManager:Load(File)
  self.file = require(File)
  local fname = File:gsub("^(.*/+)", "")
  if File == fname then
    self.path = ""
  else
    self.path = File:gsub('%/'..fname..'$', '') .. "/"
  end

  for i = 1, #self.file.tilesets do
    local tileset = self.file.tilesets[i]
    self:loadTileset(tileset)
  end

  for i = 1, #self.file.layers do
    local layer = self.file.layers[i]
    self:loadLayer(layer)
  end
  local canvasWidth = self.file.width * self.file.tilewidth
  local canvasHeight = self.file.height * self.file.tileheight
  self.canvas = love.graphics.newCanvas(canvasWidth, canvasHeight)
end
--*************************************************************
--* Drawings
--*************************************************************
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
        local numTile, r, sx, sy = LevelManager:getRotation(data)
        local numimg = self.squads[numTile].numimg
        local image = self.images[numimg]
        local quad = self.squads[numTile].obj
        local qw = self.squads[numTile].width
        local qh = self.squads[numTile].height
        local diffh = qh - th
        local ox, oy, offset = 0, 0, 0
        x = (col-1) * tw * ScaleX
        y = (row-1) * th * ScaleY
        if r > 0 then
          -- rotation 90° vers la droite
          ox = ox + qw - tw
          oy = oy + qh
        elseif r < 0 then
          -- rotation de 270° vers la droite
          ox = ox + tw
        elseif sx < 0 and sy < 0 then
--          rotation de 180° vers la droite
          ox = ox + qw
          oy = oy + th
        else
          -- aucune modification
          offset = math.abs(diffh) > 0 and diffh or 0
          oy = oy + offset
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

  -- Traitement de la rotation
  --      S'inspirer de drawObjectTile ?

  love.graphics.setColor(1,1,1,Layer.opacity)
  local image = self.images[Layer.numImg]
  love.graphics.draw(image, x, y, 0, ScaleX, ScaleY)
  love.graphics.setColor(1,1,1,1)
end
function LevelManager:drawObjectTile(Object, OffsetX, OffsetY, Alpha, ScaleX, ScaleY)
  local numTile, r, sx, sy = LevelManager:getRotation(Object.gid)
  if numTile > 0 then
    local _, _, tw, th = self:getDimensions()
    local x = (Object.x - OffsetX) * ScaleX
    local y = (Object.y - OffsetY) * ScaleY
    local numimg = self.squads[numTile].numimg
    local image = self.images[numimg]
    local ow = Object.width
    local ox, oy = 0, 0
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

    local quad = self.squads[numTile].obj
    love.graphics.setColor(1,1,1,Alpha)
    love.graphics.draw(image, quad, x, y, r, sx * ScaleX, sy * ScaleY, ox, oy)
    love.graphics.setColor(1,1,1,1)
  end
end
function LevelManager:drawObjectForm(Object, OffsetX, OffsetY, Alpha, ScaleX, ScaleY)

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
--
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
      local object = self.objects[i]
      self:drawObject(object, 0, 0, ScaleX, ScaleY)
    end
    love.graphics.setCanvas()
  end
  love.graphics.draw(self.canvas, OffsetX * -1, OffsetY * -1)
  self.updatecanvas = false
end

--*************************************************************
--* Opacity
--*************************************************************
function LevelManager:getLayerOpacity(Layer)
  return Layer.opacity or 0
end
function LevelManager:setLayerOpacity(Layer, Alpha)
  if Layer ~= nil then
    if Layer.originalOpacity == nil then
      if Layer.originalOpacity ~= Layer.opacity then
        self.updatecanvas = true
      end
      Layer.originalOpacity = Layer.opacity
    end
    Layer.opacity = Alpha
    if Layer.opacity > 1 then
      Layer.opacity = 1
    elseif Layer.opacity < 0 then
      Layer.opacity = 0
    end
  end
end
function LevelManager:adjustLayerOpacity(Layer, Adjust)
  if Layer ~= nil then
    if Layer.originalOpacity == nil then
      if Layer.originalOpacity ~= Layer.opacity then
        self.updatecanvas = true
      end
      Layer.originalOpacity = Layer.opacity
    end
    Layer.opacity = Layer.opacity + Adjust
    if Layer.opacity > 1 then
      Layer.opacity = 1
    elseif Layer.opacity < 0 then
      Layer.opacity = 0
    end
  end
end
function LevelManager:restoreLayerOpacity(Layer)
  if Layer ~= nil then
    if Layer.originalOpacity ~= nil then
      self.updatecanvas = true
      Layer.opacity = Layer.originalOpacity
    end
  end
end

function LevelManager:getObjectOpacity(Object)
  return Object.opacity or 0
end
function LevelManager:setObjectOpacity(Object, Alpha)
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
function LevelManager:adjustObjectOpacity(Object, Adjust)
  if Object ~= nil then
    if Object.originalOpacity == nil then
      if Object.originalOpacity ~= Object.opacity then
        self.updatecanvas = true
      end
      Object.originalOpacity = Object.opacity
    end
    Object.opacity = Object.opacity + Adjust
    if Object.opacity > 1 then
      Object.opacity = 1
    elseif Object.opacity < 0 then
      Object.opacity = 0
    end
  end
end
function LevelManager:restoreObjectOpacity(Object)
  if Object.originalOpacity ~= nil then
    self.updatecanvas = true
    Object.opacity = Object.originalOpacity
  end
end
function LevelManager:setOpacity(Alpha)
  for _,v in ipairs(self.layers) do
    self:setLayerOpacity(v, Alpha)
  end
  for _,v in ipairs(self.objects) do
    self:setObjectOpacity(v, Alpha)
  end
end
function LevelManager:restoreOpacity()
  for _,v in ipairs(self.layers) do
    self:restoreLayerOpacity(v)
  end
  for _,v in ipairs(self.objects) do
    self:restoreObjectOpacity(v)
  end
end
--*************************************************************
--* Retreivings
--*************************************************************
function LevelManager:getLayerByName(Name)
  for i = 1, #self.layers do
    local layer = self.layers[i]
    if layer.name == Name then
      return layer
    end
  end
  return nil
end
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
function LevelManager:getObjectByName(Name)
  for i = 1, #self.objects do
    local object = self.objects[i]
    if object.name == Name then
      return object
    end
  end
  return nil
end
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
function LevelManager:getAllObjectsByType(Type)
  return self:getAllObjectsBy("type", Type)
end
function LevelManager:getAllObjectsByShape(Shape)
  return self:getAllObjectsBy("shape", Shape)
end
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
function LevelManager:getDimensions()
  return self.file.width, self.file.height, self.file.tilewidth, self.file.tileheight
end

--*************************************************************
--* Utils
--*************************************************************
function LevelManager:getLayerTileIdAtPos(Layer, Row, Col)
  local mw, _ = self:getDimensions()
  local id = Layer.data[(Row-1) * mw + Col]
  return id or 0
end
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
function LevelManager:restoreLayerDatas(Layer)
  if Layer.originalData == nil then
    return
  end
  for k,v in pairs(Layer.originalData) do
    Layer.data[k] = v
  end
end
function LevelManager:changeLayerTileIdAtPos(Layer, Row, Col, ImgId, Force)
  if Force or self:isValidImgId(ImgId) then
    local posTile = (Row - 1) * Layer.width + Col
    if Layer.originalData == nil then
      self:backupLayerDatas(Layer)
    end
    Layer.data[posTile] = ImgId
    self.updatecanvas = true
  end
end
function LevelManager:restoreLayerTileIdAtPos(Layer, Row, Col)
  local posTile = (Row - 1) * Layer.width + Col
  Layer.data[posTile] = Layer.originalData[posTile]
  self.updatecanvas = true
end
function LevelManager:changeObjectImageId(Object, ImgId)
  if self:isValidImgId(ImgId) then
    Object.gid = ImgId
    self.updatecanvas = true
  end
end
function LevelManager:restoreObjectImageId(Object)
  if Object.originalGid ~= nil then
    Object.gid = Object.originalGid
    self.updatecanvas = true
  end
end

function LevelManager:isDrawable(Item)
  return Item.visible == true and Item.opacity > 0
end
function LevelManager:isValidImgId(ImgId)
  return self.tileids[ImgId] and true or false
end
function LevelManager:getRotation(pNum)
  local FLIPH = 0x80000000
  local FLIPV = 0x40000000
  local FLIPD = 0x20000000
  local numTile = pNum
  local r, sx, sy = 0, 1, 1
  local flipX, flipY, flipD = false, false, false
  -- Code provenant de STI
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
  -- Fin Code provenant de STI
  return numTile, r, sx, sy
end
--
function LevelManager:ConvertRowColToCoord(Row, Col)
  local mw, mh, tw, th = self:getDimensions()
  if Row < 0 or Row > mh or Col < 0 and Col > mw then
    return nil, nil
  end
  local x = (Col - 1) * tw
  local y = (Row - 1) * th
  return x, y
end
--
function LevelManager:ConvertCoordAndSizeToRowCol(X, Y)
  local mw, mh, tw, th = self:getDimensions()
  if X < 0 or X > mw * tw or Y < 0 or Y > mh * th then
    return nil, nil
  end
  local col = math.floor(X / tw) + 1
  local row = math.floor(Y / th)
  return row, col
end
--
function LevelManager:reload()
  for _,layer in ipairs(self.layers) do
    self:restoreLayerOpacity(layer)
    self:restoreLayerDatas(layer)
  end
  self:resetObjects()
  self.updatecanvas = true
end

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
LevelManager.__tostring = function(NoTitle) return LevelManager:ToString(NoTitle) end
LevelManager.__index = LevelManager
return LevelManager