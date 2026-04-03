extends Control

@export var window_size :Vector2i = DisplayServer.window_get_size()
var window_width :int = window_size.x
var window_height :int = window_size.y 

@export var grid_spacing :int = 100
@export var gridline_thickness :float = 1.0

var isDragging :bool = false
var lastMousePos := Vector2.ZERO
var origin := Vector2.ZERO

var labelOffset = 0

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
	#Draw the vertical lines of the grid
	for x in range(0, 2*(int(window_size.x)), grid_spacing):
		var color = Color(0.5, 0.5, 0.5)
		#offset values the pixel positions of the graph objects 
		#have from their original positions when the origin was at initialization
		var refreshedPosition :Array = refresh_pixel_positions(origin.x, origin.y)
		var xOffset :float = refreshedPosition[0]
		var yOffset :float = refreshedPosition[1]
		#draw vertical gridline
		draw_line(Vector2(x+xOffset, yOffset-grid_spacing), Vector2(x+xOffset, 2*window_size.y+yOffset-grid_spacing), color, gridline_thickness)
		#draw an x-axis tick
		var xTickPos = window_height/2
		draw_line(Vector2(x+xOffset, xTickPos-grid_spacing/5+origin.y), Vector2(x+xOffset, xTickPos+grid_spacing/5+origin.y), Color(0.0, 0.0, 0.0, 1.0), 5*gridline_thickness)
		#draw the number label above the x-axis tick
		var text_width = 25
		var draw_position = Vector2(x+xOffset-text_width/3, xTickPos-grid_spacing/5+origin.y-grid_spacing/15)
		var text_to_draw = str((x-window_width/2)/grid_spacing - int((origin.x-sign(origin.x))/grid_spacing))
		var text_color = Color(0.541, 0.565, 0.541, 1.0) # White color
		draw_string(ThemeDB.fallback_font, draw_position, text_to_draw, HORIZONTAL_ALIGNMENT_LEFT, 100, text_width, text_color)
	#Draw the horizontal lines of the grid
	for y in range(0, 2*(int(window_size.y)), grid_spacing):
		var color = Color(0.5, 0.5, 0.5)
		#offset values the pixel positions of the graph objects 
		#have from their original positions when the origin was at initialization
		var refreshedPosition :Array = refresh_pixel_positions(origin.x, origin.y)
		var xOffset :float = refreshedPosition[0]
		var yOffset :float = refreshedPosition[1]
		#Draw horizontal gridline
		draw_line(Vector2(xOffset-grid_spacing, y+yOffset), Vector2(2*window_size.x+xOffset-grid_spacing, y+yOffset), color, gridline_thickness)
		#draw a y-axis tick
		var yTickPos = window_width/2
		draw_line(Vector2(yTickPos-grid_spacing/5+origin.x, y+yOffset), Vector2(yTickPos+grid_spacing/5+origin.x, y+yOffset), Color(0.0, 0.0, 0.0, 1.0), 5*gridline_thickness)
		#draw the number label above the y-axis tick
		var text_width = 25
		var draw_position = Vector2(yTickPos+grid_spacing/15+origin.x, y+yOffset-text_width/3)
		var text_to_draw = str(-1*((y-window_height/2)/grid_spacing - int((origin.y-sign(origin.y))/grid_spacing)))
		var text_color = Color(0.541, 0.565, 0.541, 1.0) # White color
		draw_string(ThemeDB.fallback_font, draw_position, text_to_draw, HORIZONTAL_ALIGNMENT_LEFT, 100, text_width, text_color)
	#Draw x-axis
	draw_line(Vector2(-origin.x, window_height/2) + origin, Vector2(window_width-origin.x, window_height/2) + origin, Color(0.0, 0.0, 0.0, 1.0), 5*gridline_thickness)
	#draw y-axis
	draw_line(Vector2(window_width/2, -origin.y) + origin, Vector2(window_width/2, window_height-origin.y) + origin, Color(0.0, 0.0, 0.0, 1.0), 5*gridline_thickness)
	queue_redraw()
	
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
