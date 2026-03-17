extends "res://addons/gut/test.gd"

var Grid = load("res://grid.gd")
var grid
var windowSize: Vector2
var origins: Array[Vector2]

func before_all():
	windowSize = DisplayServer.window_get_size()
	grid = Grid.new()
	# different origin positions to test
	origins = [Vector2(0,0), Vector2(windowSize[0]/2, 0), windowSize/2, Vector2(0, windowSize[1]/2)]

func test_conversions():
	for origin in origins:
		grid.origin = origin
		var true_origin = Vector2(grid.origin[0]+windowSize[0]/2, grid.origin[1]+windowSize[1]/2)
		
		# checking origin
		var r_origin = Vector2.ZERO
		var g_origin = Vector2(r_origin[0]+true_origin[0], true_origin[1]-r_origin[1])
		assert_almost_eq(grid.convert_to_godot_coords(r_origin), g_origin, Vector2(0.001, 0.001))
		assert_almost_eq(grid.convert_to_real_coords(g_origin), r_origin, Vector2(0.001, 0.001))
		
		# checking top right quadrant
		var r_top_right = Vector2(windowSize[0]/4.0, windowSize[1]/4.0)
		var g_top_right = Vector2(r_top_right[0]+true_origin[0], true_origin[1]-r_top_right[1])
		assert_almost_eq(grid.convert_to_godot_coords(r_top_right), g_top_right, Vector2(0.001, 0.001))
		assert_almost_eq(grid.convert_to_real_coords(g_top_right), r_top_right, Vector2(0.001, 0.001))
		
		# checking bottom right quadrant
		var r_bottom_right = Vector2(windowSize[0]/4.0, -windowSize[1]/4.0)
		var g_bottom_right = Vector2(r_bottom_right[0]+true_origin[0], true_origin[1]-r_bottom_right[1])
		assert_almost_eq(grid.convert_to_godot_coords(r_bottom_right), g_bottom_right, Vector2(0.001, 0.001))
		assert_almost_eq(grid.convert_to_real_coords(g_bottom_right), r_bottom_right, Vector2(0.001, 0.001))
		
		# checking bottom left quadrant
		var r_bottom_left = Vector2(-windowSize[0]/4.0, -windowSize[1]/4.0)
		var g_bottom_left = Vector2(r_bottom_left[0]+true_origin[0], true_origin[1]-r_bottom_left[1])
		assert_almost_eq(grid.convert_to_godot_coords(r_bottom_left), g_bottom_left, Vector2(0.001, 0.001))
		assert_almost_eq(grid.convert_to_real_coords(g_bottom_left), r_bottom_left, Vector2(0.001, 0.001))
		
		# checking top left quadrant
		var r_top_left = Vector2(-windowSize[0]/4.0, -windowSize[1]/4.0)
		var g_top_left = Vector2(r_top_left[0]+true_origin[0], true_origin[1]-r_top_left[1])
		assert_almost_eq(grid.convert_to_godot_coords(r_top_left), g_top_left, Vector2(0.001, 0.001))
		assert_almost_eq(grid.convert_to_real_coords(g_top_left), r_top_left, Vector2(0.001, 0.001))

func test_graph_plotting():
	# Array of functions to test
	# Some test cases for functions that result in very large values may be shown to fail because of floating point math
	var functions: Array[Callable] = [func(x): return tan(x), func(x): return log(x), func(x): return x**2]
	for i in range(len(functions)):
		for origin in origins:
			grid.origin = origin
			var points: Array[Vector2] = grid.draw_function(functions[i])
			for j in range(1, len(points), len(points)/10):
				var point = grid.convert_to_real_coords(points[j])
				point /= grid.grid_spacing
				if(is_nan(point[1])):
					assert_true(is_nan(functions[i].call(point[0])))
				elif(functions[i].call(point[0]) == -INF):
					pass
				else:
					assert_almost_eq(functions[i].call(point[0]), point[1], 0.01) 
