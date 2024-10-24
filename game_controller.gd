extends Node

var TILESIZE = Globals.get_tileSize()
var TILEBORDER = Globals.get_tileBorder()

func _ready():
	add_child(load("res://board.tscn").instantiate())
	add_child(load("res://player.tscn").instantiate())
