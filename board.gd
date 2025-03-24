extends Node2D

const BACKGROUNDCOLOUR = "#0f716e"
const INTERTILECOLOUR = "white"
var TILESIZE = null
var TILEBORDER = null
var GRIDSIZE = null
var GRIDBORDER = 20

var playerRackSize = null
var playerRack = null

func set_values(tileSize: int, tileBorder: int, gridSize: int, playerRackSize: int):
	TILESIZE = tileSize
	TILEBORDER = tileBorder
	GRIDSIZE = gridSize
	self.playerRackSize = playerRackSize

func initialise():
	initialise_grid()
	create_background()

func initialise_grid():
	var Grid = get_node("Grid")
	Grid.set_values(TILESIZE, TILEBORDER, GRIDSIZE)
	Grid.set_word_list("res://CSW24.txt")
	Grid.initialise()

func create_background():
	var startingX = (DisplayServer.screen_get_size().x - GRIDSIZE * (TILESIZE + TILEBORDER)) / 2 
	var startingY = (DisplayServer.screen_get_size().y - (GRIDSIZE + 4) * (TILESIZE + TILEBORDER)) / 2 
	var backgroundRect = ColorRect.new()
	backgroundRect.position = Vector2(startingX- GRIDBORDER,startingY- GRIDBORDER)
	backgroundRect.size = Vector2(GRIDSIZE * (TILESIZE + TILEBORDER) + 2 * GRIDBORDER, GRIDSIZE * (TILESIZE + TILEBORDER) + 2 * GRIDBORDER)
	backgroundRect.color = Color(BACKGROUNDCOLOUR)
	add_child(backgroundRect) #Add background to Board, so grid only contains playable squares
	
	var interTileBackground = ColorRect.new()
	interTileBackground.position = Vector2(startingX-1,startingY-1)
	interTileBackground.size = Vector2(GRIDSIZE * (TILESIZE + TILEBORDER), GRIDSIZE * (TILESIZE + TILEBORDER))
	interTileBackground.color = Color(INTERTILECOLOUR)
	add_child(interTileBackground)

func show_player_rack(playerRack):
	self.playerRack = playerRack
	var startingY = 9 * (DisplayServer.screen_get_size().y) / 10 - TILESIZE
	var startingX = (DisplayServer.screen_get_size().x - playerRackSize * (TILESIZE + TILEBORDER)) / 2
	for i in range(len(playerRack)):
		var tile = self.playerRack[i]
		if tile.get_parent() != self:
			add_child(tile)
		tile.position = Vector2(startingX + i * (TILESIZE + TILEBORDER), startingY)

