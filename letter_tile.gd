extends Node2D
var dragging = false
var dragTileStartPosition
var dragMouseStartPosition
var currentBoardTile
var letter;


func _process(delta):
	if dragging:
		if currentBoardTile == null or currentBoardTile.get_occupancy() != "Occupied":
			move_tile()

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT: #Detects button pressed or lifted
		if Input.is_action_pressed("left_click"): #Button pressed
			if hoveringMe() and not Globals.get_draggingSomething():
				Globals.set_draggingSomething(true)
				dragging = true
				dragTileStartPosition = position
				dragMouseStartPosition = get_global_mouse_position()
				move_to_front() #Move to front of canvas
		elif dragging:
			dragging = false
			Globals.set_draggingSomething(false)

func hoveringMe():
	var mousePos = get_global_mouse_position()
	var spriteSize = get_node("Sprite2D").texture.get_width() * scale.x
	var collisionShape2d = get_node("Area2D/CollisionShape2D")
	if (global_position.x -spriteSize/2<= mousePos.x && global_position.x + spriteSize/2 >= mousePos.x && global_position.y -spriteSize/2<= mousePos.y && global_position.y + spriteSize/2 >= mousePos.y):
		return true
	return false

func move_tile():
	var TILESIZE = Globals.get_tileSize()
	var mousePos = get_global_mouse_position()
	var grid = get_node("/root/Game/game_controller/Board/Grid")
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
				currentBoardTile.check_play.emit()
		else:
			if boardTile == currentBoardTile:
							if (boardTileRect.position.x<= mousePos.x && boardTileRect.position.x + TILESIZE >= mousePos.x && boardTileRect.position.y<= mousePos.y && boardTileRect.position.y+ TILESIZE  >= mousePos.y):
								stillOnTile = true
	if stillOnTile and not currentBoardTile == null:
		position = Vector2(currentBoardTile.get_child(0).position.x + TILESIZE /2, currentBoardTile.get_child(0).position.y + TILESIZE /2)
	if (not currentBoardTile == null) and !stillOnTile:
		currentBoardTile.set_letterTile(null)
		currentBoardTile.set_occupancy("Empty")
		currentBoardTile.check_play.emit()
		currentBoardTile = null

func get_value():
	var pointValue;
	if letter == " ":
		pointValue = 0
	if letter == "D" or letter == "G":
		pointValue = 2
	elif letter == "B" or letter == "C" or letter == "M" or letter == "P":
		pointValue = 3
	elif letter == "F" or letter == "H" or letter == "V" or letter == "W" or letter == "Y":
		pointValue = 4
	elif letter == "K":
		pointValue = 5
	elif letter == "J" or letter == "X":
		pointValue = 8
	elif letter == "Q" or letter == "Z":
		pointValue = 10
	else:
		pointValue = -1;
	
	return pointValue;

func set_letter(tileLetter):
	letter = tileLetter;
	if letter == "blank":
		%Letter.text = " "
	else:
		%Letter.text = letter;

func get_letter():
	return %Letter.text
