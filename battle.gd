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
var playersTurn = false
var exchanging = false
var enemyScore = 0
var playerScore = 0
var readyForNextTurn = true

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
	
func _process(_delta):
	if readyForNextTurn and !playersTurn:
		readyForNextTurn = false
		game_turn()

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
	else:
		print("player turn")


func play_made(wordsToScore, tilesUsed):
	print("play made")
	var scoreLabel = %Score
	if !playersTurn:
		scoreLabel = %EnemyScore
	var score = await playScorer.animate_score(wordsToScore, scoreLabel, tilesUsed)
	remove_board_multipliers(wordsToScore)
	
	playersTurn = !playersTurn
	if playersTurn:
		update_enemy_rack(tilesUsed)
		enemyScore = score
		game_turn()
	if !playersTurn:
		update_player_rack(tilesUsed)
		playerScore = score
		readyForNextTurn = false
		resolve_scores()
		
func tiles_to_word(tiles):
	var word = ""
	for tile in tiles:
		word += tile.get_label()
	return word

func remove_board_multipliers(wordsPlayed):
	for word in wordsPlayed:
		for tile in word:
			var boardTile = tile.get_current_board_tile()
			boardTile.set_square_multiplier(1, "word")
			boardTile.set_square_multiplier(1, "letter")


func resolve_scores():
	#Cancel out damage then deal 
	var minScore = min(playerScore, enemyScore)
	smooth_adjust_scores(playerScore - minScore, enemyScore - minScore)

func smooth_adjust_scores(newPlayerScore, newEnemyScore):
	while playerScore != newPlayerScore or enemyScore != newEnemyScore:
		var delta = direction_to_change(playerScore, newPlayerScore)
		playerScore += delta
		set_score_label(%Score, playerScore)

		delta = direction_to_change(enemyScore, newEnemyScore)
		enemyScore += delta
		set_score_label(%EnemyScore, enemyScore)
		await wait(0.1)
	readyForNextTurn = true


func direction_to_change(value, target):
	if value == target:
		return 0 
	elif value < target:
		return 1
	else:
		return -1

func set_score_label(label, score):
	label.text = "Score: " + str(score)

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
		
func wait(seconds):
	await get_tree().create_timer(seconds).timeout
