-- libraries and stuff
local utils = require('utils')
local tiles = require('tiles')
local levels = require('levels')
local entities = require('entities')
local textureAssets = textures.assets
local whitePixel = textures.whitePixel or textures:newTexture('whitePixel', 1, 1):setPixel(0, 0, 1, 1, 1)
time = 0

-- pause game
gamePaused = false
keybinds:newKeybind('pause', 'key.keyboard.o').press = function()
   gamePaused = not gamePaused
   if gamePaused then print('press O to unpause') end
end

-- model
local hud = models.model.Hud
local worldModel = hud.world
local entityModel = worldModel:newPart('entity'):setPos(0, 0, -1)
local tilesModel = hud.world.tiles
local emptyCube = models.model.emptyCube
models.model:removeChild(emptyCube)
emptyCube:light(15, 15)
local background = hud.background

-- level
loaded = nil
levelTiles = nil
levelDefaultTile = nil
levelEntities = nil
levelLight = nil
cameraPos = vec(0, 0)
oldCameraPos = vec(0, 0)
local cameraZoom = 1

local lightOffsets = {}
for x = -8, 8 do
   for y = -8, 8 do
      local lightStrength = 1 - math.min(vec(x, y):length() / 8, 1)
      if lightStrength > 0 then
         lightOffsets[vec(x, y)] = 1 - (1 - lightStrength) ^ 2
      end
   end
end

local function loadLevel(id)
   local levelData = levels[id]
   cameraZoom = levelData.zoom or 1

   entityModel:removeTask()
   levelEntities = {}

   levelTiles = {}
   levelDefaultTile = tiles[levelData.default]

   local x, y = 0, 0
   local level = levelData.world
   local lightSources = {}
   for i = 1, #level do
      local char = level:sub(i, i)
      if char == '\n' then
         y = y - 1
         x = 0
      else
         x = x + 1
         if not levelTiles[x] then levelTiles[x] = {} end
         local tileData = tiles[char] or {}
         if tileData.entity then
            local sprite = entityModel:newSprite(x..'_'..y)
               :texture(textureAssets, 8, 8)
               :pos(-x * 8, y * -8)
               :light(15, 15)
            local spriteVertices = {}
            for i, v in pairs(sprite:getVertices()) do
               spriteVertices[i] = {vertex = v, uv = v:getUV()}
            end
            table.insert(levelEntities, {
               oldPos = vec(x, y),
               pos = vec(x, y),
               vel = vec(0, 0),
               moveTime = 0,
               type = tileData.entity,
               tile = tileData,
               sprite = sprite,
               spriteVertices = spriteVertices,
            })
            if tileData.entity == 'player' then
               cameraPos = vec(x, y) + 0.5
               oldCameraPos = cameraPos
            end
            levelTiles[x][y] = tiles[' ']
         else
            if tileData.light then table.insert(lightSources, vec(x, y)) end
            levelTiles[x][y] = tileData
         end
      end
   end
   if loaded == id then return end
   loaded = id
   levelLight = {}
   for _, lightPos in pairs(lightSources) do
      for pos, l in pairs(lightOffsets) do
         local p = lightPos + pos
         if not levelLight[p.x] then levelLight[p.x] = {} end
         levelLight[p.x][p.y] = math.max(levelLight[p.x][p.y] or 0, l)
      end
   end
end

loadLevel('room')

-- tick
function events.tick()
   if gamePaused then return end
   time = time + 1
   oldCameraPos = cameraPos:copy()
   for _, v in pairs(levelEntities) do
      v.oldPos = v.pos:copy()
      entities.tick(v)
   end
end

-- render
local tilesSprites = {}
for x = -20, 20 do
   for y = -8, 8 do
      local sprite = emptyCube:copy(x..'_'..y)
      sprite:pos(-x * 8, y * -8)
      tilesModel:addChild(sprite)
      table.insert(tilesSprites, {
         pos = vec(x, y),
         sprite = sprite
      })
   end
end

function events.world_render(delta)
   if gamePaused then
      renderer:setRenderHUD(true)
      hud:setVisible(false)
      return
   end
   hud:setVisible(true)
   renderer:setRenderHUD(false)
   local windowSize = client.getScaledWindowSize()
   local camera = math.lerp(oldCameraPos, cameraPos, delta)
   local cameraFull = camera:copy():floor()
   local cameraOffset = vec(camera.x % 1, 1 - camera.y % 1)
   camera.y = -camera.y
   cameraFull.y = -cameraFull.y
   local scale = windowSize.y / (16 * 8) * cameraZoom
   worldModel:setPos(cameraOffset.xy_ * 8 * scale - windowSize.xy_ * 0.5)
   worldModel:setScale(scale)
   -- background
   background:setPrimaryTexture('custom', levels[loaded].backgroundTexture or whitePixel, 16, 16)
   background:color(levels[loaded].backgroundColor or whitePixel)
   local bgScale = windowSize.y / 16
   background:setPos(-windowSize.xy_ * 0.5)
   background:setScale(bgScale, bgScale)
   -- tiles
   for _, sprite in pairs(tilesSprites) do
      local pos = sprite.pos + cameraFull
      local tile = levelTiles[pos.x] and levelTiles[pos.x][-pos.y] or levelDefaultTile
      local uv = tile and tile.uv or vec(0, 0)
      if tile and tile.frames then
         uv = uv + vec(0, math.floor(time * tile.speed) % tile.frames)
      end
      sprite.sprite:setUV(uv / 8) -- * 8 / 64
      local l = levelLight[pos.x] and levelLight[pos.x][-pos.y] or 0
      sprite.sprite:setColor(l, l, l)
   end
   -- entities
   for _, e in pairs(levelEntities) do
      local uv, flip = entities.render(e)
      local pos = math.lerp(e.oldPos, e.pos, delta)
      e.sprite:setPos((cameraFull - pos.x_ + pos._y).xy_ * 8)
      if flip then
         for _, v in pairs(e.spriteVertices) do v.vertex:setUV((1 - v.uv.x + uv.x) / 8, (v.uv.y + uv.y) / 8) end
      else
         for _, v in pairs(e.spriteVertices) do v.vertex:setUV((v.uv + uv) / 8) end
      end
   end
end