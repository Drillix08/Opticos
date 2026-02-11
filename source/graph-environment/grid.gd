extends Control

@export var grid_spacing :int = 20
@export var major_every :int = 5

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
	while (abs(xOffset) > 5*grid_spacing):
		if (xOffset > 0):
			xOffset -= 5*grid_spacing
		if (xOffset < 0):
			xOffset += 5*grid_spacing
	while (abs(yOffset) > 5*grid_spacing):
		if (yOffset > 0):
			yOffset -= 5*grid_spacing
		if (yOffset < 0):
			yOffset += 5*grid_spacing
			
	return [xOffset, yOffset]

func _draw():
	var windowSize :Vector2i = DisplayServer.window_get_size()
	
	#Draw the vertical lines of the grid
	for x in range(0, 2*(int(windowSize.x)), grid_spacing):
		var color := Color(0.3, 0.3, 0.3)
		@warning_ignore("integer_division")
		if (x / grid_spacing) % major_every == 0:
			color = Color(0.5, 0.5, 0.5)
		#offset values the pixel positions of the graph objects 
		#have from their original positions when the origin was at initialization
		var refreshedPosition :Array = refresh_pixel_positions(origin.x, origin.y)
		var xOffset :float = refreshedPosition[0]
		var yOffset :float = refreshedPosition[1]
		#Draw y-axis
		draw_line(Vector2(x+xOffset, yOffset-5*grid_spacing), Vector2(x+xOffset, 2*windowSize.y+yOffset-5*grid_spacing), color)

	#Draw the horizontal lines of the grid
	for y in range(0, 2*(int(windowSize.y)), grid_spacing):
		var color := Color(0.3, 0.3, 0.3)
		@warning_ignore("integer_division")
		if (y / grid_spacing) % major_every == 0:
			color = Color(0.5, 0.5, 0.5)
		#offset values the pixel positions of the graph objects 
		#have from their original positions when the origin was at initialization
		var refreshedPosition :Array = refresh_pixel_positions(origin.x, origin.y)
		var xOffset :float = refreshedPosition[0]
		var yOffset :float = refreshedPosition[1]
		#Draw x-axis
		draw_line(Vector2(xOffset-5*grid_spacing, y+yOffset), Vector2(2*windowSize.x+xOffset-5*grid_spacing, y+yOffset), color)
	
	#Draw the x and y axes
	draw_line(Vector2(500, -origin.y) + origin, Vector2(500, 700-origin.y) + origin, Color(0.0, 0.0, 0.0, 1.0), 5.0)
	draw_line(Vector2(-origin.x, 300) + origin, Vector2(1000-origin.x, 300) + origin, Color(0.0, 0.0, 0.0, 1.0), 5.0)
	
	#Draw the function
	var square_size = windowSize[0]/2.0
	var rect = Rect2(convert_to_godot_coords(Vector2(-square_size, -square_size))-origin, Vector2(2*square_size, 2*square_size))
	draw_function(rect, 0)

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
		
# recursively checks if the function passes through the square,
# if it does, split the square into 4 more square, and check for each one
# if it does not, end the recursion
# the recursion ends when the depth reaches a currently hardcoded value (8 rn) and draws a rectangle
func draw_function(rect: Rect2, depth: int):
	var start = convert_to_real_coords(rect.position)
	var end = convert_to_real_coords(rect.end)
	var conversion = grid_spacing*major_every
	var top: float = start[1]/conversion
	var bottom: float = end[1]/conversion
	var x_left: float = start[0]/conversion
	var x_right: float = end[0]/conversion
	if is_in_rect(bottom, top, x_left, x_right):
		if(depth >= 8):
			draw_rect(rect, Color.RED)
		else:
			var top_left = Rect2(rect.position, rect.size/2)
			var top_right = Rect2(Vector2(rect.position[0]+rect.size[0]/2, rect.position[1]), rect.size/2)
			var bottom_right = Rect2(rect.position+rect.size/2, rect.size/2)
			var bottom_left = Rect2(Vector2(rect.position[0], rect.position[1]+rect.size[1]/2), rect.size/2)
			draw_function(top_left, depth+1)
			draw_function(top_right, depth+1)
			draw_function(bottom_right, depth+1)
			draw_function(bottom_left, depth+1)

#checks if a function (currently hardcoded as x^2) passes through a given rectangle
func is_in_rect(lowerbound, upperbound, left, right):
	var i: float = left
	while i <= right:
		var y = i**2
		if (lowerbound <= y) && (y <= upperbound):
			return true
		i += 0.001
	return false

# this function converts godot coordinates to the equivilent in an xy plane
# for example, the top left of the screen which is normall (0,0) will become (-x,y)
func convert_to_real_coords(vec: Vector2):
	var windowSize :Vector2 = DisplayServer.window_get_size()
	var true_origin = Vector2(origin[0]+windowSize[0]/2, origin[1]+windowSize[1]/2)
	return Vector2(vec[0]-true_origin[0], true_origin[1]-vec[1])
	
# this function converts xy coordinates to their equivalent in godot
# for example, the origin which is normally (0, 0) would become (screenwidth/2, screenheight/2)
func convert_to_godot_coords(vec: Vector2):
	var windowSize :Vector2 = DisplayServer.window_get_size()
	var true_origin = Vector2(origin[0]+windowSize[0]/2, origin[1]+windowSize[1]/2)
	return Vector2(vec[0]+true_origin[0], true_origin[1]+vec[1])
