local model = models.model.Hud.levelTransition
local levels = require('levels')
local progress = require('progress')
local whitePixel = textures.whitePixel or textures:newTexture('whitePixel', 1, 1):setPixel(0, 0, 1, 1, 1)
local levelTransition = -1
local animPos = vec(0, 0)
local targetLevel = nil
model:pos(0, 0, -8):color(0, 0, 0)

local sprites = {}
for i = 1, 4 do
   sprites[i] = model:newSprite(tostring(i))
      :texture(whitePixel, 1, 1)
      :color(0, 0, 0)
end

local function getAnimPos()
   for _, v in pairs(levelEntities) do
      if v.type == 'player' then
         animPos = v.pos + 0.5
         animPos.y = -animPos.y
         break
      end
   end
   local transitionOffset = levels[loaded].transitionOffset
   if transitionOffset then
      animPos.x = animPos.x + transitionOffset.x
      animPos.y = animPos.y - transitionOffset.y
   end
end

function setLevel(level)
   if levelTransition < 0 then
      levelTransition = 1
      targetLevel = level or loaded
      getAnimPos()
      return true
   end
end
function nextLevel()
   if levelTransition < 0 then
      levelTransition = 1
      targetLevel = math.min(loaded + 1, #levels)
      progress.updateProgress(targetLevel)
      getAnimPos()
   end
end

function events.tick()
   if levelTransition < 0 then return end
   levelTransition = levelTransition + 1
   if levelTransition == 11 then
      loadLevel(targetLevel)
      getAnimPos()
      setUIScreen()
   elseif levelTransition > 22 then
      levelTransition = -1
   end
end

return function(delta, camera, worldScale)
   if levelTransition < 0 then
      model:visible(false)
      return
   end
   local t = levelTransition + delta
   local scale = 1
   if levelTransition < 11 then
      scale = math.clamp(1 - t / 10, 0, 1)
      scale = 1 - (1 - scale) ^ 2
   else
      scale = math.clamp((t - 12) / 10, 0, 1)
      scale = scale ^ 2
   end
   model:visible(true)
   local windowSize = client.getScaledWindowSize()
   local maxSize = math.max(windowSize:unpack())
   local size = maxSize * scale
   local pos = (camera.xy - animPos) * worldScale * 8 - windowSize * 0.5
   local corner1, corner2 = pos + size, pos - size
   model.circle:pos(pos.xy_)
   model.circle:scale(size / 20)
   sprites[1]:pos(corner1.x__):scale(corner1.x__ + windowSize._y_)
   sprites[2]:pos(corner2.x__):scale(windowSize._y_ + corner2.x__ + windowSize.x__)
   sprites[3]:pos(corner1._y_):scale(corner1._y_ + windowSize.x__)
   sprites[4]:pos(corner2._y_):scale(corner2._y_ + windowSize.xy_)
end