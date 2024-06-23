local themes = {}

themes.house = {
   defaultTile = 'w',
   backgroundColor = vectors.hexToRGB('0069aa'),
   tileset = vec(0, 0),
}

themes.tv = {
   tileset = vec(0, 1),
   backgroundTexture = textures.tvBg,
   light = 0.75,
   defaultTile = ' ',
}

themes.void = {
   defaultTile = 'w',
   backgroundColor = vec(0, 0, 0),
   light = 0
}

return themes