extends Node2D

var gaddag = {}
var validMoves
var playScorer

func _ready():
	playScorer = get_node("/root/playScorer")
	var file = FileAccess.open("res://gaddag.json", FileAccess.READ)
	if file:
		var content = file.get_as_text()
		gaddag = JSON.parse_string(content)
		print("GADDAG loaded successfully!")
	else:
		print("Failed to load GADDAG!")

# Check if a sequence exists
func search(sequence):
	var node = gaddag
	for letter in sequence:
		if letter in node:
			node = node[letter]
		else:
			return false
	return "*" in node  # Check if it's a full word

func enemy_play_move(validLocations, grid, rack, targetScore, acceptableRange):
	var move = get_move(validLocations, grid, rack, targetScore, acceptableRange)
	for placement in move:
		var tile = placement[0]
		grid.place_tile(tile, placement[1], placement[2])
		tile.place_on_board_tile(tile.get_current_board_tile())
	#playScorer.animate_score(bestMove)

func get_move(validLocations, grid, rack, targetScore, acceptableRange):
	print("getting moves")
	validMoves = []
	generate_moves(validLocations, grid, rack)
	print("got moves")
	var closestMove = null
	var minScoreDifference = 1000
	for move in validMoves:
		var tilesUsed = []
		for placement in move:
			tilesUsed.append(placement[0])
			grid.place_tile(placement[0], placement[1], placement[2])
		var wordsToScore = grid.get_words_to_score()
		var score = playScorer.calculate_score(wordsToScore, tilesUsed)
		var scoreDifference = abs(targetScore - score)
		if scoreDifference < minScoreDifference:
			if scoreDifference <= acceptableRange:
				grid.unoccupy_board_tiles()
				return move
			minScoreDifference = scoreDifference
			closestMove = move
		grid.unoccupy_board_tiles()
	return closestMove
	

func generate_moves(validLocations, grid, rack):
	for location in validLocations:
		var boardTile = grid.get_board_tile(location[0], location[1])
		generate_moves_from_point(grid, rack, location, boardTile, gaddag, "", [], true, true)
		generate_moves_from_point(grid, rack, location, boardTile, gaddag, "", [], false, true)

func generate_moves_from_point(grid, rack, rootCoords, anchor, node, word, tilePlacements, isHorizontal, isBackwards):
	var coords = grid.get_coordinates(anchor)
	var x = coords[0]
	var y = coords[1]
	
	#If currently on a complete and valid word
	if "*" in node.keys() and len(tilePlacements) > 0:
		if !tilePlacements in validMoves:
			validMoves.append(tilePlacements)
	
	#Iterate over every child in tree
	for letter in node.keys():
		#Ignore end of word
		if letter == "*":
			continue
		
		if letter == "-":
			var newCoords = get_new_coords(rootCoords[0], rootCoords[1], isHorizontal, false)
			var boardTile = grid.get_board_tile(newCoords[0], newCoords[1])
			generate_moves_from_point(grid, rack, rootCoords, boardTile, node["-"], word, tilePlacements.duplicate(), isHorizontal, false)
		
		var anchorTile = null
		if anchor:
			anchorTile = anchor.get_letter_tile()
			
		var anchorTileLabel = null
		if anchorTile:
			anchorTileLabel = anchorTile.get_label()
			
		if anchorTile != null:
			if anchorTileLabel == letter:
				var newCoords = get_new_coords(x, y, isHorizontal, isBackwards)
				if grid.is_valid_coords(newCoords[0], newCoords[1]):
					generate_moves_from_point(grid, rack, rootCoords, grid.get_board_tile(x+int(isHorizontal), y+int(!isHorizontal)), node[letter], new_word(word, letter, isBackwards), tilePlacements.duplicate(), isHorizontal, isBackwards)
			else:
				#If there is a tile placed but it is not a valid option for this subtree, abandon it
				if !anchorTileLabel in node.keys():
					return
		else:
			for tile in rack:
				if tile.get_label() == letter:
					if !is_valid_tile_placement(grid, anchor, tile, !isHorizontal):
						return false
					else:
						var new_rack = rack.duplicate()
						new_rack.erase(tile)
						var newCoords = get_new_coords(x, y, isHorizontal, isBackwards)
						if grid.is_valid_coords(newCoords[0], newCoords[1]):
							var newTilePlacements = tilePlacements.duplicate()
							newTilePlacements.append([tile, x, y])
							generate_moves_from_point(grid, new_rack, rootCoords, grid.get_board_tile(newCoords[0], newCoords[1]), node[letter], new_word(word, letter, isBackwards), newTilePlacements, isHorizontal, isBackwards)

func get_new_coords(x, y, isHorizontal, isBackwards):
	return [x+int(isHorizontal) * pow(-1, isBackwards), y+int(!isHorizontal) * pow(-1, isBackwards)]

func new_word(word, letter, isBackwards):
	if isBackwards:
		return letter + word
	return word + letter

#Takes a tile and where it will be placed along with a direction. Checks if the tile works in that direction
#Used to check for creating invalid words perpendicular to play
func is_valid_tile_placement(grid, anchor, tile, isHorizontal):
	var node = gaddag
	node = node["A"]
	node = node["-"]
	node = node["W"]
	node = node["A"]
	node = node["*"]
	node = gaddag
	var reverse = true
	var coords = grid.get_coordinates(anchor)
	var wordLength = 0
	
	grid.place_tile(tile, coords[0], coords[1])
	while true:
		var boardTile = null
		tile = null
		if grid.is_valid_coords(coords[0], coords[1]):
			boardTile = grid.get_board_tile(coords[0], coords[1])
			tile = boardTile.get_letter_tile()
		if tile == null:
			if "*" in node.keys():
				grid.unoccupy_board_tiles()
				return true
			elif "-" in node.keys():
				reverse = false
				node = node["-"]
				coords = grid.get_coordinates(anchor)
				coords[0] += int(isHorizontal)
				coords[1] += int(!isHorizontal)
			else:
				#If wordLength == 1, then the word is one letter long, which is not a valid scrabble word but is allowed to be on the board
				grid.unoccupy_board_tiles()
				return (wordLength == 1)
		else:
			var letter = tile.get_label()
			
			if letter in node.keys():
				wordLength += 1
				node = node[letter]
				#If reverse is true, multiplies by -1. Otherwise, multiplies by 1
				coords[0] = coords[0] + int(isHorizontal) * pow(-1, int(reverse))
				coords[1] = coords[1] + int(!isHorizontal) * pow(-1, int(reverse))
			else:
				grid.unoccupy_board_tiles()
				return false
	
