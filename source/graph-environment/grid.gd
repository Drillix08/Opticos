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
	#offset values the pixel positions of the graph objects 
	#have from their original positions when the origin was at initialization
	var refreshedPosition :Array = refresh_pixel_positions(origin.x, origin.y)
	var xOffset :float = refreshedPosition[0]
	var yOffset :float = refreshedPosition[1]
		
	#Draw the vertical lines of the grid
	for x in range(0, 2*(int(windowSize.x)), grid_spacing):
		var color := Color(0.3, 0.3, 0.3)
		@warning_ignore("integer_division")
		if (x / grid_spacing) % major_every == 0:
			color = Color(0.5, 0.5, 0.5)
		#Draw solid line
		draw_line(Vector2(x+xOffset, yOffset-5*grid_spacing), Vector2(x+xOffset, 2*windowSize.y+yOffset-5*grid_spacing), color)

	#Draw the horizontal lines of the grid
	for y in range(0, 2*(int(windowSize.y)), grid_spacing):
		var color := Color(0.3, 0.3, 0.3)
		@warning_ignore("integer_division")
		if (y / grid_spacing) % major_every == 0:
			color = Color(0.5, 0.5, 0.5)
		#Draw solid line
		draw_line(Vector2(xOffset-5*grid_spacing, y+yOffset), Vector2(2*windowSize.x+xOffset-5*grid_spacing, y+yOffset), color)
	
	#Draw the x and y axes
	draw_line(Vector2(0, 300 + origin.y), Vector2(1000, 300 + origin.y), Color(0.0, 0.0, 0.0, 1.0), 5.0)
	draw_line(Vector2(500 + origin.x, 0), Vector2(500 + origin.x, 600), Color(0.0, 0.0, 0.0, 1.0), 5.0)
	
	var full_screen_rect: Rect2 = Rect2(Vector2(0,0) + origin, Vector2(windowSize.x, windowSize.y))
	#var full_screen_rect: Rect2 = Rect2(Vector2(495,295) + origin, Vector2(10,10))
	draw_rect(full_screen_rect, Color(255,0,0,.15))
	LineRectMethod(full_screen_rect, 10, Color(255,0,0, .15))

func _process(delta: float):
	print(1)
	var windowSize :Vector2i = DisplayServer.window_get_size()
	var full_screen_rect: Rect2 = Rect2(Vector2(0,0), Vector2(windowSize.x, windowSize.y))
	#var full_screen_rect: Rect2 = Rect2(Vector2(495,295) + origin, Vector2(10,10))
	draw_rect(full_screen_rect, Color(255,0,0,.15))
	LineRectMethod(full_screen_rect, 10, Color(255,0,0, .15))
	

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

func LineRectMethod(rect: Rect2, maxSize: int, color: Color):
	if(rect.size.x <= maxSize): return
	var newColor = Color(color.r, color.g, color.b, color.a+.05)
	var topLeft = Rect2(Vector2(rect.position.x, rect.position.y), rect.size/2)
	var topRight = Rect2(Vector2(rect.position.x+rect.size.x/2, rect.position.y), rect.size/2)
	var bottomLeft = Rect2(Vector2(rect.position.x, rect.position.y+rect.size.y/2), rect.size/2)
	var bottomRight = Rect2(Vector2(rect.position.x+rect.size.x/2, rect.position.y+rect.size.y/2), rect.size/2)
	if(solutionIn(topLeft)): 
		draw_rect(topLeft, newColor)
		LineRectMethod(topLeft, maxSize, newColor)
	if(solutionIn(topRight)): 
		draw_rect(topRight, newColor)
		LineRectMethod(topRight, maxSize, newColor)
	if(solutionIn(bottomLeft)): 
		draw_rect(bottomLeft, newColor)
		LineRectMethod(bottomLeft, maxSize, newColor)
	if(solutionIn(bottomRight)): 
		draw_rect(bottomRight, newColor)
		LineRectMethod(bottomRight, maxSize, newColor)
	
func solutionIn(rect: Rect2) -> int:
	var topLeftCoord = Vector2(rect.position.x-origin.x - 500, -(rect.position.y-origin.y-300))
	#var topRightCoord = Vector2(rect.position.x - 500, -(rect.position.y+rect.size.y-300)) - origin
	#var bottomLeftCoord = Vector2(rect.position.x+rect.size.x - 500, -(rect.position.y-300)) - origin
	var bottomRightCoord = Vector2(rect.position.x-origin.x+rect.size.x - 500, -(rect.position.y-origin.y+rect.size.y-300))
	if(topLeftCoord.x*topLeftCoord.x*topLeftCoord.x < topLeftCoord.y && bottomRightCoord.x*bottomRightCoord.x*bottomRightCoord.x < bottomRightCoord.y):
		return 0
	elif(topLeftCoord.x*topLeftCoord.x*topLeftCoord.x > topLeftCoord.y && bottomRightCoord.x*bottomRightCoord.x*bottomRightCoord.x > bottomRightCoord.y):
		return 0
	else:
		return 1
