local keys = {
   left = keybinds:fromVanilla('key.left'),
   right = keybinds:fromVanilla('key.right'),
   up = keybinds:fromVanilla('key.forward'),
   down = keybinds:fromVanilla('key.back'),
}

for _, v in pairs(keys) do
   v.press = function() return not gameHidden end
end

return keys