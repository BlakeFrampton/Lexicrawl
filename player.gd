extends Node

var TILESIZE = null
var TILEBORDER = null
var TILEBAG = preload("res://tile_bag.tscn")

var rack = []
var rackSize = 7
var tileBag
var dragging = false
	
func set_values(tileSize: int, tileBorder: int):
	TILESIZE = tileSize
	TILEBORDER = tileBorder

func _ready():
	tileBag = TILEBAG.instantiate()
	tileBag.set_values(TILESIZE, self)
	add_child(tileBag)

func get_racksize():
	return rackSize

func get_rack():
	return rack

func draw_tiles():
	for i in range(rackSize - len(rack)):
		var next_tile = tileBag.get_tile()
		if next_tile:
			rack.append(next_tile)
		else:
			print("Uh oh no more tiles")

func use_tiles(tilesUsed):
	for tile in tilesUsed:
		rack.erase(tile)

func exchange_start():
	for tile in rack:
		tile.set_exchanging(true)
		
func exchange_tiles():
	var tilesToExchange = []
	for tile in rack:
		print("Tile: ", tile.get_label(), " Exchange: ", tile.get_exchange_this_tile())
		if tile.get_exchange_this_tile():
			tilesToExchange.append(tile)
		else:
			tile.set_exchanging(false)
	for tile in tilesToExchange:
		rack.erase(tile)
		tile.queue_free()
		
func set_dragging(value):
	dragging = value

func get_dragging():
	return dragging
