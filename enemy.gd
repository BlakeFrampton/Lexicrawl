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

var searches = 0
	
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
	var validLocations = get_valid_locations(grid)
	playFinder.get_best_move(validLocations, grid, rack)
	
	print("Submitting play")
	grid.submit_play()

func find_move(grid):
	#var search_results = search_step(grid, [], 0, rack, -1, -1, 1)
	#return search_results[1]
	return
	
	

#func search_step(grid, placedTiles, closestScore, tiles, row, col,layer):
	#
	#if layer > 5:
		#return [closestScore, [], false]
	##print("start of step")
	#searches += 1
	#if searches % 1000 == 0:
		#print("searches: ", searches)
	#
	#var newlyPlacedTiles = []
	#var closestPlacedTiles = []
	#var validLocations = get_valid_locations(grid, row, col)
	##print("valid locations: ", validLocations)
	#if row == col and col == -1:
		#print("locations: ", len(validLocations))
	#
	##Try to eliminate sub-tree
	##If a word perpendicular to play is invalid, it will never change this play, so whole subtree is invalid
	#var wordsPlayed = grid.get_words_played()
	#print("Words played:")
	#for word in wordsPlayed:
		#print(grid.tiles_to_word(word))
		#if grid.word_is_horizontal(word):
			#if row != -1:
				#return [closestScore, placedTiles, false]
		#else:
			#if col != -1:
				#return [closestScore, placedTiles, false]
	#
	#var counter = 0
	#for location in validLocations:
		#if row == col and col == -1:
			#counter += 1
			#print("location ",counter)
		#for tile in tiles:
			#tile.placed_on_board(grid.get_board_tile(location[0], location[1]))
			#placedTiles.append([tile, location[0], location[1]])
			#newlyPlacedTiles.append([tile, location[0], location[1]])
			##print("tile ", tile, " placed at ", location[0], ",", location[1])
			#tiles.erase(tile)
			#
			##Check play
			#var wordsToScore = grid.get_words_to_score()
			#if wordsToScore != []:
				#var score = calculate_score(wordsToScore)
				#var distFromTarget = abs(targetScore - score)
				#if distFromTarget < acceptableRange:
					#print("acceptable move found")
					#reset_tiles(grid, newlyPlacedTiles)
					#return [score, placedTiles, true]
				#if distFromTarget < abs(targetScore - closestScore):
					#print("new best: ", score)
					#closestScore = score
					#closestPlacedTiles = placedTiles
			#
			#var search_results
			##If first layer, search for horizontal and vertical plays. Otherwise continue with direction.
			#if row == col and col == -1:
				#search_results = search_step(grid, placedTiles.duplicate(), closestScore, tiles.duplicate(), location[0], -1, layer + 1)
				#if search_results[2]:
					#return search_results
				##Save results
				#if search_results[0] != closestScore:
					#closestScore = search_results[0]
					#closestPlacedTiles = search_results[1]
				#
				#
				#search_results = search_step(grid, placedTiles.duplicate(), closestScore, tiles.duplicate(), -1, location[1], layer+1)
			#else:
				#search_results = search_step(grid, placedTiles.duplicate(), closestScore, tiles.duplicate(), row, col,layer+1)
			#
			#if search_results[2]:
				#return search_results
			##save results
			#if search_results[0] != closestScore:
					#closestScore = search_results[0]
					#closestPlacedTiles = search_results[1]
			#
			#tiles.append(tile)
			#
			#reset_tiles(grid, newlyPlacedTiles)
			#newlyPlacedTiles = []
	#return [closestScore, closestPlacedTiles, false]

#func get_valid_locations(grid, row, col):
	#var tilePlaced = false
	#for x in range(GRIDSIZE):
		#for y in range(GRIDSIZE):
			#if grid.get_board_tile(x,y).get_occupancy() != "Empty":
				#tilePlaced = true
	#if !tilePlaced:
		#return [[7,7]]
	#
	##If row/col is -1, check every row/col. Otherwise, check the passed row/col
	#var rowStart = 0
	#var rowEnd = GRIDSIZE
	#if row != -1:
		#rowStart = row
		#rowEnd = row + 1
	#
	#var colStart = 0
	#var colEnd = GRIDSIZE
	#if col != -1:
		#colStart = col
		#colEnd = col + 1
	#
	#var validLocations = []
	#for x in range(rowStart, rowEnd):
		#for y in range(0, GRIDSIZE):
			#if is_valid_location(x,y,grid):
				#validLocations.append([x,y])
	#return validLocations

func get_valid_locations(grid):
	var tilePlaced = false
	for x in range(GRIDSIZE):
		for y in range(GRIDSIZE):
			if grid.get_board_tile(x,y).get_occupancy() != "Empty":
				tilePlaced = true
	if !tilePlaced:
		return [[7,7]]
	
	var validLocations = []
	for x in range(GRIDSIZE):
		for y in range(GRIDSIZE):
			if is_valid_location(x,y,grid):
				validLocations.append([x,y])
	return validLocations

func is_valid_location(x, y, grid):
	var boardTile = grid.get_board_tile(x,y)
	if boardTile.get_occupancy() == "Empty":
		var adjacentCoords = grid.get_adjacent_coords(x, y)
		for coordinate in adjacentCoords:
			var adjacentTile = grid.get_board_tile(coordinate[0], coordinate[1])
			if adjacentTile.get_occupancy() != "Empty":
				return true
	return false

func reset_tiles(grid, placedTiles):
	for placement in placedTiles:
		placement[0].get_current_board_tile().set_occupancy("Empty")
		placement[0].set_current_board_tile(null)
	
func get_rack():
	return rack
