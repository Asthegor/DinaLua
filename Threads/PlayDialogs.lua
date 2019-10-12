local Dialog = ...

if Dialog then
  local soc = require('socket')
  channel = {}
  channel.text = love.thread.getChannel('NewText')
  channel.speed = love.thread.getChannel('Speed')

  local wait = 0.1
  local text = ""
  for i=1, string.len(Dialog) do
    text = string.sub(Dialog,1,i)
    channel.text:push(text)
    local speed = channel.speed:pop()
    local curwait = wait
    if speed then
      curwait = 0.01
    end
    soc.sleep(curwait)
  end
end