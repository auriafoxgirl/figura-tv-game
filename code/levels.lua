local tiles = require('code.tiles')

local levels
levels = {
{ -- main menu room
   theme = 'house',
   speedrun = 'stop',
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
      levelEntities.player.hide = true
   end
},
{ -- prologue
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
      local player = levelEntities.player
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
   speedrun = 'start',
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
},
{
   theme = 'tv',
   world = [[
                                              
     K                                        
     K                                        
  q  K  o                                     
 fff^^^fff                                    
 FFFfffFFF   fOOOf           (         [      
  FFFFFFF^^^^FfkfF   QQQ   P )         ]      
    FFF      FFfFF^^^f f^^^ffff       fff     
             FFFFF   F F    FFF^^^^^^^FFFf    
              FFF    F                   Ff   
                     F                      f 
                     F                     fF 
                     Fff   ffff   ffff   ffF  
                                              
]]
},
{
   theme = 'tv',
   world = [[
                            
                      K     
                  (   K  [  
   k   o  o q  q  )P  K  ]  
 fffff OOOO QQQQ ffff K fff 
  FFF             FF        
                            
]]
},
{
   theme = 'tv',
   noAirLight = true,
   world = [[
                                              
         f            OOOfff   ff    fffff    
         F         ffOOO        Ff   F   Ff   
         F k   ffff                 O       f 
         FKKKffF                   OO      fF 
         F                        OO      fFF 
     KO  F                    ff^^fff^^^^fFFF 
     KO             ffffff^^^fF     FffffFFF  
     KO            fF                FFFFFFF  
     KO           fF                  FFFFFF  
  [  KO  (       fF                    FFFF   
  ]  KO  )P    f                       FFFF   
 fff KO fffOOOfFf                      FFFF   
        FFFfo   Fffff  KKff  KKfff     FFF    
        FFFFf       F^^^^^^^^^^^FFf    FFF    
         FFFFf                   FFf   FFF    
         FFFFFf                        FF     
          FFFFFf                       FF     
            FFFFf                      FF     
                   Kff                 F      
                         ffK       ffKKF      
                              fff   F^^F      
                                              
]]
},
{
   theme = 'tv',
   world = [[
              
          [   
          ]   
        fffff 
        FFFFF 
  (     FFFFF 
  )P    FFFF  
 ffffff+FFFF  
 FFFFFFFFFFF  
  FFFFFFFFF   
  FFFFFF      
              
]]
},
{
   theme = 'tv',
   world = [[
                        
                [       
                ]       
              ffff      
                        
                        
                        
                  f+fff 
                   FFF  
                        
                        
   (          ff+ff     
   )P         FFFFF     
 fffff  ff+ff  FFF      
 FFFFF   FFF            
  FFF                   
                        
]]
},
{
   theme = 'tv',
   world = [[
                           
     f^^^^^^^^^^^^^^^f     
                           
   (                   [   
   )P                  ]   
 ffffff+fff+fff+fff+ffffff 
                           
]]
},
{
   theme = 'tv',
   world = [[
                
          q     
                
                
    Q       f+f 
    Q       FFF 
  [ Q (     FFF 
  ] Q )P    FFF 
 fffffffff+fFFF 
 FFFFFFFFFFFFFF 
   FFFFFFFFFFF  
      FFFFFFFF  
      FFFFF     
                
]]
},
{
   theme = 'tv',
   world = [[
                             
     Q                       
     Q             O         
  [  Q   (         O         
  ]  Q  P)         O         
 fff Q fffff    ff O         
 FFF^^^^FFF        Q ddd     
                   Q         
                   Q  q   ff 
             f+ff  Q fffffFF 
     o   fff FFFF    FFFFFF  
   fffff FFF                 
    FFF  FFF                 
                             
]]
},
{
   theme = 'tv',
   world = [[
                       
 fffffffffffffffffffff 
 F   Q       F       F 
 F [ Q       F o     F 
 F ] Q       F       F 
 Fffff   ffffFffff   F 
 F   F       F       F 
 F   F       F       F 
 F   F       F       F 
 F   Ff+ff   F   ff+fF 
 F           F       F 
 F           F       F 
 F           F       F 
 F   ffffff+fFf+ffKKKF 
 F   F       O   F   F 
 F   F k     O q F   F 
 F   F       O   F   F 
 F  +Fffff   ffffF  +F 
 F                   F 
 F     (             F 
 F     )P            F 
 Ff+fffffff+fffffff+fF 
                       
]]
},
{
   theme = 'tv',
   noAirLight = true,
   world = [[
                                    
         f                          
        fF  o                       
       fFF  ff  fff                 
      fFF             fff        f  
     fFF                    ff   Ff 
     FFF                         FF 
     FFF                         FF 
     FFF           k     o       FF 
     FFF   fffff KKKKK OOOOO ff+fFF 
     FFF  fFFFFF^^^^^^^^^^^^^FFFFFF 
     FFF                         FF 
     FFF                         FF 
    fFFF                         FF 
    FFFF+ffff  ff+ff  ff+ff  ff  FF 
   fFFFFFFFFF  FFFFF  FFFFF  FF  FF 
  fFFFFFFFF                   F+ FF 
      O                        Q F  
   [  O                        Q F  
   ]  O q                      Q F  
 ffffffffffQ  QffQ  QffQ  Qfffdd+F  
  FFFFFFFFF^^^^FF^^^^FF^^^^FFF  FF  
                            FF+ FF  
                                F   
        (                       F   
        )P                      F   
      ffffff   ffff   ffff   ff+F   
      FFFFFF    FF     FF     FFF   
       FFFF                         
                                    
]]
},
{ -- cable room
   theme = 'tv',
   signs = {
      'Cables room',
      'Signal'
   },
   world = [[
              1
              1
              1
              1
              1
              1
              1!
              1!
              1!
 ffff         1!
fFFFFf        1!
FF   F        1!
FF76 (   (    2!
FFCL )# P)  # 1!
FFffffffffffffwff
 FFFFFFFFFW4443FF
 FFFFFFFFFcFFFFF
  FFFFFFFFcFFFF
    FFFFFFcFF
          1
          1
          1
          1
          1
          1
          1
          1
]]
},
{ -- ending animation
   theme = 'house',
   zoom = 2,
   noInput = true,
   speedrun = 'end',
   transitionOffset = vec(-2.6, 0.4),
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
999999999w _P_12_5 w____________
999999999( _T_34__ (____________
888888888)  d  s   )____________
777777777fffffffffffffffffffffff
666666666FFFFFFFFFFFFFFFFFFFFFFF
666666666FFFFFFFFFFFFFFFFFFFFFFF
666666666FFFFFFFFFFFFFFFFFFFFFFF
666666666FFFFFFFFFFFFFFFFFFFFFFF
]],
   tick = function(time)
      tiles['T'].uv = vec(6, 4 + 3)
      local player = levelEntities.player
      if time == 1 then
         player.pos = player.pos - vec(0, 1)
      end
      if time < 20 then
         player.hide = true
      elseif time < 38 then
         player.hide = false
         player.vel.x = 0.22
         if time == 20 or time == 35 then
            player.vel.y = 0.5
         end
      elseif time > 41 then
         local y = player.pos.y
         player.pos.y = math.floor(y) + 0.5
         if time == 42 then
            player.vel = vec(-0.02, 0)
         else
            player.vel = vec(0, 0)
         end
      end
      if time == 60 then
         setLevel(#levels, 'thanksForPlaying')
      end
   end
},
{ -- thanks for playing room
theme = 'void',
cameraOffset = vec(0, 2),
transitionOffset = vec(0, 2),
zoom = 10,
noInput = true,
world = [[
fff
fPf
fff
]],
tick = function(t)
   if t == 100 then setLevel(1, 'mainMenu') end
end
},
}

-- function events.entity_init() setLevel(#levels - 3) end -- debug

return levels