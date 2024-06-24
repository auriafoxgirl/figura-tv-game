local gnui = require("libraries.gnui")
local levels = require('code.levels')
local progress = require('code.progress')
local dialog = require('code.dialog')
local items = require('code.items')
local accessories = require('code.accessories')

-- variables and stuff
uiScreen = nil
local clickedElement = nil
local canvas = gnui.getScreenCanvas()
canvas:setZ(160) -- multiplied by clipping margin (0.05), 8 / 0.05
-- mouse clicking cancelling
local click = keybinds:newKeybind("screenui", "key.mouse.left")
click.press = function()
   if gameHidden then return end
   if host:getScreen() and not host:isChatOpen() and not uiScreen then return end
   return true
end
-- pausing game
local pause = keybinds:newKeybind('pause game', 'key.keyboard.escape', true)
pause.press = function()
   if gameHidden then return end
   if host:getScreen() then return end
   if uiScreen then return end
   gamePaused = true
   setUIScreen('pause')
   return true
end

-- dialog
local dialogScreen = gnui:newContainer()
canvas:addChild(dialogScreen)
dialogScreen:setAnchor(0, 0, 1, 0)
            :setDimensions(4, 4, -4, 48)
            :setCanCaptureCursor(false)
            :setVisible(false)
local dialogLabel = gnui:newLabel()
dialogScreen:addChild(dialogLabel)
dialogLabel:setText('')
           :setFontScale(1.5)
           :setDimensions(10, 10)
do
   local sprite = gnui:newSprite()
   sprite:setTexture(textures.ui)
         :setUV(1, 19, 5, 23)
         :setBorderThickness(2, 2, 2, 2)
         :setScale(2)
   dialogScreen:setSprite(sprite)
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
   return button, label
end

do
   local screen = gnui:newContainer():setAnchor(0, 0, 1, 1)
   screens.mainMenu = {screen = screen}
   screen:addChild(
      createButton('play', vec(118, 18), vec(8, -40),
      function()
         if progress.getProgress() == 0 then
            setLevel(2)
         else
            setUIScreen('levels')
         end
      end
   ):setAnchor(0, 0.5))
   screen:addChild(
      createButton('info', vec(118, 18), vec(8, -20),
      function()
         setUIScreen('info')
      end
   ):setAnchor(0, 0.5))
   screen:addChild(
      createButton('settings', vec(118, 18), vec(8, 0),
      function()
         setUIScreen('settings')
      end
   ):setAnchor(0, 0.5))
   screen:addChild(
      createButton('quit game', vec(118, 18), vec(8, 20),
      function()
         gameHidden = true
         local key = keybinds:getVanillaKey('figura.config.action_wheel_button'):gsub('^key%.keyboard%.', '')
         print('press '..key..' to show game')
      end
   ):setAnchor(0, 0.5))
   local label = gnui:newLabel()
   screen:addChild(label)
   label:setText({text = 'Fix the\nTV static!', color = '#000000'})
        :setCanCaptureCursor(false)
        :setFontScale(2)
        :setDimensions(4, 4)
end

do
   local screen = gnui:newContainer():setAnchor(0, 0, 1, 1)
   local levelScreen = nil
   local function rebuild()
      if levelScreen then screen:removeChild(levelScreen) end
      levelScreen = gnui:newContainer():setAnchor(0, 0.5, 1, 1.5)
      screen:addChild(levelScreen)
      levelScreen:addChild((
         createButton('prologue', vec(118, 18), vec(0, 4),
         function()
            setLevel(2)
         end
      )))
      local x, y = 0, 1
      local maxLevel = progress.getProgress()
      for i = 3, #levels - 3 do
         if x >= 5 then
            x = 0
            y = y + 1
         end
         local isLocked = i > maxLevel -- change this later
         levelScreen:addChild((
            createButton(tostring(i - 2), vec(22, 22), vec(x * 24, y * 24),
            function()
               setLevel(i)
            end,
            isLocked and vec(0, 12) or vec(0, 0), -- uv
            isLocked, -- locked
            vec(0.5, 0.5),
            isLocked and '#92a1b9' -- text color
         )))
         x = x + 1
      end
      local isLocked = #levels - 2 > maxLevel
      levelScreen:addChild((
         createButton('signal room', vec(118, 18), vec(0, (y + 1) * 24),
         function()
            setLevel(#levels - 2)
         end,
         isLocked and vec(0, 12) or vec(0, 0), -- uv
         isLocked, -- locked
         vec(0.5, 0.5),
         isLocked and '#92a1b9' -- text color
      )))
      y = y + 1
      levelScreen:addChild((
         createButton('back', vec(118, 18), vec(0, (y + 1) * 24 - 2),
         function()
            setUIScreen('mainMenu')
         end
      )))
      levelScreen:setDimensions(vec(8, (y + 1) * -12 - 8).xyxy)
   end
   screens.levels = {screen = screen, func = rebuild}
end

do
   local screen = gnui:newContainer():setAnchor(0, 0.5, 1, 1.5)
   local y = 0
   local buttons = {}
   local update
   for id, v in pairs(items) do
      if v.accessory then
         local button, label = createButton(id, vec(118, 18), vec(0, y * 20),
            function()
               accessories.setEnabled(id, not accessories.getEnabled(id))
               update()
            end
         )
         screen:addChild(button)
         table.insert(buttons, {
            label = label,
            name = id,
         })
         y = y + 1
      end
   end
   screen:addChild((
      createButton('back', vec(118, 18), vec(0, y * 20),
      function()
         setUIScreen('mainMenu')
      end
   )))
   y = y + 1
   screen:setDimensions(vec(8, y * -10).xyxy)
   function update()
      for _, v in pairs(buttons) do
         v.label:setText(
            (accessories.getEnabled(v.name) and 'on ' or 'off')..
            ' | '..
            v.name
         )
      end
   end
   screens.settings = {screen = screen, func = update}
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

do
   local screen = gnui:newContainer():setAnchor(0, 0, 1, 1)
   screens.pause = {screen = screen}
   screen:addChild(
      createButton('back to game', vec(128, 18), vec(-64, -20),
      function()
         gamePaused = false
         setUIScreen()
      end
   ):setAnchor(0.5, 0.5))
   screen:addChild(
      createButton('back to main menu', vec(128, 18), vec(-64, 2),
      function()
         setLevel(1, 'mainMenu')
      end
   ):setAnchor(0.5, 0.5))
end

do
   local screen = gnui:newContainer():setAnchor(0, 0, 1, 1)
   screens.thanksForPlaying = {screen = screen}
   local label = gnui:newLabel()
   screen:addChild(label)
   label:setAlign(0.5, 0.5)
        :setAnchor(0.5, 0.5)
        :setText('Thanks for\nplaying')
        :setFontScale(4)
end

-- magic
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
      local mousePos = client:getMousePos() / client:getGuiScale()
      canvas:setMousePos(mousePos.x, mousePos.y, true)
   else
      uiScreen = nil
   end
end
setUIScreen('mainMenu')

events.WORLD_RENDER:register(function()
   if gameHidden then
      host:setUnlockCursor(false)
      clickedElement = nil
      canvas:setCanCaptureCursor(false)
      canvas:setVisible(false)
      return
   end
   canvas:setVisible(true)

   if dialog.text ~= '' then
      dialogScreen:setVisible(true)
      dialogLabel:setText(dialog.text)
   else
      dialogScreen:setVisible(false)
   end

   if not uiScreen then
      host:setUnlockCursor(false)
      clickedElement = nil
      canvas:setCanCaptureCursor(false)
      if currentContainer then currentContainer:setVisible(false) end
      return
   elseif host:getScreen() and not host:isChatOpen() then
      currentContainer:setCanCaptureCursor(false)
      return
   end
   host:setUnlockCursor(true)
   canvas:setCanCaptureCursor(true)
   currentContainer:setCanCaptureCursor(true)
   currentContainer:setVisible(true)
end)

events.MOUSE_MOVE:register(function()
   if gameHidden or uiScreen then return end
   return true
end)