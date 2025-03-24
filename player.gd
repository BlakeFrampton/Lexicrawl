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
	return rack

func draw_tiles():
	for i in range(rackSize - len(rack)):
		var next_tile = tileBag.get_tile()
		rack.append(next_tile)

func use_tiles(tilesUsed):
	for tile in tilesUsed:
		rack.erase(tile)

func exchange_start():
	for tile in rack:
		tile.set_exchanging(true)
		
func exchange_tiles():
	print(rack)
	for tile in rack:
		print(tile.get_label())
		if tile.get_exchange_this_tile():
			rack.erase(tile)
			tile.queue_free()
		else:
			tile.set_exchanging(false)
