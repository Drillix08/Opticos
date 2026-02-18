extends Control

@export var grid_spacing :int = 100
@export var gridline_thickness :float = 1.0

var isDragging :bool = false
var lastMousePos := Vector2.ZERO
var origin := Vector2.ZERO

'''
If the x or y value of the origin has a distance
that's greater then the grid spacing
the x or y pixel positions are reset to what they originally
were at when the origin was at (0, 0), otherwise does nothing
'''
func refresh_pixel_positions(xOffset, yOffset):
	while (abs(xOffset) > grid_spacing):
		if (xOffset > 0):
			xOffset -= grid_spacing
		if (xOffset < 0):
			xOffset += grid_spacing
	while (abs(yOffset) > grid_spacing):
		if (yOffset > 0):
			yOffset -= grid_spacing
		if (yOffset < 0):
			yOffset += grid_spacing
			
	return [xOffset, yOffset]

func _draw():
	var windowSize :Vector2i = DisplayServer.window_get_size()
	
	#Draw the vertical lines of the grid
	for x in range(0, 2*(int(windowSize.x)), grid_spacing):
		var color = Color(0.5, 0.5, 0.5)
		#offset values the pixel positions of the graph objects 
		#have from their original positions when the origin was at initialization
		var refreshedPosition :Array = refresh_pixel_positions(origin.x, origin.y)
		var xOffset :float = refreshedPosition[0]
		var yOffset :float = refreshedPosition[1]
		#draw vertical gridline
		draw_line(Vector2(x+xOffset, yOffset-grid_spacing), Vector2(x+xOffset, 2*windowSize.y+yOffset-grid_spacing), color, gridline_thickness)
		#draw an x-axis tick
		draw_line(Vector2(x+xOffset, 280+origin.y), Vector2(x+xOffset, 320+origin.y), Color(0.0, 0.0, 0.0, 1.0), 5*gridline_thickness)
	#Draw the horizontal lines of the grid
	for y in range(0, 2*(int(windowSize.y)), grid_spacing):
		var color = Color(0.5, 0.5, 0.5)
		#offset values the pixel positions of the graph objects 
		#have from their original positions when the origin was at initialization
		var refreshedPosition :Array = refresh_pixel_positions(origin.x, origin.y)
		var xOffset :float = refreshedPosition[0]
		var yOffset :float = refreshedPosition[1]
		#Draw horizontal gridline
		draw_line(Vector2(xOffset-grid_spacing, y+yOffset), Vector2(2*windowSize.x+xOffset-grid_spacing, y+yOffset), color, gridline_thickness)
		#draw a y-axis tick
		draw_line(Vector2(480+origin.x, y+yOffset), Vector2(520+origin.x, y+yOffset), Color(0.0, 0.0, 0.0, 1.0), 5*gridline_thickness)
	#Draw x-axis
	

	draw_line(Vector2(-origin.x, 300) + origin, Vector2(1000-origin.x, 300) + origin, Color(0.0, 0.0, 0.0, 1.0), 5*gridline_thickness)
	#draw y-axis
	draw_line(Vector2(500, -origin.y) + origin, Vector2(500, 700-origin.y) + origin, Color(0.0, 0.0, 0.0, 1.0), 5*gridline_thickness)

	#Draw the function
	draw_function(func(x):
		return x**2
	)
	
#controlls the moving of the "camera" when you click and drag
func _input(event):
	if event is InputEventMouseButton\
	and event.button_index == MOUSE_BUTTON_LEFT:
		isDragging = event.pressed
		lastMousePos = event.position
	if event is InputEventMouseMotion and isDragging:
		var delta :Vector2 = event.position - lastMousePos
		origin += delta
		lastMousePos = event.position
		queue_redraw()

## This function will draw the graph of the function specified by input_function
## The argument of this function should be a function that takes a single argument x and returns y
func draw_function(input_function: Callable):
	var windowSize :Vector2i = DisplayServer.window_get_size()
	var left = -(origin[0] + windowSize[0]/2.0)
	var right = left + windowSize[0]
	while(left < right-1):
		var x0 = (left)/grid_spacing
		var x1 = (left+1)/grid_spacing
		var y0 = input_function.call(x0)
		var y1 = input_function.call(x1)
		x0 *= grid_spacing
		x1 *= grid_spacing
		y0 *= grid_spacing
		y1 *= grid_spacing
		draw_line(convert_to_godot_coords(Vector2(x0, y0)), convert_to_godot_coords(Vector2(x1, y1)), Color.RED, 2)
		left += 1

## this function converts Godot coordinates to the equivilent in an xy plane.
## for example, the top left of the screen which is normally (0,0) will become (-x,y)
func convert_to_real_coords(vec: Vector2):
	var windowSize :Vector2 = DisplayServer.window_get_size()
	var true_origin = Vector2(origin[0]+windowSize[0]/2, origin[1]+windowSize[1]/2)
	return Vector2(vec[0]-true_origin[0], true_origin[1]-vec[1])
	
## this function converts xy coordinates to their equivalent in Godot.
## for example, the origin which is normally (0, 0) would become (screenwidth/2, screenheight/2)
func convert_to_godot_coords(vec: Vector2):
	var windowSize :Vector2 = DisplayServer.window_get_size()
	var true_origin = Vector2(origin[0]+windowSize[0]/2, origin[1]+windowSize[1]/2)
	return Vector2(vec[0]+true_origin[0], true_origin[1]-vec[1])
