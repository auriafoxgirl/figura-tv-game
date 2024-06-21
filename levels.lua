local tiles = require('tiles')

return {
   {
   theme = 'house',
   zoom = 2,
   noInput = true,
   cameraOffset = vec(-2, 7/8),
   transitionOffset = vec(-2, 7/8),
   world = [[
999999999wcccccccccwcccccccccccc
999999999wcccccccccwcccccccccccc
999999999wcccccccccwcccccccccccc
999999999wcccccccccwcccccccccccc
999999999wcccccccccwcccccccccccc
999999999wcccccccccwcccccccccccc
999999999wcccccccccwcccccccccccc
999999999wCCCCCCCCCwCCCCCCCCCCCC
999999999w         w____________
999999999w ___12_5 w____________
999999999( _t_34__ (____________
888888888)  d Ps   )____________
777777777fffffffffffffffffffffff
666666666FFFFFFFFFFFFFFFFFFFFFFF
666666666FFFFFFFFFFFFFFFFFFFFFFF
666666666FFFFFFFFFFFFFFFFFFFFFFF
666666666FFFFFFFFFFFFFFFFFFFFFFF
]],
   tick = function()
      levelEntities[1].hide = true
   end
   },
{
   theme = 'house',
   zoom = 2,
   noInput = true,
   world = [[
999999999wcccccccccwcccccccccccc
999999999wcccccccccwcccccccccccc
999999999wcccccccccwcccccccccccc
999999999wcccccccccwcccccccccccc
999999999wcccccccccwcccccccccccc
999999999wcccccccccwcccccccccccc
999999999wcccccccccwcccccccccccc
999999999wCCCCCCCCCwCCCCCCCCCCCC
999999999w         w____________
999999999w ___12_5 w____________
999999999( _T_34__ (____________
888888888)P d  s   )____________
777777777fffffffffffffffffffffff
666666666FFFFFFFFFFFFFFFFFFFFFFF
666666666FFFFFFFFFFFFFFFFFFFFFFF
666666666FFFFFFFFFFFFFFFFFFFFFFF
666666666FFFFFFFFFFFFFFFFFFFFFFF
]],
   tick = function(time)
      local player = levelEntities[1]
      if time <= 36 then
         player.vel = vec(0.12, 0)
      elseif time <= 38 then
         player.vel = vec(-0.01, 0)
      elseif time <= 74 then
         if time >= 44 then
            player.vel = vec(0.12, 0)
         end
      elseif time <= 80 then
         if time == 75 then
            player.vel = vec(-0.01, 0.5)
         end
      elseif time <= 100 then
         local y = player.pos.y
         player.pos.y = math.floor(y) + 0.5
         player.vel = vec(0, 0)
      elseif time == 101 then
         player.vel = vec(-0.2, 0.5)
      elseif time <= 120 then
         player.vel.x = -0.2
         if time == 115 then
            player.vel.y = 0.6
         end
      elseif time <= 250 then
         if time == 125 or time == 140 or time == 180 or time == 220 then
            player.vel = vec(0.05, 0.6)
         end
      elseif time <= 260 then
         player.vel.x = 0.15
      elseif time == 270 then
         player.vel = vec(-0.6, 0.6)
      elseif time == 280 then
        player.hide = true
        nextLevel()
      end
      if time >= 90 and not (time >= 150 and time <= 160) and not (time >= 190 and time <= 200) and not (time >= 230 and time <= 240) then
         tiles['T'].uv = vec(7, time % 8)
      else
         tiles['T'].uv = vec(6, 4 + math.clamp(math.floor((time - 40) * 0.25), 0, 3))
      end
   end
   },
{
   theme = 'tv',
   world = [[
                     
                  [  
  (               ]  
  )P     ff     ffff 
 fffff^^^^^^^fffFFFF 
 FFFFFfffffffFFFFF   
   FFFFFFFFFFFFFFF   
     FFFFFFFFFFF     
        FFFFF        
                     
]]
},
{
   theme = 'tv',
   world = [[
       [              
       ]              
      fff             
            fff       
  (               fff 
  )P             fFFF 
 fffff          fFFF  
 FFFFF^^^^ff     FF   
 FFFFFffffFF          
  FFFFFFFFF           
]]
},
{
   theme = 'tv',
   world = [[
                   Q              
        (          Q          [   
 q      )P         Q          ]   
fff   fffff   ffff Q ffff   fffff 
       FFF     FF     FF     FFF  
]]
},
{
   theme = 'tv',
   world = [[
                 (  O  [ 
 o q k          P)  O  ] 
fffffff QQOOKK ffff   fff
 FFFFF          FF       
  FFF                    
]]
},
{
   theme = 'tv',
   world = [[
    f                                
    F      k  f                      
    F     fff F                      
    F K       F                      
    F KK                             
    F  KK                            
    F   KK                           
    F       KKK             (   O  [ 
    F^^^^^^^f f   KKK       )P  O  ] 
    F       F F^^^^^^^^^fOOOfff   fff
                 Q         fFFF      
                 Q        fFFF       
 q               Q     o fFFFF       
fff   OOO   fff  OOOO  ffFFFF        
]]
}
}