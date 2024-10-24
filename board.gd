extends Node2D
var TILESIZE = Globals.get_tileSize()
var TILEBORDER = Globals.get_tileBorder()
var GRIDSIZE = Globals.get_gridSize()
const BACKGROUNDCOLOUR = "White"

func _ready():
	var startingX = (DisplayServer.screen_get_size().x - GRIDSIZE * (TILESIZE + TILEBORDER)) / 2 
	var startingY = (DisplayServer.screen_get_size().y - (GRIDSIZE + 4) * (TILESIZE + TILEBORDER)) / 2 
	var backgroundRect = ColorRect.new()
	backgroundRect.position = Vector2(startingX,startingY)
	backgroundRect.size = Vector2(GRIDSIZE * (TILESIZE + TILEBORDER), GRIDSIZE * (TILESIZE + TILEBORDER))
	backgroundRect.color = Color(BACKGROUNDCOLOUR)
	add_child(backgroundRect) #Add background to Board, so grid only contains playable squares
