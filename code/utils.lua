local utils = {}

-- cube
utils.emptyCube = models.model.emptyCube
models.model:removeChild(utils.emptyCube)
utils.emptyCube:light(15, 15)

return utils