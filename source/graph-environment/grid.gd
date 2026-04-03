extends Control

@export var window_size :Vector2i = DisplayServer.window_get_size()
var window_width :int = window_size.x
var window_height :int = window_size.y 

@export var grid_spacing :int = 100
@export var gridline_thickness :float = 1.0

var isDragging :bool = false
var lastMousePos := Vector2.ZERO
var origin := Vector2.ZERO

var functionValues: Array[Vector2] = [Vector2(-1, -1)]
var functionLines: Array[Array]

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
		@warning_ignore("integer_division")
		var xTickPos = window_height/2
		@warning_ignore("integer_division")
		draw_line(Vector2(x+xOffset, xTickPos-grid_spacing/5+origin.y), Vector2(x+xOffset, xTickPos+grid_spacing/5+origin.y), Color(0.0, 0.0, 0.0, 1.0), 5*gridline_thickness)
		#draw the number label above the x-axis tick
		var text_width = 25
		@warning_ignore("integer_division")
		var draw_position = Vector2(x+xOffset-text_width/3, xTickPos-grid_spacing/5+origin.y-grid_spacing/15)
		@warning_ignore("integer_division")
		var text_to_draw = str((x-window_width/2)/grid_spacing - int((origin.x-sign(origin.x))/grid_spacing))
		var text_color = Color(0.541, 0.565, 0.541, 1.0) # White color
		if(text_to_draw != "0"): draw_string(ThemeDB.fallback_font, draw_position, text_to_draw, HORIZONTAL_ALIGNMENT_LEFT, 100, text_width, text_color)
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
		@warning_ignore("integer_division")
		var yTickPos = window_width/2
		@warning_ignore("integer_division")
		draw_line(Vector2(yTickPos-grid_spacing/5+origin.x, y+yOffset), Vector2(yTickPos+grid_spacing/5+origin.x, y+yOffset), Color(0.0, 0.0, 0.0, 1.0), 5*gridline_thickness)
		#draw the number label above the y-axis tick
		var text_width = 25
		@warning_ignore("integer_division")
		var draw_position = Vector2(yTickPos+grid_spacing/15+origin.x, y+yOffset-text_width/3)
		@warning_ignore("integer_division")
		var text_to_draw = str(-1*((y-window_height/2)/grid_spacing - int((origin.y-sign(origin.y))/grid_spacing)))
		var text_color = Color(0.541, 0.565, 0.541, 1.0) # White color
		draw_string(ThemeDB.fallback_font, draw_position, text_to_draw, HORIZONTAL_ALIGNMENT_LEFT, 100, text_width, text_color)
	#Draw x-axis
	@warning_ignore("integer_division")
	draw_line(Vector2(-origin.x, window_height/2) + origin, Vector2(window_width-origin.x, window_height/2) + origin, Color(0.0, 0.0, 0.0, 1.0), 5*gridline_thickness)
	#draw y-axis
	@warning_ignore("integer_division")
	draw_line(Vector2(window_width/2, -origin.y) + origin, Vector2(window_width/2, window_height-origin.y) + origin, Color(0.0, 0.0, 0.0, 1.0), 5*gridline_thickness)
	
	queue_redraw()
	
	#Draw the function
	draw_function(func(x):
		return x**2
	)
	
#controlls the moving of the "camera" when you click and drag
func _input(event):
	if($Animator.animating):
		if Input.is_key_pressed(KEY_LEFT):
			$Animator._on_back_pressed()
		if Input.is_key_pressed(KEY_RIGHT):
			$Animator._on_next_pressed()
		if Input.is_key_pressed(KEY_SPACE):
			$Animator._on_play_pause_pressed()
		return
	if event is InputEventMouseButton\
	and event.button_index == MOUSE_BUTTON_LEFT:
		isDragging = event.pressed
		lastMousePos = event.position
	if event is InputEventMouseMotion and isDragging:
		var delta :Vector2 = event.position - lastMousePos
		origin += delta
		lastMousePos = event.position
		$Animator.animProgLeft = Util.convert_to_real_coords(origin, Vector2(-1,0)).x
		queue_redraw()
	if event.is_action_pressed("zoom_in"):
		print("scroll")
	if event.is_action_pressed("ui_accept"):
		$Animator.prepare_to_animate(functionValues, origin, grid_spacing, functionLines)
		$Animator.animProgLeft = Util.convert_to_real_coords(origin, Vector2(0,0)).x
		$Animator.animate_Limit(400, functionValues, true, true, .005, 1)
	if Input.is_key_pressed(KEY_D):
		$Animator.prepare_to_animate(functionValues, origin, grid_spacing, functionLines)
		$Animator.animate_derivative(1)
	if Input.is_key_pressed(KEY_I):
		$Animator.prepare_to_animate(functionValues, origin, grid_spacing, functionLines)
		# LEFT, RIGHT
		$Animator.animate_Integral("LEFT")
## This function will draw the graph of the function specified by input_function
## The argument of this function should be a function that takes a single argument x and returns y
func draw_function(input_function: Callable):
	functionLines.clear()
	var windowSize :Vector2i = DisplayServer.window_get_size()
	var left: float = -(origin.x + windowSize.x/2.0)
	var right: float = left + windowSize.x
	var top: float = origin.y + (windowSize.y / 2.0)
	var bottom: float = origin.y - (windowSize.y / 2.0)
	if(!$Animator.animating): functionValues = [Vector2(-1, -1)]

	while(left < right):
		var x0: float = (left)/grid_spacing
		var x1: float = (left+1)/grid_spacing
		var y0: float = input_function.call(x0)
		var y1: float = input_function.call(x1)

		# figure out the starting point of functions with a left-asymptote
		if is_nan(y0) && !is_nan(y1):
			var initialX = x1;
			var initialY = y1;
			var step: float = 1.0 / grid_spacing
			for i in range(16):
				step /= 2
				# try moving x0 forward
				x0 += step;
				y0 = input_function.call(x0)
				y1 = input_function.call(x1)
				if absf(y0) == INF || absf(y1) == INF: break
				if !is_nan(y0):
					# Went too far
					x0 -= step
					x1 -= step
			y0 = input_function.call(x0)
			y1 = input_function.call(x1)
			if is_nan(y0) || absf(y0) > absf(y1): 
				y0 = y1 * INF
				y1 = initialY
				x1 = initialX
			elif is_nan(y1) || absf(y1) > absf(y0):
				y1 = y0 * INF
				y0 = initialY
				x0 = initialX

		# figure out the starting point of functions with a right-asymptote
		elif !is_nan(y0) && is_nan(y1):
			var initialX = x1;
			var initialY = y1;
			var step: float = 1.0 / grid_spacing
			for i in range(16):
				step /= 2
				# try moving x1 backward
				x1 -= step;
				y0 = input_function.call(x0)
				y1 = input_function.call(x1)
				if absf(y0) == INF || absf(y1) == INF: break
				if !is_nan(y1):
					# Went too far
					x0 += step
					x1 += step

			y0 = input_function.call(x0)
			y1 = input_function.call(x1)
			if is_nan(y0) || absf(y0) > absf(y1): 
				y0 = y1 * INF
				y1 = initialY
				x1 = initialX
			elif is_nan(y1) || absf(y1) > absf(y0):
				y1 = y0 * INF
				y0 = initialY
				x0 = initialX

		# figure out other types of asymptotes
		elif absf(y0 - y1) > 200:
			var max_jump: float = absf(y0 - y1)
			
			var step: float = 1.0 / grid_spacing
			for i in range(16):
				step /= 2
				# try to move x0 forward
				x0 += step
				y0 = input_function.call(x0)
				y1 = input_function.call(x1)
				
				if absf(y0 - y1) > max_jump:
					max_jump = absf(y0 - y1)
					continue # Worked! So move on
				
				# Went too far, try moving x1 back instead
				x0 -= step
				x1 -= step
				y0 = input_function.call(x0)
				y1 = input_function.call(x1)
				if absf(y0 - y1) > max_jump:
					max_jump = absf(y0 - y1)
					continue # Worked! So move on
					
				# Still too far, reset back to initial to try again
				# With a smaller step size
				x1 += step

			# If we narrowed the jump down to a small enough step size,
			# while still maintaing the size of the jump,
			# then it's likely an asymptote
			if x1 - x0 < 0.0001:
				left += 1
				continue
		
		# Actually drawing the line with the correct spacing:
		x0 *= grid_spacing
		x1 *= grid_spacing
		y0 *= grid_spacing
		y1 *= grid_spacing
		if y0 == INF: y0 = top
		if y0 == -INF: y0 = bottom
		if y1 == INF: y1 = top
		if y1 == -INF: y1 = bottom
		if ($Animator.animating && $Animator.animProgLeft > x1): draw_line(Util.convert_to_godot_coords(origin, Vector2(x0, y0)), Util.convert_to_godot_coords(origin, Vector2(x1, y1)), Color.YELLOW, 2)
		elif($Animator.animating && $Animator.animProgRight < x0): draw_line(Util.convert_to_godot_coords(origin, Vector2(x0, y0)), Util.convert_to_godot_coords(origin, Vector2(x1, y1)), Color.YELLOW, 2)
		else: 
			draw_line(Util.convert_to_godot_coords(origin, Vector2(x0, y0)), Util.convert_to_godot_coords(origin, Vector2(x1, y1)), Color.RED, 2)
			var line: Array[Vector2]
			line.append(Util.convert_to_godot_coords(origin, Vector2(x0, y0))) 
			line.append(Util.convert_to_godot_coords(origin, Vector2(x1, y1)))
			functionLines.append(line)
		if(!$Animator.animating): functionValues.append(Util.convert_to_godot_coords(origin, Vector2(x0,y0)))
		left += 1;
	return functionValues
