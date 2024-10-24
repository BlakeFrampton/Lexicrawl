extends Node2D
var CharList = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S"]
var dragging = false
var dragTileStartPosition
var dragMouseStartPosition
var pointValue = -1
var currentBoardTile

func _ready():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var index = rng.randi_range(0,CharList.size()-1)
	%Letter.text = CharList[index]

func _process(delta):
	if dragging:
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
	if not currentBoardTile == null:
		currentBoardTile.set_occupied(false)
	position = dragTileStartPosition + (get_global_mouse_position() - dragMouseStartPosition)
	for boardTile in grid.get_children():
		var boardTileRect = boardTile.get_child(0)
		if not boardTile.get_occupied():
			if (boardTileRect.position.x<= mousePos.x && boardTileRect.position.x + TILESIZE >= mousePos.x && boardTileRect.position.y<= mousePos.y && boardTileRect.position.y+ TILESIZE  >= mousePos.y):
				position = Vector2(boardTileRect.position.x + TILESIZE /2, boardTileRect.position.y + TILESIZE /2)
				currentBoardTile = boardTile
				currentBoardTile.set_occupied(true)

func set_value(value):
	if value == "Blank":
		pointValue = 0
		%Letter.text = ""
	else:
		%Letter.text = value
	if value == "D" or value == "G":
		pointValue = 2
	elif value == "B" or value == "C" or value == "M" or value == "P":
		pointValue = 3
	elif value == "F" or value == "H" or value == "V" or value == "W" or value == "Y":
		pointValue = 4
	elif value == "K":
		pointValue = 5
	elif value == "J" or value == "X":
		pointValue = 8
	elif value == "Q" or value == "Z":
		pointValue = 10
