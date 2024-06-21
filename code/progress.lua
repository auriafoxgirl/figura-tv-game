local finishedLevels = config:load('finishedLevels') or 0
local module = {}
function module.getProgress()
   return finishedLevels
end

function module.updateProgress(level)
   if level > finishedLevels then
      finishedLevels = level
      config:save('finishedLevels', finishedLevels)
   end
end

function module.resetProgress()
   finishedLevels = 0
   config:save('finishedLevels', finishedLevels)
end

return module