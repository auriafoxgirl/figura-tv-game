local gnui = require("libraries.gnui")
local levels = require('levels')
local progress = require('progress')

-- variables and stuff
uiScreen = nil
local clickedElement = nil
-- mouse clicking cancelling
local click = keybinds:newKeybind("screenui", "key.mouse.left")
click.press = function()
   if gamePaused then return end
   if host:getScreen() and not host:isChatOpen() and not uiScreen then return end
   return true
end

-- ui screens
local screens = {}
local function createButton(text, size, pos, func, uvOffset, locked, textAlign, textColor)
   uvOffset = uvOffset or vec(0, 0)
   local buttonSize = size.__xy + (pos.xyxy or vec(0, 0, 0, 0))

   local button = gnui:newContainer()
   local buttonBg = gnui:newContainer()
   button:setDimensions(buttonSize)

   local sprite = gnui:newSprite()
   sprite:setTexture(textures.ui)
         :setUV(1, 1, 5, 5)
         :setBorderThickness(2, 2, 2, 2)
         :setScale(2)

   button:addChild(buttonBg)
   buttonBg:setSprite(sprite)
           :setCanCaptureCursor(false)

   local label = gnui:newLabel()
   buttonBg:addChild(label)
   label:setText({text = text, color = textColor or '#ffffff'})
        :setCanCaptureCursor(false)
        :setDimensions(4, 4, size.x - 4, size.y - 6)
   if textAlign then label:setAlign(textAlign.x, textAlign.y) end

   local function updateButton()
      local pressed = false
      if button.isCursorHovering then
         if clickedElement == button then
            pressed = true
            sprite:setUV(vec(13, 2, 17, 5) + uvOffset.xyxy)
         else
            sprite:setUV(vec(7, 1, 11, 5) + uvOffset.xyxy)
         end
      else
         sprite:setUV(vec(1, 1, 5, 5) + uvOffset.xyxy)
      end
      if pressed then
         buttonBg:setDimensions(size.__xy + vec(0, 2, 0, 0))
      else
         buttonBg:setDimensions(size.__xy)
      end
   end
   updateButton()
   button.MOUSE_ENTERED:register(function()
      updateButton()
   end)
   button.MOUSE_EXITED:register(function()
      if clickedElement == button then clickedElement = nil end
      updateButton()
   end)
   button.INPUT:register(function(event)
      if event.key ~= "key.mouse.left" then return end
      if event.isPressed then
         if not locked then
            clickedElement = button
         end
      elseif clickedElement == button then
         if func then func() end
         clickedElement = nil
      end
      updateButton()
   end)
   return button
end

do
   local screen = gnui:newContainer():setAnchor(0, 0, 1, 1)
   screens.mainMenu = {screen = screen}
   screen:addChild(
      createButton('play', vec(128, 18), vec(8, -11),
      function()
         if progress.getProgress() == 0 then
            setLevel(2)
         else
            setUIScreen('levels')
         end
      end
   ):setAnchor(0, 0.5))
   screen:addChild(
      createButton('info', vec(128, 18), vec(8, 11),
      function()
         setUIScreen('info')
      end
   ):setAnchor(0, 0.5))
end

do
   local screen = gnui:newContainer():setAnchor(0, 0, 1, 1)
   local levelScreen = nil
   local function rebuild()
      if levelScreen then screen:removeChild(levelScreen) end
      levelScreen = gnui:newContainer():setAnchor(0, 0.5, 1, 1.5)
      screen:addChild(levelScreen)
      levelScreen:addChild(
         createButton('prologue', vec(118, 18), vec(0, 4),
         function()
            setLevel(2)
         end
      ))
      local x, y = 0, 1
      local maxLevel = progress.getProgress()
      for i = 3, #levels do
         if x >= 5 then
            x = 0
            y = y + 1
         end
         local isLocked = i > maxLevel -- change this later
         levelScreen:addChild(
            createButton(tostring(i - 2), vec(22, 22), vec(x * 24, y * 24),
            function()
               setLevel(i)
            end,
            isLocked and vec(0, 12) or vec(0, 0), -- uv
            isLocked, -- locked
            vec(0.5, 0.5),
            isLocked and '#92a1b9' -- text color
         ))
         x = x + 1
      end
      levelScreen:addChild(
         createButton('back', vec(118, 18), vec(0, (y + 1) * 24 + 2),
         function()
            setUIScreen('mainMenu')
         end
      ))
      levelScreen:setDimensions(vec(8, (y + 1) * -12 - 8).xyxy)
   end
   screens.levels = {screen = screen, func = rebuild}
end

do
   local screen = gnui:newContainer():setAnchor(0, 0, 1, 1)
   screens.info = {screen = screen}
   screen:addChild(
      createButton(
         'Fix the tv static!\nPlatformer 2d game made\nin figura where you try\nto fix the tv static\n\nMade for avatar contest\n\nMade by:\nAuriafoxgirl\n\nLibraries:\nGNUI - GNamimates',
         vec(134, 104),
         vec(8, -72),
         nil,
         vec(0, 6),
         true
      ):setAnchor(0, 0.5)
   )
   screen:addChild(
      createButton('back', vec(134, 18), vec(8, 36),
      function()
         setUIScreen('mainMenu')
      end
   ):setAnchor(0, 0.5))
end

-- magic
local canvas = gnui.createScreenCanvas()
canvas:setZ(16)

local currentContainer
function setUIScreen(menu)
   if currentContainer then
      canvas:removeChild(currentContainer)
      currentContainer = nil
   end
   if screens[menu] then
      uiScreen = menu
      currentContainer = screens[menu].screen
      canvas:addChild(currentContainer)
      if screens[menu].func then screens[menu].func() end
   else
      uiScreen = nil
   end
end
setUIScreen('mainMenu')

events.WORLD_RENDER:register(function()
   if gamePaused or not uiScreen then
      host:setUnlockCursor(false)
      canvas:setVisible(false)
      clickedElement = nil
      return
   end
   host:setUnlockCursor(true)
   canvas:setVisible(true)
end)

events.MOUSE_MOVE:register(function()
   if gamePaused or uiScreen then return end
   return true
end)