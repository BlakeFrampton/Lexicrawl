extends Node2D

var TILESIZE = null

var title = ""

var exchanging = false
var exchangeThisTile = false
var dragTileStartPosition
var dragMouseStartPosition
var currentBoardTile
var label
var value = 0
var multiplier = 1
var player
var dragging = false
var awaitingLetter = false

func set_values(title, label, tileSize, value, multiplier, player=null):
	TILESIZE = tileSize
	set_title(title)
	set_label(label)
	set_value(value)
	set_multiplier(multiplier)
	self.player = player

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
				elif player.get_dragging() == false:
					dragging = true
					player.set_dragging(true) #Stores whether any tile is being dragged, to avoid multiple tiles being held at once
					dragTileStartPosition = position
					dragMouseStartPosition = get_global_mouse_position()
					move_to_front() #Move to front of canvas
		elif player.get_dragging():
			player.set_dragging(false)
			dragging = false

func _unhandled_input(event):
	if awaitingLetter and event is InputEventKey and event.pressed:
		var letter = OS.get_keycode_string(event.keycode).to_upper()
		
		if letter.length() == 1 and letter.is_valid_identifier():  # Ensure it's a valid letter
			set_label(letter)
			#status_label.text = "Letter chosen: " + letter
			awaitingLetter = false  # Stop listening for input


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
		if boardTile.get_occupancy() == "Empty":
			if (boardTile.position.x<= mousePos.x && boardTile.position.x + TILESIZE >= mousePos.x && boardTile.position.y<= mousePos.y && boardTile.position.y+ TILESIZE  >= mousePos.y):
				if not currentBoardTile == null:
					currentBoardTile.set_letter_tile(null)
					currentBoardTile.set_occupancy("Empty")
				stillOnTile = true
				placed_on_board(boardTile)
		else:
			if boardTile == currentBoardTile:
							if (boardTile.position.x<= mousePos.x && boardTile.position.x + TILESIZE >= mousePos.x && boardTile.position.y<= mousePos.y && boardTile.position.y+ TILESIZE  >= mousePos.y):
								stillOnTile = true
	if stillOnTile and not currentBoardTile == null:
		position = Vector2(currentBoardTile.position.x + TILESIZE /2, currentBoardTile.position.y + TILESIZE /2)
	if (not currentBoardTile == null) and !stillOnTile:
		currentBoardTile.set_letter_tile(null)
		currentBoardTile.set_occupancy("Empty")
		currentBoardTile = null

func placed_on_board(boardTile):
	currentBoardTile = boardTile
	currentBoardTile.set_letter_tile(self)
	currentBoardTile.set_occupancy("New")
	if is_blank():
		select_label()

func is_blank():
	if title.to_lower().contains("blank"):
		return true
	return false

func select_label():
	awaitingLetter = true
	set_label("_")
	print("awaiting letter")
	#status_label.text = "Choose a letter for the blank tile"

func set_value(value = null):
	if value:
		self.value = value
	else:
		if label == " ":
			self.value = 0
		elif label == "A" or label == "E" or label == "I" or label == "L" or label == "N" or label == "O" or label == "R" or label == "S" or label == "T" or label == "U":
			self.value = 1
		elif label == "D" or label == "G":
			self.value = 2
		elif label == "B" or label == "C" or label == "M" or label == "P":
			self.value = 3
		elif label == "F" or label == "H" or label == "V" or label == "W" or label == "Y":
			self.value = 4
		elif label == "K":
			self.value = 5
		elif label == "J" or label == "X":
			self.value = 8
		elif label == "Q" or label == "Z":
			self.value = 10
		else:
			self.value = -1;
	
	%Value.text = str(self.value)

func get_value():
	return value

func set_multiplier(multiplier):
	if multiplier:
		self.multiplier = multiplier
	else:
		self.multiplier = 1
	if self.multiplier == 1:
		%Multiplier.text = ""
	else:
		%Multiplier.text = "x" + str(self.multiplier)

func get_multiplier():
	return multiplier

func set_label(label):
	self.label = label
	%Letter.text = self.label;

func get_label():
	return label

func get_letter():
	return label
	#For special tiles like blanks this will be different

func set_title(value):
	title = value

func pulse_and_rotate(duration):
	var tween = get_tree().create_tween()
	var sprite = get_node("Sprite2D")
	const SCALE = 1.5
	# Scale up to 130% and rotate 30 degrees in 0.25s
	tween.parallel().tween_property(sprite, "scale", Vector2(SCALE, SCALE), duration / 2).set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_property(sprite, "rotation_degrees", 30, duration / 2).set_trans(Tween.TRANS_SINE)
	
	#tween.chain()
	## Scale back to 100% and rotate back to 0 in the next 0.25s
	tween.parallel().tween_property(sprite, "scale", Vector2(1.0, 1.0), duration / 2).set_delay(duration/2).set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_property(sprite, "rotation_degrees", 0, duration / 2).set_delay(duration/2).set_trans(Tween.TRANS_SINE)

func get_current_board_tile():
	return currentBoardTile
