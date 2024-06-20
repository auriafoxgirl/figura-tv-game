local module = {}

local input = require('input')
local levels = require('levels')
local tiles = require('tiles')

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
   local isPlayer = e.type == 'player' and not levels[loaded].noInput
   if isPlayer then
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
      if isPlayer and jumpTime >= 1 then
         e.vel.y = e.vel.y * 0.975 - 0.05
      else
         e.vel.y = e.vel.y * 0.95 - 0.1
      end
      if isPlayer and input.down:isPressed() and e.vel.y < 0 then
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
         if onGround and isPlayer then
            coyoteJump = 3
         end
      end
      if isPlayer then
         if jumpBuffer >= 1 and coyoteJump >= 1 then
            e.vel.y = 0.55
            coyoteJump = 0
            jumpTime = 4
            if collision(e.pos + e.vel, e.tile.hitbox, true, e.pos) then
               if not collision(vec(math.round(e.pos.x), e.pos.y) + e.vel, e.tile.hitbox, true, e.pos) then
                  e.pos.x = math.round(e.pos.x)
               end
            end
         end
      end
      if onGround and not e.wasOnGround then
         sounds['minecraft:block.stone.fall']:pos(player:getPos()):play()
      end
      e.wasOnGround = onGround
      -- left right
      if isPlayer then
         local dir = (input.right:isPressed() and 1 or 0) - (input.left:isPressed() and 1 or 0)
         dir = dir * 0.25
         e.vel.x = e.vel.x + dir
      end
      if e.vel.x ~= 0 then
         e.flip = e.vel.x < 0
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
      local oldMoveTime = e.moveTime
      e.moveTime = e.moveTime + math.abs(e.pos.x - e.oldPos.x)
      if e.type == 'player' then
         -- step sound
         if oldMoveTime % 2 < 1 and e.moveTime % 2 >= 1 and onGround then
            sounds['minecraft:block.stone.step']:pos(player:getPos()):play()
         end
         -- camera 
         cameraPos.x = math.lerp(cameraPos.x, e.pos.x + 0.5 + math.clamp(e.vel.x, -0.5, 0.5) * 6, 0.25)
         cameraPos.y = math.lerp(cameraPos.y, e.pos.y + 0.5, onGround and 0.4 or 0.2)
         local pos = (e.pos + 0.5):floor()
         -- tile
         local tile = levelTiles[pos.x] and levelTiles[pos.x][pos.y]
         if tile then
            if tile.damage then
               if setLevel() then
                  sounds['minecraft:entity.player.hurt_freeze']:pos(player:getPos()):pitch(1.6):play()
                  sounds['minecraft:entity.player.hurt_freeze']:pos(player:getPos()):pitch(1.2):play()
               end
            end
            if tile.code then tile.code(e) end
            if tile.key then
               levelTiles[pos.x][pos.y] = tiles[' ']
               for _, tilesX in pairs(levelTiles) do
                  for y, t in pairs(tilesX) do
                     local unlockedId = t.id..' key:'..tile.key
                     if tiles[unlockedId] then
                        tilesX[y] = tiles[unlockedId]
                     end
                  end
               end
            end
         end
         -- in void
         if not (pos > levelSafeArea.xy and pos < levelSafeArea.zw) then
            setLevel()
         end
      end
   end
end

function module.render(e)
   if e.hide then return vec(0, 0), false end
   if e.tile.uv then
      return e.tile.uv, false
   end
   if e.type == 'player' then
      local uv = vec(6, 0)
      if math.abs(e.vel.x) > 0.04 then
         uv.y = uv.y + math.floor(e.moveTime * 1.5) % 4
      end
      return uv, e.flip
   elseif e.type == 'tv' then
      local uv = vec(7, 0)
      return uv
   end
   return vec(0, 0), false
end

return module