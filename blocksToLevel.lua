-- simple tool to make levels in game easier
--[[@@@
/figura run require('blocksToLevel')()
--]]

local faces = {
   south = vec(1, 0, 0),
   west = vec(0, 0, 1),
   north = vec(-1, 0, 0),
   east = vec(0, 0, -1)
}

local dirs = {}
for x = -4, 4 do
   for y = -4, 4 do
      if x ~= 0 or y ~= 0 then
         table.insert(dirs, vec(x, y))
      end 
   end
end

local function box(p)
   p = p:copy()
   for _ = 1, 32 do
      particles['end_rod']:pos(
         p + vec(
            math.random(),
            math.random(),
            math.random()
         ) * 1.2 - 0.1
      ):lifetime(100):gravity(0):spawn()
   end
end

local tiles = {
   ['minecraft:gold_ore'] = 'q',
   ['minecraft:gold_block'] = 'Q',
   ['minecraft:redstone_ore'] = 'o',
   ['minecraft:redstone_block'] = 'O',
   ['minecraft:lapis_ore'] = 'k',
   ['minecraft:lapis_block'] = 'K',
   ['minecraft:pink_glazed_terracotta'] = 'P',
   ['minecraft:end_rod'] = '^',
   ['minecraft:slime_block'] = '+',
   ['minecraft:stone_bricks'] = 'F',
}
local fullTiles = {
   ['F'] = true,
   ['+'] = true,
}

local function getTile(pos, blocks)
   local block = blocks[tostring(pos)]
   if not block then return end
   if block.id == 'minecraft:stone_bricks' then
      local block2 = blocks[tostring(pos + vec(0, 1))]
      if fullTiles[tiles[block2 and block2.id]] then
         return 'F'
      else
         return 'f'
      end
   elseif tiles[block.id] then
      return tiles[block.id]
   elseif block.id == 'minecraft:iron_door' or block.id == 'minecraft:cherry_door' then
      local top = block.properties and block.properties.half == 'upper'
      if block.id == 'minecraft:cherry_door' then
         return top and '[' or ']'
      else
         return top and '(' or ')'
      end
   end
end

local function find()
   local block, hitPos, face = player:getTargetedBlock()
   if block:isAir() then return end
   if not faces[face] then return end
   local pos = (hitPos - player:getLookDir() * 0.01):floor()
   local x = faces[face]
   local y = vec(0, 1, 0)
   local blocks = {[tostring(vec(0, 0))] = world.getBlockState(pos)}
   local blocksToCheck = {[tostring(vec(0, 0))] = vec(0, 0)}
   local count = 1
   local min = vec(0, 00)
   local max = vec(0, 0)
   for _ = 1, 10 do
      local newBlocksToCheck = {}
      for _, p in pairs(blocksToCheck) do
         for _, dir in pairs(dirs) do
            local p2 = p + dir
            local id = tostring(p2)
            local block = world.getBlockState(pos + x * p2.x + y * p2.y)
            if not blocks[id] and not block:isAir() then
               count = count + 1
               blocks[id] = block
               newBlocksToCheck[id] = p2
               min = vec(
                  math.min(min.x, p2.x),
                  math.min(min.y, p2.y)
               )
               max = vec(
                  math.max(max.x, p2.x),
                  math.max(max.y, p2.y)
               )
            end
         end
      end
      blocksToCheck = newBlocksToCheck
      if count > 256 then break end
   end
   for _, b in pairs(blocks) do
      box(b:getPos())
   end
   local final = {"{\n   theme = 'tv',\n   world = [[\n"}
   for y = max.y + 1, min.y - 1, -1 do
      for x = min.x - 1, max.x + 1 do
         local tile = getTile(vec(x, y), blocks)
         table.insert(final, tile or ' ')
      end
      table.insert(final, '\n')
   end
   table.insert(final, ']]\n},')
   local output = table.concat(final)
   print('level saved to clipboard')
   host:setClipboard(output)
end

return find