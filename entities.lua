local module = {}

local input = require('input')

local jumpBuffer = 0
local coyoteJump = 0
local jumpTime = 0

local function collision(pos, hitbox, ignoreOneWay, oldPos)
   hitbox = hitbox / 8
   hitbox.x = math.clamp(hitbox.x, -4, 4)
   hitbox.y = math.clamp(hitbox.y, -4, 4)
   local min = pos - vec(hitbox.x * 0.5 - 0.5, 0)
   local max = pos + vec(hitbox.x * 0.5 + 0.5, hitbox.y)
   for x = math.floor(min.x), math.ceil(max.x) do
      for y = math.floor(min.y), math.ceil(max.y) do
         local tile = levelTiles[x] and levelTiles[x][y] or levelDefaultTile
         if tile and not tile.noCollision then
            local tilePos = vec(x, y)
            if tile.oneWay then
               if not ignoreOneWay and min <= tilePos + 1 and max >= tilePos and oldPos.y >= tilePos.y + 0.99 then
                  return true
               end
            else
               if min <= tilePos + 1 and max >= tilePos then
                  return true
               end
            end
         end
      end
   end
   return false
end

function module.tick(e)
   if e.type == 'player' then
      jumpBuffer = math.max(jumpBuffer - 1, 0)
      coyoteJump = math.max(coyoteJump - 1, 0)
      jumpTime = math.max(jumpTime - 1, 0)
      if input.up:isPressed() then
         jumpBuffer = 2
      else
         jumpTime = 0
      end
   end
   if e.tile.physics then
      local onGround = false
      -- up, down
      if e.type == 'player' and jumpTime >= 1 then
         e.vel.y = e.vel.y * 0.975 - 0.05
      else
         e.vel.y = e.vel.y * 0.95 - 0.1
      end
      if e.type == 'player' and input.down:isPressed() and e.vel.y < 0 then
         e.vel.y = e.vel.y - 0.05
      end
      e.pos.y = e.pos.y + e.vel.y
      local ignoreOneWay = e.vel.y > 0 or input.down:isPressed()
      if collision(e.pos, e.tile.hitbox, ignoreOneWay, e.oldPos) then
         onGround = e.vel.y < 0
         e.pos.y = e.pos.y - e.vel.y
         for _ = 1, 4 do
            e.vel.y = e.vel.y * 0.5
            e.pos.y = e.pos.y + e.vel.y
            if collision(e.pos, e.tile.hitbox, ignoreOneWay, e.oldPos) then
               e.pos.y = e.pos.y - e.vel.y
            end
            end
         if onGround and e.type == 'player' then
            coyoteJump = 3
         end
      end
      if e.type == 'player' then
         if jumpBuffer >= 1 and coyoteJump >= 1 then
            e.vel.y = 0.6
            coyoteJump = 0
            jumpTime = 6
         end
      end
      -- left right
      if e.type == 'player' then
         local dir = (input.right:isPressed() and 1 or 0) - (input.left:isPressed() and 1 or 0)
         if dir ~= 0 then
            e.flip = dir < 0
         end
         dir = dir * 0.25
         e.vel.x = e.vel.x + dir
      end
      e.vel.x = e.vel.x * (onGround and 0.6 or 0.65)
      e.pos.x = e.pos.x + e.vel.x
      if collision(e.pos, e.tile.hitbox, true, e.oldPos) then
         e.pos.x = e.pos.x - e.vel.x
         for _ = 1, 4 do
            e.vel.x = e.vel.x * 0.5
            e.pos.x = e.pos.x + e.vel.x
            if collision(e.pos, e.tile.hitbox, true, e.oldPos) then
               e.pos.x = e.pos.x - e.vel.x
            end
         end
      end
      e.moveTime = e.moveTime + math.abs(e.pos.x - e.oldPos.x)
      if e.type == 'player' then
         cameraPos.x = math.lerp(cameraPos.x, e.pos.x + 0.5 + math.clamp(e.vel.x, -0.5, 0.5) * 6, 0.25)
         cameraPos.y = math.lerp(cameraPos.y, e.pos.y + 0.5, onGround and 0.4 or 0.2)
      end
   end
end

function module.render(e)
   if e.tile.uv then
      return e.tile.uv, false
   end
   if e.type == 'player' then
      local uv = vec(6, 0)
      if math.abs(e.vel.x) > 0.1 then
         uv.y = uv.y + math.floor(e.moveTime * 1.5) % 4
      end
      return uv, e.flip
   end
   return vec(0, 0), false
end

return module