local tiles = {
   [' '] = {uv = vec(0, 0), noCollision = true, light = 0.25}, -- empty
   ['_'] = {uv = vec(0, 0), noCollision = true, light = 1}, -- light
   ['P'] = {entity = 'player', physics = true, hitbox = vec(7, 7.9)}, -- player
   ['T'] = {uv = vec(6, 4), oneWay = true, light = 1}, -- tv
   ['t'] = {uv = vec(7, 0), frames = 8, oneWay = true, light = 1}, -- static tv
   ['f'] = {uv = vec(0, 1)}, -- floor
   ['F'] = {uv = vec(0, 2)}, -- floor2
   ['d'] = {uv = vec(1, 1), oneWay = true}, -- drawer
   ['s'] = {uv = vec(1, 2), noCollision = true}, -- sofa
   ['1'] = {uv = vec(3, 1), noCollision = true, light = 1}, -- window 1, lamp
   ['2'] = {uv = vec(4, 1), noCollision = true, light = 1}, -- window 2
   ['3'] = {uv = vec(3, 2), noCollision = true, light = 1}, -- window 3
   ['4'] = {uv = vec(4, 2), noCollision = true, light = 1}, -- window 4
   ['w'] = {uv = vec(2, 1)}, -- wall
   ['W'] = {uv = vec(2, 2)}, -- wall 2
   ['c'] = {uv = vec(2, 3)}, -- ceiling
   ['C'] = {uv = vec(2, 4)}, -- ceiling 2
   ['5'] = {uv = vec(3, 3), noCollision = true}, -- painting
   ['('] = {uv = vec(0, 3), noCollision = true}, -- door1
   [')'] = {uv = vec(0, 4), noCollision = true}, -- door2
   ['['] = {uv = vec(0, 3), noCollision = true, code = function() nextLevel() end}, -- warp door1
   [']'] = {uv = vec(0, 4), noCollision = true, code = function() nextLevel() end}, -- warp door2
   ['9'] = {uv = vec(1, 3), light = 1}, -- sky
   ['8'] = {uv = vec(1, 4), light = 1}, -- sky grass
   ['7'] = {uv = vec(1, 5)}, -- grass
   ['6'] = {uv = vec(1, 6)}, -- dirt
   ['^'] = {uv = vec(5, 0), frames = 8, light = 1, speed = 0.5, damage = true, noCollision = true}, -- cable

   ['q'] = {uv = vec(2, 5), light = 1, noCollision = true, key = 1}, -- key yellow
   ['Q'] = {uv = vec(2, 6), light = 1}, -- key block locked yellow
   ['Q key:1'] = {uv = vec(2, 7), light = 1, noCollision = true}, -- key block unlocked yellow

   ['k'] = {uv = vec(3, 5), light = 1, noCollision = true, key = 2}, -- key blue
   ['K'] = {uv = vec(3, 6), light = 1}, -- key block locked blue
   ['K key:2'] = {uv = vec(3, 7), light = 1, noCollision = true}, -- key block unlocked blue

   ['o'] = {uv = vec(4, 5), light = 1, noCollision = true, key = 3}, -- key red
   ['O'] = {uv = vec(4, 6), light = 1}, -- key block locked red
   ['O key:3'] = {uv = vec(4, 7), light = 1, noCollision = true}, -- key block unlocked red
}

for id, tile in pairs(tiles) do
   tile.id = id
end

return tiles