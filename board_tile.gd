extends Node2D

const STANDARDBOARDCOLOUR = Color(0xFFe2AEFF)
const TRIPLEWORDCOLOUR = Color(0xd95258FF)
const DOUBLEWORDCOLOUR = Color(0xe79ea9FF)
const DOUBLELETTERCOLOUR = Color(0xa2cceeFF)
const TRIPLELETTERCOLOUR = Color(0x0185c6FF)

var occupancy = "Empty"
var letterTile
var letterMultiplier = 1
var wordMultiplier = 1

func set_occupancy(value):
	occupancy = value

func get_occupancy():
	return occupancy
	
func set_letter_tile(newLetterTile):
	letterTile = newLetterTile

func get_letter_tile():
	return letterTile

func set_letter_multiplier(value):
	letterMultiplier = value

func get_letter_multiplier():
	return letterMultiplier
	
func set_word_multiplier(value):
	wordMultiplier = value

func get_word_multiplier():
	return wordMultiplier

func get_multiplier_label():
	return %Multiplier

func get_color_rect():
	return %ColorRect

func get_sprite():
	return %Sprite

func set_square_multiplier(multiplier, multiplierType):
	if multiplier > 1:
		if multiplierType == "word":
			set_word_multiplier(multiplier)
			get_multiplier_label().text = str(multiplier) + "W"
			if multiplier == 2:
				get_color_rect().color = DOUBLEWORDCOLOUR
				get_sprite().modulate = DOUBLEWORDCOLOUR
			elif multiplier == 3:
				get_color_rect().color = TRIPLEWORDCOLOUR
				get_sprite().modulate = TRIPLEWORDCOLOUR
		elif multiplierType == "letter":
			set_letter_multiplier(multiplier)
			get_multiplier_label().text = str(multiplier) + "L"
			if multiplier == 2:
				get_color_rect().color = DOUBLELETTERCOLOUR
				get_sprite().modulate = DOUBLELETTERCOLOUR
			elif multiplier == 3:
				get_color_rect().color = TRIPLELETTERCOLOUR
				get_sprite().modulate = TRIPLELETTERCOLOUR
	else:
		get_color_rect().color = STANDARDBOARDCOLOUR
		get_sprite().modulate = STANDARDBOARDCOLOUR
		get_multiplier_label().text = ""
		wordMultiplier = 1
		letterMultiplier = 1
