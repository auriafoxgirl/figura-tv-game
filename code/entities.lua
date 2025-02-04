local entities = {}

local input = require('code.input')
local levels = require('code.levels')
local tiles = require('code.tiles')
local gameParticles = require('code.particles')
local dialog = require('code.dialog')
local utils = require('code.utils')
local items = require('code.items')

local worldModel = models.model.Hud.world
local entityModel = nil
local itemList = {}

local jumpBuffer = 0
local coyoteJump = 0
local jumpTime = 0

function entities.clear()
   if entityModel then worldModel:removeChild(entityModel) end
   entityModel = worldModel:newPart('entity'):setPos(0, 0, -1)
   levelEntities = {}
   itemList = {}
end

function entities.add(tileData, pos, id)
   local id = id or tileData.entity == 'player' and 'player' or #levelEntities + 1
   if levelEntities[id] then entities.remove(id) end
   local sprite = utils.emptyCube:copy(id)
   entityModel:addChild(sprite)
   levelEntities[id] = {
      oldPos = pos,
      pos = pos,
      depth = 0,
      vel = vec(0, 0),
      moveTime = 0,
      wasOnGround = true,
      type = tileData.entity,
      tile = tileData,
      sprite = sprite,
      id = id
   }
   if tileData.entity == 'player' then
      cameraPos = pos + 0.5
      oldCameraPos = cameraPos
   end
   return levelEntities[id]
end

function entities.remove(id)
   local e = levelEntities[id]
   if not e then return end
   entityModel:removeChild(e.sprite)
   levelEntities[e] = nil
end

function entities.addItem(id)
   if itemList[id] then return end
   local entity = entities.add(
      {
         entity = 'item',
      },
      vec(0, 0),
      'item:'..id
   )
   entity.itemOffset = items[id].itemOffset / 8
   entity.uv = items[id].uv
   entity.depth = items[id].depth
   itemList[id] = entity
end

function entities.removeItem(id)
   if not itemList[id] then return end
   entities.remove(itemList[id].id)
   itemList[id] = nil
end

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

function entities.tick(e)
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
         e.vel.y = 0
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
            for _ = 1, 16 do
               local offset = math.random() - 0.5
               gameParticles.spawn(
                  math.random(5, 10),
                  e.pos + vec(0.5 + offset * 0.5, -1),
                  vec(offset * 0.05, math.random() * 0.1 + 0.05),
                  0,
                  vec(1, 1, 1) * (math.random() * 0.4 + 0.6),
                  vec(0.5, 0.5, 0.5)
               )
            end
         end
      end
      if onGround and not e.wasOnGround then
         sounds['minecraft:block.stone.fall']:pos(player:getPos()):play()
         for _ = 1, 16 do
            local offset = math.random() - 0.5
            gameParticles.spawn(
               math.random(5, 10),
               e.pos + vec(0.5 + offset * 0.5, -1),
               vec(offset * 0.15, math.random() * 0.04 + 0.04),
               0.01,
               vec(1, 1, 1) * (math.random() * 0.5 + 0.5),
               vec(0.4, 0.4, 0.4)
            )
         end
      end
      e.wasOnGround = onGround
      -- left right
      local tileBelow = onGround and levelTiles[math.floor(e.pos.x + 0.5)] and levelTiles[math.floor(e.pos.x + 0.5)][math.floor(e.pos.y - 0.5)] or {}
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
         e.vel.x = 0
      end
      local oldMoveTime = e.moveTime
      e.moveTime = e.moveTime + math.abs(e.pos.x - e.oldPos.x)
      if e.type == 'player' then
         -- particles
         if onGround and math.abs(e.vel.x) > 0.2 and oldMoveTime % 1 < 0.5 and e.moveTime % 1 >= 0.5 then
            gameParticles.spawn(
               math.random(5, 8),
               e.pos + vec(0.25 + math.random() * 0.5, -1),
               vec(-e.vel.x * 0.5, 0.1 + math.random() * 0.1),
               0.05,
               vec(1, 1, 1) * (math.random() * 0.2 + 0.8),
               vec(0.5, 0.5, 0.5)
            )
         end
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
               for _, tilesX in pairs(levelTiles) do
                  for y, t in pairs(tilesX) do
                     local unlockedId = t.id..' key:'..tile.key
                     if tiles[unlockedId] then
                        tilesX[y] = tiles[unlockedId]
                     end
                  end
               end
               if levelTiles[pos.x][pos.y] == tile then
                  levelTiles[pos.x][pos.y] = tiles[' ']
               end
            end
            if tile.signText then
               dialog.set(tile.signText, 4)
            end
            if tile.giveItem then entities.addItem(tile.giveItem) end
            if tile.removeItem then entities.removeItem(tile.removeItem) end
         end
         if tileBelow then
            if tileBelow.jump then e.vel.y = tileBelow.jump end
         end
         -- in void
         if not (pos > levelSafeArea.xy and pos < levelSafeArea.zw) then
            setLevel()
         end
      end
   end
   if e.type == 'item' then
      if levelEntities.player then
         e.pos = levelEntities.player.pos + e.itemOffset
         e.oldPos = levelEntities.player.oldPos + e.itemOffset
         e.hide = levelEntities.player.hide
      else
         e.hide = true
      end 
   end
end

function entities.render(e)
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
   elseif e.type == 'item' then
      return e.uv, levelEntities.player and levelEntities.player.flip
   end
   return vec(0, 0), false
end

return entities