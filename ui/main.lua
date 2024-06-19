local gnui = require("libraries.gnui")

-- mouse
local updateMouse = false
local click = keybinds:newKeybind("screenui", "key.mouse.left", true)
local canClick = 0
click.press = function()
   if gamePaused then return end
   if host:getScreen() and not host:isChatOpen() then return end
   updateMouse = true
   canClick = 4
   return true
end
click.release = click.press
local clickedElement = nil

-- ui screens
local screens = {}
local function createButton(text, size, pos, func)
   local button = gnui:newContainer()
   local buttonSize = size + (pos.xyxy or vec(0, 0, 0, 0))
   local sprite = gnui:newSprite()
   sprite:setTexture(textures.ui)
         :setUV(1, 1, 5, 5)
         :setBorderThickness(2, 2, 2, 2)
         :setScale(2)
   button:setSprite(sprite)
   local label = gnui:newLabel()
   label:setText(text)
        :setCanCaptureCursor(false)
        :setDimensions(4, 4, 124, 12)
   button:addChild(label)
   local function updateButton()
      local pressed = false
      if button.Hovering then
         if click:isPressed() and clickedElement == button then
            pressed = true
            sprite:setUV(13, 2, 17, 5)
         else
            sprite:setUV(7, 1, 11, 5)
            if canClick >= 1 and clickedElement == button and func then
               canClick = 0
               func()
            end
         end
      else
         sprite:setUV(1, 1, 5, 5)
      end
      if pressed then
         button:setDimensions(buttonSize + vec(0, 2, 0, 0))
      else
         button:setDimensions(buttonSize)
      end
   end
   updateButton()
   button.PRESSED:register(function()
      if canClick >= 1 then
         clickedElement = button
         canClick = 0
      end
   end)
   button.MOUSE_EXITED:register(function()
      updateButton()
      if clickedElement == button then clickedElement = nil end
   end)
   button.CURSOR_CHANGED:register(function()
      updateButton()
   end)
   return button
end

do
   local screen = gnui.newContainer()
   screen:setAnchor(0, 0, 1, 1)
   screen:addChild(createButton('hello', vec(0, 0, 128, 18), vec(8, 0)):setAnchor(0, 0.5))
   
   screens.mainMenu = screen
end

-- magic
local screen = gnui.newContainer()
local uiModelPart = models.model.Hud:newPart('ui')
uiModelPart:setPos(0, 0, -4)
uiModelPart:addChild(screen.ModelPart)
-- uiModelPart:setScale(0.5, 0.5, 0.5):pos(-196, -64)

uiScreen = nil
local currentContainer
function setUIScreen(menu)
   if currentContainer then
      screen:removeChild(currentContainer)
      currentContainer = nil
   end
   if screens[menu] then
      uiScreen = screen
      currentContainer = screens[menu]
      screen:addChild(currentContainer)
   else
      uiScreen = nil
   end
end
setUIScreen('mainMenu')

local screen_size = vectors.vec2(0,0)
events.TICK:register(function (delta)
   if gamePaused or not uiScreen then
      updateMouse = true
      host:setUnlockCursor(false)
      canClick = 0
      return
   end
   canClick = math.max(canClick -1, 0)
   host:setUnlockCursor(true)
   local new_screen_size = client:getScaledWindowSize()
   if screen_size ~= new_screen_size then
      screen_size = new_screen_size
      screen:setBottomRight(new_screen_size)
   end
   if updateMouse then
      updateMouse = false
      local pos = client:getMousePos() / client:getGuiScale()
      screen:setCursor(pos.x, pos.y, click:isPressed())
   end
end)

events.MOUSE_MOVE:register(function()
   updateMouse = true
end)