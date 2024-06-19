local themes = {}

themes.house = {
   defaultTile = 'w',
   backgroundColor = vectors.hexToRGB('0069aa'),
   tileset = vec(0, 0),
}

themes.tv = {
   tileset = vec(0, 1),
   backgroundTexture = textures.tvBg,
   backgroundColor = vec(0.5, 0.5, 0.5),
   light = 0.75,
   defaultTile = ' ',
}

return themes