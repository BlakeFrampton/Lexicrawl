extends Node

var TILESIZE = null
var TILEBORDER = null
var TILEBAG = preload("res://tile_bag.tscn")

var rack = []
var rackSize = 7
var tileBag
	
func set_values(tileSize: int, tileBorder: int):
	TILESIZE = tileSize
	TILEBORDER = tileBorder

func _ready():
	tileBag = TILEBAG.instantiate()
	tileBag.set_values(TILESIZE)
	add_child(tileBag)

func get_racksize():
	return rackSize

func get_rack():
	for i in range(7):
		var next_tile = tileBag.get_tile()
		rack.append(next_tile)
	
	return rack
