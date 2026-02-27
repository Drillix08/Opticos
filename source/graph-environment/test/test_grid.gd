extends "res://addons/gut/test.gd"

var Grid = load("res://grid.gd")
var grid
var windowSize: Vector2

func before_all():
	windowSize = DisplayServer.window_get_size()
	grid = Grid.new()
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	grid.origin = Vector2(rng.randf()*windowSize[0], rng.randf()*windowSize[1]) # generate a random origin simulating the user moving around the graphh

func test_conversions():
	var true_origin = Vector2(grid.origin[0]+windowSize[0]/2, grid.origin[1]+windowSize[1]/2)
	
	# checking origin
	var r_origin = Vector2.ZERO
	var g_origin = Vector2(r_origin[0]+true_origin[0], true_origin[1]-r_origin[1])
	assert_eq(grid.convert_to_godot_coords(r_origin), g_origin)
	assert_eq(grid.convert_to_real_coords(g_origin), r_origin)
	
	# checking top right quadrant
	var r_top_right = Vector2(windowSize[0]/4.0, windowSize[1]/4.0)
	var g_top_right = Vector2(r_top_right[0]+true_origin[0], true_origin[1]-r_top_right[1])
	assert_eq(grid.convert_to_godot_coords(r_top_right), g_top_right)
	assert_eq(grid.convert_to_real_coords(g_top_right), r_top_right)
	
	# checking bottom right quadrant
	var r_bottom_right = Vector2(windowSize[0]/4.0, -windowSize[1]/4.0)
	var g_bottom_right = Vector2(r_bottom_right[0]+true_origin[0], true_origin[1]-r_bottom_right[1])
	assert_eq(grid.convert_to_godot_coords(r_bottom_right), g_bottom_right)
	assert_eq(grid.convert_to_real_coords(g_bottom_right), r_bottom_right)
	
	# checking bottom left quadrant
	var r_bottom_left = Vector2(-windowSize[0]/4.0, -windowSize[1]/4.0)
	var g_bottom_left = Vector2(r_bottom_left[0]+true_origin[0], true_origin[1]-r_bottom_left[1])
	assert_eq(grid.convert_to_godot_coords(r_bottom_left), g_bottom_left)
	assert_eq(grid.convert_to_real_coords(g_bottom_left), r_bottom_left)
	
	# checking top left quadrant
	var r_top_left = Vector2(-windowSize[0]/4.0, -windowSize[1]/4.0)
	var g_top_left = Vector2(r_top_left[0]+true_origin[0], true_origin[1]-r_top_left[1])
	assert_eq(grid.convert_to_godot_coords(r_top_left), g_top_left)
	assert_eq(grid.convert_to_real_coords(g_top_left), r_top_left)
