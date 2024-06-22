-- libraries and stuff
local tiles = require('code.tiles')
local levels = require('code.levels')
local gameParticles = require('code.particles')
local levelThemes = require('code.levelThemes')
local entities = require('code.entities')
local utils = require('code.utils')
local levelTransition = require('code.levelTransition')
local textureAssets = textures.assets
local tilesetSize = vec(64, 64)
local textureAssetsSize = textureAssets:getDimensions()
local whitePixel = textures.whitePixel or textures:newTexture('whitePixel', 1, 1):setPixel(0, 0, 1, 1, 1)
time = 0

-- pause game
gamePaused = false
gameHidden = false
keybinds:fromVanilla('figura.config.action_wheel_button').press = function()
   gameHidden = not gameHidden
   if gameHidden then
      local key = keybinds:getVanillaKey('figura.config.action_wheel_button'):gsub('^key%.keyboard%.', '')
      print('press '..key..' to show game')
   end
   return true
end

-- model
local hud = models.model.Hud
hud:setVisible(false)
local worldModel = hud.world
local entityModel = nil
local tilesModel = hud.world.tiles
local background = hud.background
local figuraGuiInfo = models.model.CameraFiguraGuiInfo
figuraGuiInfo:setPrimaryRenderType('EMISSIVE_SOLID')
figuraGuiInfo.cube:setScale(2, 2, 2)
figuraGuiInfo:newText('')
             :pos(0, -8, -34):scale(0.4)
             :text('close figura\nmenu to play!')
             :alignment("CENTER")
             :outline(true):outlineColor(vectors.hexToRGB('#5d2c28'))

-- level
loaded = nil
levelTiles = nil
levelDefaultTile = nil
levelEntities = nil
levelLight = nil
cameraPos = vec(0, 0)
oldCameraPos = vec(0, 0)
levelSafeArea = vec(0, 0, 0, 0)
levelTheme = nil
local cameraZoom = 1
local levelTime = 0

local lightOffsets = {}
for x = -8, 8 do
   for y = -8, 8 do
      local lightStrength = 1 - math.min(vec(x, y):length() / 8, 1)
      if lightStrength > 0 then
         lightOffsets[vec(x, y)] = 1 - (1 - lightStrength) ^ 2
      end
   end
end

function loadLevel(id)
   local wasLoadedBefore = loaded == id
   loaded = id
   local levelData = levels[id]
   levelTheme = levelThemes[levelData.theme] or levelThemes.house
   cameraZoom = levelData.zoom or 1

   if entityModel then worldModel:removeChild(entityModel) end
   entityModel = worldModel:newPart('entity'):setPos(0, 0, -1)
   levelEntities = {}

   levelTiles = {}
   levelDefaultTile = tiles[levelTheme.defaultTile]
   levelTime = 0

   gameParticles.clear()

   local x, y = 0, 0
   local maxX = 0
   local level = levelData.world
   local lightSources = {}
   for i = 1, #level do
      local char = level:sub(i, i)
      if char == '\n' then
         y = y - 1
         maxX = math.max(maxX, x)
         x = 0
      else
         x = x + 1
         if not levelTiles[x] then levelTiles[x] = {} end
         local tileData = tiles[char] or {}
         if tileData.entity then
            local sprite = utils.emptyCube:copy(x..'_'..y)
            entityModel:addChild(sprite)
            table.insert(levelEntities, {
               oldPos = vec(x, y),
               pos = vec(x, y),
               vel = vec(0, 0),
               moveTime = 0,
               wasOnGround = true,
               type = tileData.entity,
               tile = tileData,
               sprite = sprite,
            })
            if tileData.entity == 'player' then
               cameraPos = vec(x, y) + 0.5
               oldCameraPos = cameraPos
            end
            levelTiles[x][y] = tiles[' ']
         else
            levelTiles[x][y] = tileData
         end
         if tileData.light then table.insert(lightSources, vec(x, y, char == ' ' and levelTheme.light or tileData.light)) end
      end
   end
   maxX = math.max(maxX, x)
   levelSafeArea = vec(
      -6,
      y - 1,
      maxX + 6,
      4096
   )
   if wasLoadedBefore then return end
   levelLight = {}
   for _, lightPos in pairs(lightSources) do
      -- local lPos, s = lightPos.xy, 
      for pos, l in pairs(lightOffsets) do
         local p = lightPos.xy + pos
         if not levelLight[p.x] then levelLight[p.x] = {} end
         levelLight[p.x][p.y] = math.max(levelLight[p.x][p.y] or 0, l * lightPos.z)
      end
   end
end

loadLevel(1)

-- tick
function events.tick()
   if gamePaused or gameHidden then return end
   time = time + 1
   levelTime = levelTime + 1
   oldCameraPos = cameraPos:copy()
   for _, v in pairs(levelEntities) do
      v.oldPos = v.pos:copy()
      entities.tick(v)
   end
   if levels[loaded].tick then
      levels[loaded].tick(levelTime)
   end
   gameParticles.tick()
end

-- render
local tilesSprites = {}
for x = -20, 20 do
   for y = -8, 8 do
      local sprite = utils.emptyCube:copy(x..'_'..y)
      sprite:pos(-x * 8, y * -8)
      tilesModel:addChild(sprite)
      table.insert(tilesSprites, {
         pos = vec(x, y),
         sprite = sprite
      })
   end
end

function events.render(_, context)
   figuraGuiInfo:setVisible(context == 'FIGURA_GUI')
end

function events.world_render(orginalDelta)
   if gameHidden then
      renderer:setRenderHUD(true)
      hud:setVisible(false)
      return
   end
   hud:setVisible(true)
   renderer:setRenderHUD(false)
   local gameBrightness = 1
   local delta = orginalDelta
   if gamePaused then
      delta = 0.5
      gameBrightness = 0.5
   end
   local windowSize = client.getScaledWindowSize()
   local camera = math.lerp(oldCameraPos, cameraPos, delta)
   camera = camera + (levels[loaded].cameraOffset or vec(0, 0))
   local cameraFull = camera:copy():floor()
   local cameraOffset = vec(camera.x % 1, 1 - camera.y % 1)
   camera.y = -camera.y
   cameraFull.y = -cameraFull.y
   local scale = windowSize.y / (16 * 8) * cameraZoom
   worldModel:setPos(cameraOffset.xy_ * 8 * scale - windowSize.xy_ * 0.5)
   worldModel:setScale(scale)
   worldModel:setColor(gameBrightness, gameBrightness, gameBrightness)
   -- background
   background:setPrimaryTexture('custom', levelTheme.backgroundTexture or whitePixel, 16, 16)
   background:color((levelTheme.backgroundColor or vec(1, 1, 1)) * gameBrightness)
   local bgScale = windowSize.y / 16
   background:setPos(-windowSize.xy_ * 0.5)
   background:setScale(bgScale, bgScale)
   local bgUvMat = matrices.mat3()
   bgUvMat:scale(3, 1, 1):translate(camera.x * 0.01)
   background:setUVMatrix(bgUvMat)
   -- tiles
   local uvOffset = (levelTheme.tileset or vec(0, 0)) * tilesetSize
   for _, sprite in pairs(tilesSprites) do
      local pos = sprite.pos + cameraFull
      local tile = levelTiles[pos.x] and levelTiles[pos.x][-pos.y] or levelDefaultTile
      local uv = tile and tile.uv or vec(0, 0)
      if tile and tile.frames then
         local speed = tile.speed or 1
         local delay = tile.delay or 0
         uv = uv + vec(0, math.max(math.floor(time * speed + pos.x, 0) % (tile.frames + delay) - delay, 0))
      end
      sprite.sprite:setUVPixels(uv * 8 + uvOffset)
      local l = levelLight[pos.x] and levelLight[pos.x][-pos.y] or 0
      sprite.sprite:setColor(l, l, l)
   end
   -- entities
   for _, e in pairs(levelEntities) do
      local uv, flip = entities.render(e)
      local pos = math.lerp(e.oldPos, e.pos, delta)
      e.sprite:setPos((cameraFull - pos.x_ + pos._y).xy_ * 8)
      if flip then
         local mat = matrices.mat3()
         mat:scale(-1, 1, 1)
         mat:translate(uv / textureAssetsSize * 8)
         mat:translate(8 / textureAssetsSize.x, 0)
         e.sprite:setUVMatrix(mat)
      else
         e.sprite:setUVPixels(uv * 8)
      end
   end
   -- level transition
   levelTransition(orginalDelta, camera, scale)
   -- particles
   gameParticles.render(delta, cameraFull)
end