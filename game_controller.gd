extends Node

var battlePath = preload("res://battle.tscn")
var playerPath = preload("res://player.tscn")

const TILESIZE = 64
const TILEBORDER = 2
const GRIDSIZE = 15
var draggingSomething = false
var player = null
var battle = null

func get_draggingSomething():
	return draggingSomething
	
func set_draggingSomething(x):
	draggingSomething = x

func _ready():
	spawn_player()
	spawn_battle()
	#spawn_map(), etc.


func _on_button_pressed():
	battle.get_node("Board").get_node("Grid").submit_play()

func spawn_player():
	player = playerPath.instantiate()
	player.set_values(TILESIZE, TILEBORDER)
	add_child(player)

func spawn_battle():
	battle = battlePath.instantiate()
	battle.set_values(TILESIZE, TILEBORDER, GRIDSIZE, player)
	battle.initialise()
	add_child(battle)
