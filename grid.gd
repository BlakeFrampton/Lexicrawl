extends Node

var boardTiles = []
var TILESIZE = Globals.get_tileSize()
var TILEBORDER = Globals.get_tileBorder()
const GRIDSIZE = 15
const STANDARDBOARDCOLOUR = Color(0xFFe2AEFF)
const TRIPLEWORDCOLOUR = Color(0xd95258FF)
const DOUBLEWORDCOLOUR = Color(0xe79ea9FF)
const DOUBLELETTERCOLOUR = Color(0xa2cceeFF)
const TRIPLELETTERCOLOUR = Color(0x0185c6FF)


func _ready():
	var board_tile = preload("res://board_tile.tscn")
	var startingX = (DisplayServer.screen_get_size().x - GRIDSIZE * (TILESIZE + TILEBORDER)) / 2 
	var startingY = (DisplayServer.screen_get_size().y - (GRIDSIZE + 4) * (TILESIZE + TILEBORDER)) / 2 
	for x in range(GRIDSIZE):
		boardTiles.append([]) 
		for y in range(GRIDSIZE):
			boardTiles[x].append(0) # Set a starter value for each position
			boardTiles[x][y] = board_tile.instantiate()
			boardTiles[x][y].get_node("ColorRect").position=Vector2(startingX + x * (TILESIZE + TILEBORDER), startingY + y * (TILESIZE + TILEBORDER))
			boardTiles[x][y].get_node("ColorRect").size = Vector2(TILESIZE, TILESIZE)
			boardTiles[x][y].get_node("ColorRect").color = setBoardTileColour(boardTiles, x, y)

			add_child(boardTiles[x][y])


func setBoardTileColour(boardTiles, x, y):
	if (min(x, y) == 0 and max(x,y) == 3) or (min(x, y) == 0 and max(x,y) == 11) or (min(x, y) == 3 and max(x,y) == 14) or (min(x, y) == 11 and max(x,y) == 14): #outer ring
		boardTiles[x][y].tileType = "2L"
		return DOUBLELETTERCOLOUR
	if (x + y == 12 or x + y == 14 or x + y == 16) and (x == 6 or x == 8) and (y == 6 or y == 8): #inner ring
		return DOUBLELETTERCOLOUR
		boardTiles[x][y].tileType = "2L"
	if (x == 2 and (y == 6 or y == 8) or x == 3 and y == 7 or x == 6 and (y == 2 or y == 12) or x == 7 and (y == 3 or y == 11) or x == 8 and (y == 2 or y == 12) or x == 11 and y == 7 or x == 12 and (y == 6 or y==8)):
		return DOUBLELETTERCOLOUR
		boardTiles[x][y].tileType = "2L"
	if (x == 1 or x == 5 or x == 9 or x == 13) and (y == 1 or y == 5 or y == 9 or y == 13):
		if !((x + y == 14 or x + y == 2 or x + y == 26) and (x == 1 or x == 14)):
			return TRIPLELETTERCOLOUR
			boardTiles[x][y].tileType = "3L"
	if y == 0 or y == 7 or y == 14:
		if x == 0 or (x == 7 and y != 7) or x == 14:
			return TRIPLEWORDCOLOUR
			boardTiles[x][y].tileType = "3W"
	if x == y or (14-x) == y:
		return DOUBLEWORDCOLOUR
		boardTiles[x][y].tileType = "2W"
	return STANDARDBOARDCOLOUR
