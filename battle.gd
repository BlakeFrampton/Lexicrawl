extends Node2D

var BOARD = preload("res://board.tscn")
var ENEMY = preload("res://enemy.tscn")

var TILESIZE = null
var TILEBORDER = null
var GRIDSIZE = null

var playScorer
var playFinder
var board
var player
var enemy
var playersTurn = true
var exchanging = false



func set_values(tileSize: int, tileBorder: int, gridSize: int, passedPlayer: Object):
	TILESIZE = tileSize
	TILEBORDER = tileBorder
	GRIDSIZE = gridSize
	player = passedPlayer

func _ready():
	playScorer = get_node("/root/playScorer")
	playFinder = get_node("/root/playFinder")
	print("playScorer: ", playScorer)
	initialise_board()
	update_player_rack()
	initialise_enemy()
	

func initialise_board():
	board = BOARD.instantiate()
	board.set_values(TILESIZE, TILEBORDER, GRIDSIZE, player.get_racksize())
	board.initialise()
	add_child(board)
	board.get_node("Grid").playMade.connect(play_made)

func update_player_rack(tilesUsed = []):
	player.use_tiles(tilesUsed)
	player.draw_tiles()
	var playerRack = player.get_rack()
	board.show_player_rack(playerRack)
	board.get_node("Grid").unoccupy_board_tiles()

func update_enemy_rack(tilesUsed = []):
	enemy.use_tiles(tilesUsed)
	enemy.draw_tiles(board)
	board.get_node("Grid").unoccupy_board_tiles()

func initialise_enemy():
	enemy = ENEMY.instantiate()
	enemy.set_values(TILESIZE, TILEBORDER, GRIDSIZE, 20, 5)
	enemy.initialise(board)
	add_child(enemy)

func game_turn():
	if !playersTurn:
		print("enemy turn")
		enemy.get_move(board.get_node("Grid"))
		#if enemyMove == []:
			#play_made([], [])
		var grid = board.get_node("Grid")
		var validLocations = enemy.get_valid_locations(grid)
		var rack = enemy.get_rack()
	else:
		print("player turn")
		print("neo vim working")


func play_made(wordsToScore, tilesUsed):
	var scoreLabel = %Score
	if !playersTurn:
		scoreLabel = %EnemyScore
	await playScorer.animate_score(wordsToScore, scoreLabel, tilesUsed)
	remove_board_multipliers(wordsToScore)
	
	playersTurn = !playersTurn
	if playersTurn:
		update_enemy_rack(tilesUsed)
	if !playersTurn:
		update_player_rack(tilesUsed)
		resolve_scores()
		
	game_turn()

func tiles_to_word(tiles):
	var word = ""
	for tile in tiles:
		word += tile.get_label()
	return word



func remove_board_multipliers(wordsPlayed):
	for word in wordsPlayed:
		for tile in word:
			var boardTile = tile.get_current_board_tile()
			var coords = board.get_node("Grid").get_coordinates(boardTile)
			boardTile.set_square_multiplier(1, "word")
			boardTile.set_square_multiplier(1, "letter")

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
		await player.exchange_tiles()
		play_made([], [])
		update_player_rack()
