extends Node

var Tiles = []

func _init():
	add_standard_tiles()

func add_tiles(value, quantity):
	for i in range(quantity):
		Tiles.append(value)
	
func add_standard_tiles():
	add_tiles("A", 9)
	add_tiles("B", 2)
	add_tiles("C", 2)
	add_tiles("D", 4)
	add_tiles("E", 12)
	add_tiles("F", 2)
	add_tiles("G", 3)
	add_tiles("H", 2)
	add_tiles("I", 9)
	add_tiles("J", 1)
	add_tiles("K", 1)
	add_tiles("L", 4)
	add_tiles("M", 2)
	add_tiles("N", 6)
	add_tiles("O", 8)
	add_tiles("P", 2)
	add_tiles("Q", 1)
	add_tiles("R", 6)
	add_tiles("S", 4)
	add_tiles("T", 6)
	add_tiles("U", 4)
	add_tiles("V", 2)
	add_tiles("W", 2)
	add_tiles("X", 1)
	add_tiles("Y", 2)
	add_tiles("Z", 1)
	add_tiles(" ", 2)

func get_tile():
	var rnd = RandomNumberGenerator.new()
	randomize()
	var index = rnd.randi_range(0, len(Tiles) - 1)
	var tileValue = Tiles[index]
	Tiles.remove_at(index)
	
	var letter_tile = load("res://letter_tile.tscn").instantiate()
	letter_tile.set_value(tileValue)
	return letter_tile
