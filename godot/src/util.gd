extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

## this function converts xy coordinates to their equivalent in Godot.
## for example, the origin which is normally (0, 0) would become (screenwidth/2, screenheight/2)
static func convert_to_godot_coords(origin: Vector2, vec: Vector2):
	var windowSize :Vector2 = DisplayServer.window_get_size()
	var true_origin = Vector2(origin[0]+windowSize[0]/2, origin[1]+windowSize[1]/2)
	return Vector2(vec[0]+true_origin[0], true_origin[1]-vec[1])

## this function converts Godot coordinates to the equivilent in an xy plane.
## for example, the top left of the screen which is normally (0,0) will become (-x,y)
static func convert_to_real_coords(origin: Vector2, vec: Vector2):
	var windowSize :Vector2 = DisplayServer.window_get_size()
	var true_origin = Vector2(origin[0]+windowSize[0]/2, origin[1]+windowSize[1]/2)
	return Vector2(vec[0]-true_origin[0], true_origin[1]-vec[1])
