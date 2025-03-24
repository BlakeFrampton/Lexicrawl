extends Node2D

var boardPath = preload("res://board.tscn")

var TILESIZE = null
var TILEBORDER = null
var GRIDSIZE = null

var board = null
var player = null
var playersTurn = true
var exchanging = false


func set_values(tileSize: int, tileBorder: int, gridSize: int, passedPlayer: Object):
	TILESIZE = tileSize
	TILEBORDER = tileBorder
	GRIDSIZE = gridSize
	player = passedPlayer

func initialise():
	initialise_board()
	update_player_rack()
	
	game_turn()

func initialise_board():
	board = boardPath.instantiate()
	board.set_values(TILESIZE, TILEBORDER, GRIDSIZE, player.get_racksize())
	board.initialise()
	add_child(board)
	get_node("Board").get_node("Grid").playMade.connect(play_made)

func update_player_rack(tilesUsed = []):
	player.use_tiles(tilesUsed)
	player.draw_tiles()
	var playerRack = player.get_rack()
	board.show_player_rack(playerRack)

func game_turn():
	if !playersTurn:
		#Run enemy turn
		playersTurn = true
		return
	return


func play_made(wordsToScore, tilesUsed):
	print(wordsToScore)
	if (playersTurn):
		update_player_rack(tilesUsed)
		resolve_scores()
	playersTurn = false
	game_turn()
	
func resolve_scores():
	#Cancel out damage then deal 
	return




func _on_submit_button_pressed():
	board.get_node("Grid").submit_play()


func _on_exchange_button_pressed():
	if !exchanging:
		exchanging = true
		player.exchange_start()
	else:
		exchanging = false
		player.exchange_tiles()
		update_player_rack()
