extends Node2D

var TILESIZE = null

var exchanging = false
var exchangeThisTile = false
var dragging = false
var dragTileStartPosition
var dragMouseStartPosition
var currentBoardTile
var label;

func set_values(tileLabel, tileSize):
	label = tileLabel
	TILESIZE = tileSize
	%Letter.text = label;

func _process(delta):
	if dragging:
		if currentBoardTile == null or currentBoardTile.get_occupancy() != "Occupied":
			move_tile()

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT: #Detects button pressed or lifted
		if Input.is_action_pressed("left_click"): #Button pressed
			if hoveringMe():
				if exchanging:
					exchangeThisTile = !exchangeThisTile
					set_exchange_colour()
				elif not dragging:
					dragging = true
					dragTileStartPosition = position
					dragMouseStartPosition = get_global_mouse_position()
					move_to_front() #Move to front of canvas
		elif dragging:
			dragging = false

func set_exchanging(exchanging):
	self.exchanging = exchanging
	exchangeThisTile = false
	set_exchange_colour()

func set_exchange_colour():
	if exchanging and !exchangeThisTile:
		get_node("Sprite2D").modulate = Color(0.5,0.5,0.5, 1)
	else:
		get_node("Sprite2D").modulate = Color(1,1,1)

func get_exchange_this_tile():
	print(exchangeThisTile)
	return exchangeThisTile

func hoveringMe():
	var mousePos = get_global_mouse_position()
	var spriteSize = get_node("Sprite2D").texture.get_width() * scale.x
	var collisionShape2d = get_node("Area2D/CollisionShape2D")
	if (global_position.x -spriteSize/2<= mousePos.x && global_position.x + spriteSize/2 >= mousePos.x && global_position.y -spriteSize/2<= mousePos.y && global_position.y + spriteSize/2 >= mousePos.y):
		return true
	return false

func move_tile():
	var mousePos = get_global_mouse_position()
	var grid = get_node("/root/Game/Battle/Board/Grid")
	var stillOnTile = false
	position = dragTileStartPosition + (get_global_mouse_position() - dragMouseStartPosition)
	for boardTile in grid.get_children():
		var boardTileRect = boardTile.get_child(0)
		if boardTile.get_occupancy() == "Empty":
			if (boardTileRect.position.x<= mousePos.x && boardTileRect.position.x + TILESIZE >= mousePos.x && boardTileRect.position.y<= mousePos.y && boardTileRect.position.y+ TILESIZE  >= mousePos.y):
				if not currentBoardTile == null:
					currentBoardTile.set_letterTile(null)
					currentBoardTile.set_occupancy("Empty")
				currentBoardTile = boardTile
				currentBoardTile.set_letterTile(self)
				currentBoardTile.set_occupancy("New")
				stillOnTile = true
		else:
			if boardTile == currentBoardTile:
							if (boardTileRect.position.x<= mousePos.x && boardTileRect.position.x + TILESIZE >= mousePos.x && boardTileRect.position.y<= mousePos.y && boardTileRect.position.y+ TILESIZE  >= mousePos.y):
								stillOnTile = true
	if stillOnTile and not currentBoardTile == null:
		position = Vector2(currentBoardTile.get_child(0).position.x + TILESIZE /2, currentBoardTile.get_child(0).position.y + TILESIZE /2)
	if (not currentBoardTile == null) and !stillOnTile:
		currentBoardTile.set_letterTile(null)
		currentBoardTile.set_occupancy("Empty")
		currentBoardTile = null

func get_value():
	var pointValue;
	if label == " ":
		pointValue = 0
	if label == "D" or label == "G":
		pointValue = 2
	elif label == "B" or label == "C" or label == "M" or label == "P":
		pointValue = 3
	elif label == "F" or label == "H" or label == "V" or label == "W" or label == "Y":
		pointValue = 4
	elif label == "K":
		pointValue = 5
	elif label == "J" or label == "X":
		pointValue = 8
	elif label == "Q" or label == "Z":
		pointValue = 10
	else:
		pointValue = -1;
	
	return pointValue;

func get_label():
	return label

func get_letter():
	return label
	#For special tiles like blanks this will be different
