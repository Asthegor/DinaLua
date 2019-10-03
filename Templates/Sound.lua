local Sound = {
  _VERSION     = 'Dina GE Sound Template v1.0',
  _DESCRIPTION = 'Sound Template in Dina Game Engine',
  _URL         = 'https://dina.lacombedominique.com/documentation/templates/sound/',
  _LICENSE     = [[
    MIT LICENSE

    Copyright (c) 2019 LACOMBE Dominique

    Permission is hereby granted, free of charge, to any person obtaining a
    copy of this software and associated documentation files (the
    "Software"), to deal in the Software without restriction, including
    without limitation the rights to use, copy, modify, merge, publish,
    distribute, sublicense, and/or sell copies of the Software, and to
    permit persons to whom the Software is furnished to do so, subject to
    the following conditions:
    The above copyright notice and this permission notice shall be included
    in all copies or substantial portions of the Software.
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
    OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
    CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
    TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
    SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
  ]]
}
Sound.__index = Sound

-- REQUIRES


--[[
proto const Sound.New(File, Type, NbLoop, Volume)
.D This fonction create a new Sound object.
.P File
Path of the sound file.
.P Type
Type of sound; could only be 'stream', 'static' or 'queue' (Löve2D requirements).
.P NbLoop
Number of time the sound could be played. -1 to indicate infinite.
.P Volume
Volume of the sound. Normal sound is 1 (default).
.R Returns an instance of Sound object
]]--
function Sound.New(File, Type, NbLoop, Volume)
  local self = setmetatable({}, Sound)
  if type(File) == "table" then
    if File["File"] then
      local Type = File["Type"]
      if not Type or Type == "" then
        Type = "stream"
      end
      self.source = love.audio.newSource(File["File"], Type)
      self:SetLooping(File["NbLoop"])
      self:SetVolume(SetDefaultNumber(File["Volume"], 1))
      return self
    end
  end
  if File then
    if not Type or Type == "" then
      Type = "stream"
    end
    self.source = love.audio.newSource(File, Type)
    self:SetLooping(NbLoop)
    self:SetVolume(SetDefaultNumber(Volume, 1))
    return self
  end
  return nil
end

--[[
proto Sound:Pause()
.D Pause the current sound.
]]--
function Sound:Play()
  self.source:pause()
end

--[[
proto Sound:Play()
.D Play the current sound at its defined volume only if it is positive.
]]--
function Sound:Play()
  if self.volume then
    self.source:setVolume(self.volume)
    self.source:play()
  end
end

--[[
proto Sound:SetLooping(NbLoop)
.D Define the number of times the sound can be played; none by default.
.P NbLoop
Number of time the sound can be played. -1 for infinite and 0 for none.
]]--
function Sound:SetLooping(NbLoop)
  if type(NbLoop) == 'number' then
    if NbLoop < 0 then NbLoop = -1 end
    self.nbloop = NbLoop
  else
    self.nbloop = 0
  end
end

--[[
proto Sound:SetVolume(Volume)
.D This function sets the sound volume. If negative or not defined, set it to 0.
.P Volume
Volume value.
]]--
function Sound:SetVolume(Volume)
  Volume = SetDefaultNumber(Volume, 0)
  if Volume < 0 then Volume = 0 end
  self.volume = Volume
end

--[[
proto Sound:Stop()
.D This function stops the sound.
]]--
function Sound:Stop()
  self.source:stop()
end

--[[
proto Sound:Update(dt)
.D This function updates the number of loops already done. if nbloop < 0, the sound is always played.
.P dt
Delta time.
]]--
function Sound:Update(dt)
  if not self.source:isPlaying() then
    if self.nbloop < 0 then
      self:Play()
    elseif self.nbloop > 0 then
      self.nbloop = self.nbloop - 1
      self:Play()
    end
  end
end

Sound.__call = function() return Sound.New() end
Sound.__index = Sound
Sound.__tostring = function() return "Sound" end
return Sound