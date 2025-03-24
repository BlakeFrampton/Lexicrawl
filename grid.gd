extends Node

var TILESIZE = null
var TILEBORDER = null
var GRIDSIZE = null
const STANDARDBOARDCOLOUR = Color(0xFFe2AEFF)
const TRIPLEWORDCOLOUR = Color(0xd95258FF)
const DOUBLEWORDCOLOUR = Color(0xe79ea9FF)
const DOUBLELETTERCOLOUR = Color(0xa2cceeFF)
const TRIPLELETTERCOLOUR = Color(0x0185c6FF)

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
			boardTiles[x][y].get_node("ColorRect").position=Vector2(startingX + x * (TILESIZE + TILEBORDER), startingY + y * (TILESIZE + TILEBORDER))
			boardTiles[x][y].get_node("ColorRect").size = Vector2(TILESIZE, TILESIZE)
			boardTiles[x][y].get_node("ColorRect").color = setBoardTileColour(boardTiles, x, y)
			#boardTiles[x][y].check_play.connect(get_words_to_score)

			add_child(boardTiles[x][y])

func set_word_list(filePath):
	var file = FileAccess.open(filePath, FileAccess.READ)
	var words = []
	
	if file:
		while not file.eof_reached():
			var line = file.get_line()
			words.append(line)
	
	wordList = words

func setBoardTileColour(boardTiles, x, y):
	if (min(x, y) == 0 and max(x,y) == 3) or (min(x, y) == 0 and max(x,y) == 11) or (min(x, y) == 3 and max(x,y) == 14) or (min(x, y) == 11 and max(x,y) == 14): #outer ring
		boardTiles[x][y].tileType = "2L"
		return DOUBLELETTERCOLOUR
	if (x + y == 12 or x + y == 14 or x + y == 16) and (x == 6 or x == 8) and (y == 6 or y == 8): #inner ring
		return DOUBLELETTERCOLOUR
		boardTiles[x][y].tileType = "2L"
	if (x == 2 and (y == 6 or y == 8) or x == 3 and y == 7 or x == 6 and (y == 2 or y == 12) or x == 7 and (y == 3 or y == 11) or x == 8 and (y == 2 or y == 12) or x == 11 and y == 7 or x == 12 and (y == 6 or y==8)):
		return DOUBLELETTERCOLOUR
		boardTiles[x][y].tileType = "2L"
	if (x == 1 or x == 5 or x == 9 or x == 13) and (y == 1 or y == 5 or y == 9 or y == 13):
		if !((x + y == 14 or x + y == 2 or x + y == 26) and (x == 1 or x == 14)):
			return TRIPLELETTERCOLOUR
			boardTiles[x][y].tileType = "3L"
	if y == 0 or y == 7 or y == 14:
		if x == 0 or (x == 7 and y != 7) or x == 14:
			return TRIPLEWORDCOLOUR
			boardTiles[x][y].tileType = "3W"
	if x == y or (14-x) == y:
		return DOUBLEWORDCOLOUR
		boardTiles[x][y].tileType = "2W"
	return STANDARDBOARDCOLOUR
	
func get_words_to_score():
	var column = -1
	var row = -1
	var horizontal = true
	var vertical = true
	var occupiedTiles = []
	var newTiles = []
	var xCoord = -1
	var yCoord= -1
	var wordsToScore = []
	
	# Check if all new tiles are in one line
	for x in range(GRIDSIZE):
		for y in range(GRIDSIZE):
			if boardTiles[x][y].get_occupancy() != "Empty":
				occupiedTiles.append(boardTiles[x][y])
				if boardTiles[x][y].get_occupancy() == "New":
					newTiles.append(0)
					newTiles[len(newTiles)-1] = boardTiles[x][y]
					xCoord = x
					yCoord = y
					if column == -1:
						column = x
					elif column != x:
						vertical = false
					if row == -1:
						row = y
					elif row != y:
						horizontal = false
	
	if not (horizontal or vertical):
		return []
	
	
	if is_first_turn():
		if boardTiles[7][7].get_occupancy() != "New":
			return []
	else:
		#Check that a new tile is next to an occupied tile
		var adjacentToOccupied = false
		for tile in newTiles:
			var coords = get_coordinates(tile)
			if not adjacentToOccupied:
				if boardTiles[min(coords[0] + 1, GRIDSIZE -1)][coords[1]].get_occupancy() == "Occupied":
					adjacentToOccupied = true
				elif boardTiles[max(coords[0] - 1, 0)][coords[1]].get_occupancy() == "Occupied":
					adjacentToOccupied = true
				elif boardTiles[coords[0]][min(coords[1] + 1, GRIDSIZE -1)].get_occupancy() == "Occupied":
					adjacentToOccupied = true
				elif boardTiles[coords[0]][max(coords[1] - 1, 0)].get_occupancy() == "Occupied":
					adjacentToOccupied = true
		if not adjacentToOccupied:
			return []
	
	var playedWords = []
	if horizontal:
		playedWords = find_played_words(1,0, newTiles)
	else:
		playedWords = find_played_words(0,1, newTiles)
	
	wordsToScore = playedWords.duplicate()
	
	for word in wordsToScore:
		if not word in wordList:
			return []
	
	return wordsToScore

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

func find_played_words(deltaX, deltaY, newTiles):
	var coords = get_coordinates(newTiles[0])
	var words = []
	var newTilesEncountered = 0
	
	while coords[0] -deltaX >= 0 and coords[1] - deltaY >= 0 and boardTiles[coords[0] - deltaX][coords[1] - deltaY].get_occupancy() != "Empty":
		coords[0] -= deltaX
		coords[1] -= deltaY
	
	var startCoords = coords.duplicate()
	var word = boardTiles[coords[0]][coords[1]].get_letterTile().get_letter()
	if boardTiles[coords[0]][coords[1]].get_occupancy() == "New":
		newTilesEncountered += 1
	while coords[0] + deltaX < GRIDSIZE and coords[1] + deltaY < GRIDSIZE and boardTiles[coords[0] + deltaX][coords[1] + deltaY].get_occupancy() != "Empty":
		coords[0] += deltaX
		coords[1] += deltaY
		word += boardTiles[coords[0]][coords[1]].get_letterTile().get_letter()
		if boardTiles[coords[0]][coords[1]].get_occupancy() == "New":
			newTilesEncountered += 1
	
	if newTilesEncountered < len(newTiles):
		return []
	
	if len(word) >= 2:
		words.append(word)
		
	for i in range(len(word)):
		coords = startCoords.duplicate()
		coords[0] += deltaX * i
		coords[1] += deltaY * i
		word = ""
		while coords[0] - deltaY >= 0 and coords[1] - deltaX >= 0 and boardTiles[coords[0] - deltaY][coords[1] - deltaX].get_occupancy() != "Empty": #Delta x and y are switched to check for perpendicular attached words
			coords[0] -= deltaY
			coords[1] -= deltaX
		word += boardTiles[coords[0]][coords[1]].get_letterTile().get_letter()
		while coords[0] + deltaY < GRIDSIZE and coords[1] + deltaX < GRIDSIZE and boardTiles[coords[0] + deltaY][coords[1] + deltaX].get_occupancy() != "Empty":
			coords[0] += deltaY
			coords[1] += deltaX
			word += boardTiles[coords[0]][coords[1]].get_letterTile().get_letter()
		if len(word) >= 2:
			words.append(word)
	
	return words

func submit_play():
	var wordsToScore = get_words_to_score()
	if wordsToScore != []:
		for x in range(GRIDSIZE):
			for y in range(GRIDSIZE):
				if boardTiles[x][y].get_occupancy() == "New":
					boardTiles[x][y].set_occupancy("Occupied")
	
	playMade.emit(wordsToScore)
