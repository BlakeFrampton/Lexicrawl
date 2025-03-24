extends Node2D

var TILEBAG = preload("res://tile_bag.tscn")
var TILESIZE
var TILEBORDER
var GRIDSIZE

var targetScore
var acceptableRange
var rack = []
var rackSize = 7
var tileBag
	
func set_values(tileSize, tileBorder, gridSize, targetScore, acceptableRange):
	TILESIZE = tileSize
	TILEBORDER = tileBorder
	GRIDSIZE = gridSize
	self.targetScore = targetScore
	self.acceptableRange = acceptableRange

func initialise(board):
	tileBag = TILEBAG.instantiate()
	tileBag.set_values(TILESIZE, null)
	add_child(tileBag)
	draw_tiles(board)
	
func draw_tiles(board):
	for i in range(rackSize - len(rack)):
		var next_tile = tileBag.get_tile()
		if next_tile:
			next_tile.position = Vector2(-100,-100)
			rack.append(next_tile)
			board.add_child(next_tile)
		else:
			print("Enemy out of tiles")

func use_tiles(tilesUsed):
	for tile in tilesUsed:
		rack.erase(tile)

func print_rack():
	var output = ""
	for tile in rack:
		output += tile.get_title()
		output += ", "
	print(output)

func get_move(grid):
	print_rack()
	
	var move = find_move(grid)
	for placement in move:
		var tile = placement[0]
		var x = placement[1]
		var y = placement[2]
		place_tile(tile, x,y, grid)
		tile.position = tile.get_board_tile_position(grid.get_board_tile(x,y))
	grid.submit_play()
	
	return move

func find_move(grid):
	var closestPlacedTiles = []
	var closestScore = 0
	var placedTiles = []
	
	var validLocations = get_valid_locations(grid)
	for location in validLocations:
		for tile in rack:
			tile.placed_on_board(grid.get_board_tile(location[0], location[1]))
			placedTiles.append([tile, location[0], location[1]])
			var wordsToScore = grid.get_words_to_score()
			if wordsToScore != []:
				var score = calculate_score(wordsToScore)
				var distFromTarget = abs(targetScore - score)
				if distFromTarget < acceptableRange:
					print("acceptable move found")
					reset_tiles(grid)
					return placedTiles
				if distFromTarget < abs(targetScore - closestScore):
					print("new best: ", score)
					closestScore = score
					closestPlacedTiles = placedTiles
			reset_tiles(grid)
			placedTiles = []
	return closestPlacedTiles

func get_valid_locations(grid):
	if grid.is_first_turn():
		return [[7,7]]
	
	var validLocations = []
	for x in range(GRIDSIZE):
		for y in range(GRIDSIZE):
			if is_valid_location(x,y,grid):
				validLocations.append([x,y])
	return validLocations

func is_valid_location(x, y,grid):
	var boardTile = grid.get_board_tile(x,y)
	if boardTile.get_occupancy() == "Empty":
		var adjacentCoords = grid.get_adjacent_coords(x, y)
		for coordinate in adjacentCoords:
			var adjacentTile = grid.get_board_tile(coordinate[0], coordinate[1])
			if adjacentTile.get_occupancy() == "Occupied":
				return true
	return false

func reset_tiles(grid):
	grid.unoccupy_board_tiles()
	for tile in rack:
		tile.set_current_board_tile(null)

func place_tile(tile, x, y, grid):
	var boardTile = grid.get_board_tile(x,y)
	boardTile.set_occupancy("New")
	boardTile.set_letter_tile(tile)
	tile.set_current_board_tile(boardTile)
	

func calculate_score(wordsToScore):
	var totalScore = 0
	for word in wordsToScore:
		totalScore += score_word(word, totalScore)
	return totalScore

func score_word(word, totalScore):
	var score = 0
	var multiplier = 1
	for tile in word:
		var boardTile = tile.get_current_board_tile()
		score += tile.get_value() * boardTile.get_letter_multiplier()
		multiplier *= tile.get_multiplier() * boardTile.get_word_multiplier()
	
	return score * multiplier
