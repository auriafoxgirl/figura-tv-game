local dialog = {text = ''}
local dialogText = ''
local dialogTime = 0
local dialogTimeout = 0

function dialog.set(text, timeout)
   dialogTimeout = timeout or 4
   if dialogText ~= text then
      dialogTime = 0
      dialogText = text
   end
end

function events.tick()
   dialogTimeout = math.max(dialogTimeout - 1, 0)
   if dialogTimeout == 0 then
      dialogText = ''
   end
   dialogTime = math.min(dialogTime + 1, #dialogText)
   dialog.text = dialogText:sub(1, dialogTime)
end

return dialog