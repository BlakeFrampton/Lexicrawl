extends Node2D

var tileType = "Standard"
var occupancy = "Empty"
var letterTile

func set_occupancy(value):
	occupancy = value

func get_occupancy():
	return occupancy
	
func set_letterTile(newLetterTile):
	letterTile = newLetterTile

func get_letterTile():
	return letterTile
