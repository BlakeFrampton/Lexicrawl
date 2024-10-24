extends Node

const TILESIZE = 64
const TILEBORDER = 2
const GRIDSIZE = 15
var draggingSomething = false

func get_gridSize():
	return GRIDSIZE
	
func get_tileSize():
	return TILESIZE
	
func get_tileBorder():
	return TILEBORDER

func get_draggingSomething():
	return draggingSomething
	
func set_draggingSomething(x):
	draggingSomething = x
