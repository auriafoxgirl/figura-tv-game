local particles = {}
local model = models.model.Hud.world.particles
local particleModel = model:newPart('particles')
local list = {}
local whitePixel = textures.whitePixel or textures:newTexture('whitePixel', 1, 1):setPixel(0, 0, 1, 1, 1)
local utils = require('code.utils')
model:pos(0, 0, -2)

function particles.clear()
   model:removeChild(particleModel)
   particleModel = model:newPart('particles')
   list = {}
end

---spawns particle
---@param time number?
---@param pos Vector3
---@param vel Vector3?
---@param gravity number?
---@param color Vector3?
---@param targetColor Vector3?
function particles.spawn(time, pos, vel, gravity, color, targetColor)
   local i = #list + 1
   local sprite = utils.emptyCube:copy(i)
   particleModel:addChild(sprite)
   sprite:primaryTexture('custom', whitePixel)
   sprite:scale(1 / 8)
   sprite:color(color)
   list[i] = {
      sprite = sprite,
      pos = pos,
      oldPos = pos,
      vel = vel or vec(0, 0),
      time = 0,
      maxTime = time or 10,
      color = color or vec(1, 1, 1),
      targetColor = targetColor or color or vec(1, 1, 1),
      gravity = gravity or 0
   }
end

function particles.tick()
   for i, particle in pairs(list) do
      particle.time = particle.time + 1
      if particle.time > particle.maxTime then
         particleModel:removeChild(particle.sprite)
         list[i] = nil
      else
         particle.oldPos = particle.pos
         particle.pos = particle.pos + particle.vel
         particle.vel = particle.vel * 0.9 - vec(0, particle.gravity)
         particle.sprite:color(math.lerp(particle.color, particle.targetColor, math.min(particle.time / particle.maxTime, 1)))
      end
   end
end

function particles.render(delta, cameraFull)
   for _, particle in pairs(list) do
      local pos = math.lerp(particle.oldPos, particle.pos, delta)
      -- pos = (pos * 8):floor() / 8
      particle.sprite:setPos((cameraFull - pos.x_ + pos._y).xy_ * 8)
   end
end

return particles