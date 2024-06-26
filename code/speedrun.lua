local module = {}
local time = -1
local speedrunMode = false
local allowSpeedrun = 0

local bestTime = config:load('bestTime')
local textTask = models.model.Hud:newText('speedrun')
textTask:setLight(15, 15):setOutline(true):setPos(-4, -4, -64):scale(1.49)

local levels = require('code.levels')

function module.startSpeedrun()
   allowSpeedrun = 40
   setLevel(3)
end

function module.getTime(t)
   t = t or bestTime
   if not t then return end
   local seconds = math.floor(t / 20) % 60
   local minutes = math.floor(t / 20 / 60)
   local text = string.format('%02d', seconds)..':'
   if minutes > 0 then text = minutes..':'..text end
   local a = ((t / 20) % 1) * 100
   text = text..string.format('%02d', a)
   return text
end

function module.tick()
   local currentLevel = levels[loaded]
   local displayTimer = speedrunMode
   if currentLevel.speedrun == 'start' then
      if not speedrunMode and allowSpeedrun >= 1 then
         speedrunMode = true
         time = 0
      end
   elseif currentLevel.speedrun == 'end' then
      displayTimer = time >= 1
      if speedrunMode then
         speedrunMode = false
         allowSpeedrun = 0
         if not bestTime or time < bestTime then
            bestTime = time
            config:save('bestTime', time)
         end
      end
   elseif currentLevel.speedrun == 'stop' then
      speedrunMode = false
      allowSpeedrun = math.max(allowSpeedrun - 1, 0)
      time = -1
   end
   if speedrunMode then time = time + 1 end
   textTask:setVisible(displayTimer)
   if displayTimer then
      textTask:setText(module.getTime(time))
   end
end

return module