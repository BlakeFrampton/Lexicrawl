extends Node

var TILESIZE = null
var TILEBORDER = null
var GRIDSIZE = null

var boardTiles = []
var wordList = []

signal playMade

func set_values(tileSize, tileBorder, gridSize):
	TILESIZE = tileSize
	TILEBORDER = tileBorder
	GRIDSIZE = gridSize

func initialise():
	var board_tile = preload("res://board_tile.tscn")
	var startingX = (DisplayServer.screen_get_size().x - GRIDSIZE * (TILESIZE + TILEBORDER)) / 2 
	var startingY = (DisplayServer.screen_get_size().y - (GRIDSIZE + 4) * (TILESIZE + TILEBORDER)) / 2 
	for x in range(GRIDSIZE):
		boardTiles.append([]) 
		for y in range(GRIDSIZE):
			boardTiles[x].append(0) # Set a starter value for each position
			boardTiles[x][y] = board_tile.instantiate()
			boardTiles[x][y].position=Vector2(startingX + x * (TILESIZE + TILEBORDER), startingY + y * (TILESIZE + TILEBORDER))
			boardTiles[x][y].get_multiplier_label().size = Vector2(TILESIZE, TILESIZE)
			boardTiles[x][y].get_color_rect().size = Vector2(TILESIZE, TILESIZE)
			boardTiles[x][y].set_square_multiplier(1, "word")

			add_child(boardTiles[x][y])
	set_board_multipliers()

func set_board_multipliers():
	var word2 = [[1,1], [2,2], [3,3], [4,4], [7,7], [10,10], [11,11], [12,12], [13,13], [1,13],[2,12],[3,11], [4,10], [10,4], [11,3],[12,2],[13,1]]
	var word3 = [[0,0], [7,0], [14,0], [0,7], [14,7], [0,14], [7,14], [14,14]]
	var letter2 = [[3,0], [11,0],[6,2], [8,2],[0,3],[7,3], [14,3], [2,6], [6,6], [8,6], [12,6], [3,7],[11,7], [2,8], [6,8], [8,8], [12,8],[0,11], [7,11], [14,11], [6,12],[8,12],[3,14],[11,14]]
	var letter3 = [[5,1], [9,1], [1,5], [5,5], [9,5], [13,5], [1,9], [5,9], [9,9], [13,9], [5,13], [9,13]]
	
	for square in word2:
		boardTiles[square[0]][square[1]].set_square_multiplier(2, "word")
	for square in word3:
		boardTiles[square[0]][square[1]].set_square_multiplier(3, "word")
	for square in letter2:
		boardTiles[square[0]][square[1]].set_square_multiplier(2, "letter")
	for square in letter3:
		boardTiles[square[0]][square[1]].set_square_multiplier(3, "letter")



func set_word_list(filePath):
	var file = FileAccess.open(filePath, FileAccess.READ)
	var words = []
	
	if file:
		while not file.eof_reached():
			var line = file.get_line()
			words.append(line)
	
	wordList = words

func is_horizontal_play():
	var row = -1
	for x in range(GRIDSIZE):
		for y in range(GRIDSIZE):
			if boardTiles[x][y].get_occupancy() == "New":
				if row == -1:
					row = y
				elif row != y:
					return false
	return true

func is_vertical_play():
	var column = -1
	for x in range(GRIDSIZE):
		for y in range(GRIDSIZE):
			if boardTiles[x][y].get_occupancy() == "New":
				if column == -1:
					column = x
				elif column != x:
					return false
	return true
	
func get_new_tiles_placed():
	var newTiles = []
	for x in range(GRIDSIZE):
		for y in range(GRIDSIZE):
			if boardTiles[x][y].get_occupancy() == "New":
				newTiles.append(boardTiles[x][y])
	return newTiles

func attaches_to_previously_played_word(newTiles):
	for tile in newTiles:
		var coords = get_coordinates(tile)
		var adjacentCoords = get_adjacent_coords(coords[0], coords[1])
		for coordinate in adjacentCoords:
			if boardTiles[coordinate[0]][coordinate[1]].get_occupancy() == "Occupied":
				return true
	return false

func get_adjacent_coords(x,y):
	var coords = []
	if x - 1 >= 0:
		coords.append([x-1, y])
	if x + 1 < GRIDSIZE:
		coords.append([x+1, y])
	if y - 1 >= 0:
		coords.append([x, y-1])
	if y + 1 < GRIDSIZE:
		coords.append([x, y+1])
	return coords

func get_board_tile(x,y):
	return boardTiles[x][y]

func get_words_to_score():
	var words = get_words_played()
	
	for word in words:
		if not word_is_valid(tiles_to_word(word)):
			return []

	return words

func word_is_horizontal(word_tiles):
	var boardTile1 = word_tiles[0].get_current_board_tile()
	var boardTile2 = word_tiles[1].get_current_board_tile()
	
	if get_coordinates(boardTile1)[0] > get_coordinates(boardTile2)[0]:
		return true
	return false

func get_words_played():
	var horizontal = is_horizontal_play()
	var vertical = is_vertical_play()
	
	if not (horizontal or vertical):
		print("not horizontal or vertical")
		return []
	
	var newTiles = get_new_tiles_placed()
	
	if is_first_turn():
		if boardTiles[7][7].get_occupancy() != "New": #First turn must be placed on center tile
			print("7,7 is not occupied 'New'")
			return []
	else:
		if !attaches_to_previously_played_word(newTiles):
			print("Does not attach")
			return []
	
	var words = []
	if horizontal:
		words = get_directional_words_played(1,0, newTiles)
	else:
		words = get_directional_words_played(0,1, newTiles)
	
	return words

func word_is_valid(word):
	if word in wordList:
		return true
	return false

func tiles_to_word(tiles):
	var word = ""
	for tile in tiles:
		word += tile.get_label()
	return word

func is_first_turn():
	for x in range(GRIDSIZE):
		for y in range(GRIDSIZE):
			if boardTiles[x][y].get_occupancy() == "Occupied":
				return false
	return true

func get_coordinates(boardTile):
	for x in range(GRIDSIZE):
		for y in range(GRIDSIZE):
			if boardTiles[x][y] == boardTile:
				return ([x,y])
	return ([-1,-1])

func get_directional_words_played(deltaX, deltaY, newTiles):
	var coords = get_coordinates(newTiles[0])
	var words = []
	var newTilesEncountered = 0
	
	#Go to first tile in played line
	while coords[0] - deltaX >= 0 and coords[1] - deltaY >= 0 and boardTiles[coords[0] - deltaX][coords[1] - deltaY].get_occupancy() != "Empty":
		coords[0] -= deltaX
		coords[1] -= deltaY
	
	var startCoords = coords.duplicate()
	var word = []
	word.append(boardTiles[coords[0]][coords[1]].get_letter_tile()) #Get first letter of word
	
	if boardTiles[coords[0]][coords[1]].get_occupancy() == "New":
		newTilesEncountered += 1
	
	#Traverse through word
	while coords[0] + deltaX < GRIDSIZE and coords[1] + deltaY < GRIDSIZE and boardTiles[coords[0] + deltaX][coords[1] + deltaY].get_occupancy() != "Empty":
		coords[0] += deltaX
		coords[1] += deltaY
		word.append(boardTiles[coords[0]][coords[1]].get_letter_tile()) #Add next letter to word
		if boardTiles[coords[0]][coords[1]].get_occupancy() == "New":
			newTilesEncountered += 1
	
	#Means there is a gap in the word played
	if newTilesEncountered < len(newTiles):
		return []
	
	if len(word) >= 2:
		words.append(word)
		
	for i in range(len(word)):
		coords = startCoords.duplicate()
		coords[0] += deltaX * i
		coords[1] += deltaY * i
		
		#Only check for perpendicular words on new tiles
		if boardTiles[coords[0]][coords[1]].get_occupancy() == "New": 
			word = []
			#Traverse to start of word
			while coords[0] - deltaY >= 0 and coords[1] - deltaX >= 0 and boardTiles[coords[0] - deltaY][coords[1] - deltaX].get_occupancy() != "Empty": #Delta x and y are switched to check for perpendicular attached words
				coords[0] -= deltaY
				coords[1] -= deltaX
			word.append(boardTiles[coords[0]][coords[1]].get_letter_tile())
			
			#Traverse to end of word
			while coords[0] + deltaY < GRIDSIZE and coords[1] + deltaX < GRIDSIZE and boardTiles[coords[0] + deltaY][coords[1] + deltaX].get_occupancy() != "Empty":
				coords[0] += deltaY
				coords[1] += deltaX
				word.append(boardTiles[coords[0]][coords[1]].get_letter_tile())
			
			if len(word) >= 2:
				words.append(word)
	return words

func submit_play():
	var wordsToScore = get_words_to_score()
	print("Words to score: ", wordsToScore)
	var tilesUsed = []
	if wordsToScore != []:
		for x in range(GRIDSIZE):
			for y in range(GRIDSIZE):
				if boardTiles[x][y].get_occupancy() == "New":
					var tile = boardTiles[x][y].get_letter_tile()
					if !tilesUsed.has(tile): #if we haven't recorded that this tile is used, add it to the list
						tilesUsed.append(tile)
					boardTiles[x][y].set_occupancy("Occupied")
	
	if wordsToScore != []:
		playMade.emit(wordsToScore, tilesUsed)

func unoccupy_board_tiles():
	for x in range(GRIDSIZE):
		for y in range(GRIDSIZE):
			if boardTiles[x][y].get_occupancy() == "New":
				boardTiles[x][y].set_occupancy("Empty")
				var letterTile = boardTiles[x][y].get_letter_tile()
				boardTiles[x][y].set_letter_tile(null)
				if letterTile:
					letterTile.set_current_board_tile(null)

func is_valid_coords(x, y):
	if x < GRIDSIZE and x >= 0:
		if y < GRIDSIZE and y >= 0:
			return true
	return false
	
func place_tile(tile, x, y):
	var boardTile = get_board_tile(x,y)
	boardTile.set_occupancy("New")
	boardTile.set_letter_tile(tile)
	tile.set_current_board_tile(boardTile)
