extends Node2D

var boardPath = preload("res://board.tscn")

var TILESIZE = null
var TILEBORDER = null
var GRIDSIZE = null

var board = null
var player = null
var playersTurn = false


func set_values(tileSize: int, tileBorder: int, gridSize: int, passedPlayer: Object):
	TILESIZE = tileSize
	TILEBORDER = tileBorder
	GRIDSIZE = gridSize
	player = passedPlayer

func initialise():
	board = boardPath.instantiate()
	board.set_values(TILESIZE, TILEBORDER, GRIDSIZE, player.get_racksize())
	board.initialise()
	add_child(board)
	get_node("Board").get_node("Grid").playMade.connect(play_made)
	
	game_turn()


func game_turn():
	var playerRack = player.get_rack()
	board.set_player_rack(playerRack)

func play_made(wordsToScore):
	print(wordsToScore)
