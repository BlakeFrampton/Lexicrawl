extends Node2D

const BACKGROUNDCOLOUR = "White"
var TILESIZE = null
var TILEBORDER = null
var GRIDSIZE = null

var playerRackSize = null
var playerRack = null

func set_values(tileSize: int, tileBorder: int, gridSize: int, playerRackSize: int):
	TILESIZE = tileSize
	TILEBORDER = tileBorder
	GRIDSIZE = gridSize
	self.playerRackSize = playerRackSize

func initialise():
	initialise_grid()
	
	var startingX = (DisplayServer.screen_get_size().x - GRIDSIZE * (TILESIZE + TILEBORDER)) / 2 
	var startingY = (DisplayServer.screen_get_size().y - (GRIDSIZE + 4) * (TILESIZE + TILEBORDER)) / 2 
	var backgroundRect = ColorRect.new()
	backgroundRect.position = Vector2(startingX,startingY)
	backgroundRect.size = Vector2(GRIDSIZE * (TILESIZE + TILEBORDER), GRIDSIZE * (TILESIZE + TILEBORDER))
	backgroundRect.color = Color(BACKGROUNDCOLOUR)
	add_child(backgroundRect) #Add background to Board, so grid only contains playable squares

func initialise_grid():
	var Grid = get_node("Grid")
	Grid.set_values(TILESIZE, TILEBORDER, GRIDSIZE)
	Grid.set_word_list("res://CSW24.txt")
	Grid.initialise()

func set_player_rack(playerRack):
	self.playerRack = playerRack
	var startingY = 9 * (DisplayServer.screen_get_size().y) / 10 - TILESIZE
	var startingX = (DisplayServer.screen_get_size().x - playerRackSize * (TILESIZE + TILEBORDER)) / 2
	for i in range(playerRackSize):
		var tile = self.playerRack[i]
		add_child(tile)
		tile.position = Vector2(startingX + i * (TILESIZE + TILEBORDER), startingY)
