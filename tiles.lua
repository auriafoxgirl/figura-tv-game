return {
   [' '] = {uv = vec(0, 0), noCollision = true}, -- empty
   ['_'] = {uv = vec(0, 0), noCollision = true, light = true}, -- light
   ['P'] = {entity = 'player', physics = true, hitbox = vec(7, 7.9)}, -- player
   ['T'] = {uv = vec(6, 4), oneWay = true, light = true}, -- tv
   ['f'] = {uv = vec(0, 1)}, -- wood floor
   ['F'] = {uv = vec(0, 2)}, -- wood floor2
   ['d'] = {uv = vec(1, 1), oneWay = true}, -- drawer
   ['s'] = {uv = vec(1, 2), noCollision = true}, -- sofa
   ['1'] = {uv = vec(3, 1), noCollision = true, light = true}, -- window 1
   ['2'] = {uv = vec(4, 1), noCollision = true, light = true}, -- window 2
   ['3'] = {uv = vec(3, 2), noCollision = true, light = true}, -- window 3
   ['4'] = {uv = vec(4, 2), noCollision = true, light = true}, -- window 4
   ['w'] = {uv = vec(2, 1)}, -- wall
   ['W'] = {uv = vec(2, 2)}, -- wall 2
   ['c'] = {uv = vec(2, 3)}, -- ceiling
   ['C'] = {uv = vec(2, 4)}, -- ceiling 2
   ['5'] = {uv = vec(3, 3), noCollision = true}, -- painting
   ['('] = {uv = vec(0, 3)}, -- dor1
   [')'] = {uv = vec(0, 4)}, -- dor1
}