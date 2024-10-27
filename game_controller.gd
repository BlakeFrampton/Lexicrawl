extends Node

var TILESIZE = Globals.get_tileSize()
var TILEBORDER = Globals.get_tileBorder()

func _ready():
	add_child(load("res://board.tscn").instantiate())
	add_child(load("res://player.tscn").instantiate())


func _on_button_pressed():
	get_node("Board").get_node("Grid").submit_play()
