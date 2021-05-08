local Vector = {
  _TITLE       = 'Dina Game Engine - Vector',
  _VERSION     = '3.0.1',
  _URL         = 'https://dina.lacombedominique.com/documentation/core/vector/',
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

-- TODO: work in progress; the file could be deleted


function Vector.new(X, Y)
  assert(X ~= nil and Y ~= nil, "ERROR: the parameters X and Y must be filled.")
  local self = {}
  local id = string.gsub(tostring(self), "table: ", "")
  setmetatable(self, Vector)
  self.id = id
  self.x = X
  self.y = Y
  return self
end

local function ToString(self)
  return "[" .. tostring(self.x) .. ", " .. tostring(self.y) .. "]"
end

local function AddVector(A, B)
  if IsNumber(A.x) and IsNumber(A.y) and IsNumber(B.x) and IsNumber(B.y) then
    return Vector.new(A.x + B.x, A.y + B.y)
  end
  return nil
end
local function DivVector(A, B)
  if IsNumber(A) then
    if IsNumber(A.x) and IsNumber(A.y) then
      return Vector.new(B.x / A, B.y / A)
    end
  elseif IsNumber(B) then
    if IsNumber(B.x) and IsNumber(B.y) then
      return Vector.new(A.x / B, A.y / B)
    end
  end
  return nil
end
local function EqVector(A, B)
  if IsNumber(A.x) and IsNumber(A.y) and IsNumber(B.x) and IsNumber(B.y) then
    return A.x == B.x and A.y == B.y
  end
  return nil
end
local function MulVector(A, B)
  if IsNumber(A) then
    if IsNumber(B.x) and IsNumber(B.y) then
      return Vector.new(A * B.x, A * B.y)
    end
  elseif IsNumber(B) then
    if IsNumber(A.x) and IsNumber(A.y) then
      return Vector.new(A.x * B, A.y * B)
    end
  end
  return nil
end
local function SubVector(A, B)
  if IsNumber(A.x) and IsNumber(A.y) and IsNumber(B.x) and IsNumber(B.y) then
    return Vector.new(A.x - B.x, A.y - B.y)
  end
  return nil
end


Vector.__tostring = function(self) return ToString(self) end
Vector.__add = function(A, B) return AddVector(A, B) end
Vector.__div = function(A, B) return DivVector(A, B) end
Vector.__eq = function(A, B) return EqVector(A, B) end
Vector.__le = nil
Vector.__lt = nil
Vector.__mul = function(A, B) return MulVector(A, B) end
Vector.__sub = function(A, B) return SubVector(A, B) end

return Vector