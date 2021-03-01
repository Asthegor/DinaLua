local soc = require('socket')
local channel = {}
channel.text = love.thread.getChannel('NewText')
channel.speed = love.thread.getChannel('Speed')
channel.stop = love.thread.getChannel('Stop')

local Dialog = ...

local function utf8iter(str)
  return str:gfind("([%z\1-\127\194-\244][\128-\191]*)")
end

if Dialog then

  local wait = 0.1
  local text = ""
  for char in utf8iter(Dialog) do
    local stop = channel.stop:pop()
    if stop then
      return
    end
    text = text .. char
    channel.text:push(text)
    local speed = channel.speed:pop()
    local curwait = wait
    if speed then
      curwait = 0.01
    end
    soc.sleep(curwait)
  end
end