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
	board.get_node("Grid").playMade.connect(play_made)

func update_player_rack(tilesUsed = []):
	player.use_tiles(tilesUsed)
	player.draw_tiles()
	var playerRack = player.get_rack()
	board.show_player_rack(playerRack)
	board.get_node("Grid").unoccupy_board_tiles()

func game_turn():
	if !playersTurn:
		#Run enemy turn
		playersTurn = true
		return
	return


func play_made(wordsToScore, tilesUsed):
	for word in wordsToScore:
		print(tiles_to_word(word))
	
	print(await calculate_score(wordsToScore))
	remove_board_multipliers(wordsToScore)
	
	if (playersTurn):
		update_player_rack(tilesUsed)
		resolve_scores()
	playersTurn = false
	game_turn()

func tiles_to_word(tiles):
	var word = ""
	for tile in tiles:
		word += tile.get_label()
	return word

func calculate_score(wordsToScore):
	var totalScore = 0
	for word in wordsToScore:
		totalScore += await score_word(word, totalScore)
	%Score.text = "Score: " + str(totalScore)
	return totalScore

func score_word(word, totalScore):
	var score = 0
	var multiplier = 1
	for tile in word:
		var boardTile = tile.get_current_board_tile()
		score += tile.get_value() * boardTile.get_letter_multiplier()
		multiplier *= tile.get_multiplier() * boardTile.get_word_multiplier()
		%Score.text = "Score: " + str(score + totalScore)
		tile.pulse_and_rotate(0.5)
		await wait(0.5)

	if multiplier > 1:
		for tile in word:
			tile.pulse_and_rotate(0.5)
		%Score.text = "Score: " + str(score * multiplier + totalScore)
		await wait(0.5)
	
	return score * multiplier

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
		player.exchange_tiles()
		update_player_rack()

func wait(seconds):
	await get_tree().create_timer(seconds).timeout

