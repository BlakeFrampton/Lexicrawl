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
	
	print(search("C-AT"))

# Check if a sequence exists
func search(sequence):
	var node = gaddag
	for letter in sequence:
		if letter in node:
			node = node[letter]
		else:
			return false
	return "*" in node  # Check if it's a full word

func get_best_move(validLocations, grid, rack):
	print("getting moves")
	validMoves = []
	generate_moves(validLocations, grid, rack)
	print("got moves")
	var bestMove = null
	var bestScore = 0
	for move in validMoves:
		for placement in move:
			grid.place_tile(placement[0], placement[1], placement[2])
		var wordsToScore = grid.get_words_to_score()
		var score = playScorer.calculate_score(wordsToScore)
		if score > bestScore:
			bestScore = score
			bestMove = move
			print("New best: ", bestScore)
		grid.unoccupy_board_tiles()
	print("Best score: ", bestScore)
	for placement in bestMove:
		var tile = placement[0]
		grid.place_tile(tile, placement[1], placement[2])
		tile.place_on_board_tile(tile.get_current_board_tile())
	#playScorer.animate_score(bestMove)
	


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
		validMoves.append(tilePlacements)
	
	#Iterate over every child in tree
	for letter in node.keys():
		#Ignore end of word
		if letter == "*":
			continue
		
		if letter == "-":
			var boardTile = grid.get_board_tile(rootCoords[0] - int(isHorizontal), rootCoords[1] - int(!isHorizontal))
			generate_moves_from_point(grid, rack, rootCoords, boardTile, node["-"], word, tilePlacements.duplicate(), isHorizontal, false)
		
		var anchorTile = null
		if anchor:
			anchorTile = anchor.get_letter_tile()
			
		var anchorTileLabel = null
		if anchorTile:
			anchorTileLabel = anchorTile.get_label()
			
		if anchorTile != null:
			if anchorTileLabel == letter:
				if grid.is_valid_coords(x+int(isHorizontal), y+int(!isHorizontal)):
					generate_moves_from_point(grid, rack, rootCoords, grid.get_board_tile(x+int(isHorizontal), y+int(!isHorizontal)), node[letter], new_word(word, letter, isBackwards), tilePlacements.duplicate(), isHorizontal, isBackwards)
			else:
				#If there is a tile placed but it is not a valid option for this subtree, abandon it
				if !anchorTileLabel in node.keys():
					return
		else:
			for tile in rack:
				if tile.get_label() == letter:
					var new_rack = rack.duplicate()
					new_rack.erase(tile)
					if grid.is_valid_coords(x+int(isHorizontal), y+int(!isHorizontal)):
						var newTilePlacements = tilePlacements.duplicate()
						newTilePlacements.append([tile, x, y])
						generate_moves_from_point(grid, new_rack, rootCoords, grid.get_board_tile(x+int(isHorizontal), y+int(!isHorizontal)), node[letter], new_word(word, letter, isBackwards), newTilePlacements, isHorizontal, isBackwards)

func new_word(word, letter, isBackwards):
	if isBackwards:
		return letter + word
	return word + letter
