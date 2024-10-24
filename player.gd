extends Node
var rack = []
var TILESIZE = Globals.get_tileSize()
var TILEBORDER = Globals.get_tileBorder()
var handSize = 7
var tileBag

func _init():
		tileBag = load("res://tile_bag.tscn").instantiate()

func _ready():
	var startingY = 9 * (DisplayServer.screen_get_size().y) / 10 - TILESIZE
	var startingX = (DisplayServer.screen_get_size().x - handSize * (TILESIZE + TILEBORDER)) / 2

	for i in range(7):
		var next_tile = tileBag.get_tile()
		add_child(next_tile)
		next_tile.position = Vector2(startingX + i * (TILESIZE + TILEBORDER), startingY)
		rack.append(next_tile)
