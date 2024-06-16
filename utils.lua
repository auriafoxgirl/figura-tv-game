local utils = {}

local table2d = {
   __index = function(t, i)
      t[i] = {}
      return rawget(t, i)
   end
}

-- function utils.table2d()
--    return setmetatable({}, table2d)
-- end

return utils