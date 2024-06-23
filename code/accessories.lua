local accessories = {}
local entities = require('code.entities')
local currentAccessories = config:load('accessories')
if type(currentAccessories) ~= 'table' then currentAccessories = {} end

function accessories.save()
   config:save('accessories', currentAccessories)
end

function accessories.setEnabled(id, x)
   currentAccessories[id] = x and true or nil
   accessories.save()
end

function accessories.getEnabled(id)
   return currentAccessories[id] and true or false
end

function accessories.give()
   for i in pairs(currentAccessories) do
      entities.addItem(i)
   end
end

return accessories