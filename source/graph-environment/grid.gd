extends Control

@export var window_size :Vector2i = DisplayServer.window_get_size()
var window_width :int = window_size.x
var window_height :int = window_size.y 

@export var grid_spacing :int = 100
@export var gridline_thickness :float = 1.0

var isDragging :bool = false
var lastMousePos := Vector2.ZERO
var origin := Vector2.ZERO
signal do_something
var pause: bool = false
var frameOffset: int = 0
var functionValues: Array[Vector2] = [Vector2(-1, -1)]
var animProgLeft: float = Util.convert_to_real_coords(origin, Vector2(-1,0)).x
var animProgRight: float = Util.convert_to_real_coords(origin, Vector2(200000,0)).x
var animating: bool = false

# for derivative
var secant_line_left: Vector2 = Vector2(0, 0)
var secant_line_right: Vector2 = Vector2(0, 0)

# for integration
var rectangles: Array[Rect2]

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
	
	#draw_line(Vector2(0.0, 385.0076), Vector2(1000.0, 646.5566), Color.YELLOW)

	queue_redraw()
	
	#Draw the function
	draw_function(func(x):
		return tan(x)
	)
	
	draw_line(secant_line_left, secant_line_right, Color.YELLOW)
	for rectangle in rectangles: 
		draw_rect(rectangle, Color.YELLOW) 
		if rectangle.size[0] > 1: # do not draw the border on the final iteration
			draw_rect(rectangle, Color.BLACK, false, 1) # rectangle outline
	
#controlls the moving of the "camera" when you click and drag
func _input(event):
	if(animating):
		if Input.is_key_pressed(KEY_LEFT):
			_on_back_pressed()
		if Input.is_key_pressed(KEY_RIGHT) and animating:
			_on_next_pressed()
		return
	if event is InputEventMouseButton\
	and event.button_index == MOUSE_BUTTON_LEFT:
		isDragging = event.pressed
		lastMousePos = event.position
	if event is InputEventMouseMotion and isDragging:
		var delta :Vector2 = event.position - lastMousePos
		origin += delta
		lastMousePos = event.position
		animProgLeft = Util.convert_to_real_coords(origin, Vector2(-1,0)).x
		queue_redraw()
	if event.is_action_pressed("zoom_in"):
		print("scroll")
	if event.is_action_pressed("ui_accept"):
		animProgLeft = Util.convert_to_real_coords(origin, Vector2(0,0)).x
		animate_Limit(200, functionValues, true, true, .015, 1.001)
	if Input.is_key_pressed(KEY_D):
		animate_derivative(1)
	if Input.is_key_pressed(KEY_I):
		# LEFT, RIGHT, TRAPEZOIDAL
		animate_Integral("LEFT")

## This function will draw the graph of the function specified by input_function
## The argument of this function should be a function that takes a single argument x and returns y
func draw_function(input_function: Callable):
	var windowSize :Vector2i = DisplayServer.window_get_size()
	var left: float = -(origin.x + windowSize.x/2.0)
	var right: float = left + windowSize.x
	var top: float = origin.y + (windowSize.y / 2.0)
	var bottom: float = origin.y - (windowSize.y / 2.0)
	if(!animating): functionValues = [Vector2(-1, -1)]

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
		if (animating && animProgLeft > x1): draw_line(Util.convert_to_godot_coords(origin, Vector2(x0, y0)), Util.convert_to_godot_coords(origin, Vector2(x1, y1)), Color.YELLOW, 2)
		elif(animating && animProgRight < x0): draw_line(Util.convert_to_godot_coords(origin, Vector2(x0, y0)), Util.convert_to_godot_coords(origin, Vector2(x1, y1)), Color.YELLOW, 2)
		else: draw_line(Util.convert_to_godot_coords(origin, Vector2(x0, y0)), Util.convert_to_godot_coords(origin, Vector2(x1, y1)), Color.RED, 2)
		if(!animating): functionValues.append(Util.convert_to_godot_coords(origin, Vector2(x0,y0)))
		left += 1;
	return functionValues

## Function for animating values approaching a limit from left and/or right position
## initially at [code]speed[/code] seconds per point slowing at a rate of [code]rate[/code] per point
func animate_Limit(limit: float, points: Array[Vector2], left: bool, right: bool, speed: float, rate: float, step: int = 1):
	step -= 1
	if(!(right || left)): return 
	animating = true
	var endpoint: float = Util.convert_to_godot_coords(origin, Vector2(limit,0)).x
	var limit_point: TextureRect = null
	for coords in points:
		if coords.x == limit:
			limit_point = TextureRect.new()
			limit_point.texture = load("res://Black_Circle.png")
			limit_point.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			limit_point.size = Vector2(20, 20)
			limit_point.position = coords - Vector2(10, 10)
			add_child(limit_point)
			break
	var rect: TextureRect = null
	var rect2: TextureRect = null
	if(left): 
		rect = TextureRect.new()
		rect.position = Vector2(0,0)
		rect.texture = load("res://Yellow_Circle.png")
		rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		rect.size = Vector2(10, 10)
		add_child(rect)
	if(right):
		rect2 = TextureRect.new()
		rect2.position = Vector2(0,0)
		rect2.texture = load("res://Yellow_Circle.png")
		rect2.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		rect2.size = Vector2(10, 10)
		add_child(rect2)
	
	var coordLabel: CoordLabel = null
	var coordLabel2: CoordLabel = null
	var rDone: bool = true
	if right: rDone = false
	if(left):
		coordLabel = CoordLabel.new()
		add_child(coordLabel)
	if(right):
		coordLabel2 = CoordLabel.new()
		add_child(coordLabel2)
	$AnimationControls.visible = true
	if(endpoint < 0):
		return
	var i: int = 1
	var j: int = 0
	while (i < points.size()):
		if(pause):
			await do_something
			if(i != 1): i += frameOffset
			if(frameOffset != 0 && i - step > 0): i -= step
			if(frameOffset == 0 && i + step < points.size()): i += step
			if(j > 2): j += frameOffset
			if(frameOffset != 0 && j - step > 2): j -= step
			if(frameOffset == 0 && j + step < points.size()): j += step
			frameOffset = 0
		if(i + 1 != points.size() && points[i + 1].x > limit && rDone): break
		#print(points[i])
		if(left): 
			if(points[i].x < limit):
				var coords: Vector2 = Util.convert_to_real_coords(origin, points[i])
				animProgLeft = Util.convert_to_real_coords(origin, Vector2(i, 0)).x
				coordLabel.text = "(%.0f, " % coords.x + "%.3f" % coords.y + ")"
				rect.position = points[i] - rect.size/2
				coordLabel.position = rect.position + rect.size/2
				coordLabel.check_coords()
		if(right && j != 0): 
			if(points[points.size() - j].x > limit):
				animProgRight = Util.convert_to_real_coords(origin, Vector2(window_size.x - j, 0)).x
				var coords2: Vector2 = Util.convert_to_real_coords(origin, points[points.size() - j])
				coordLabel2.text = "(%.0f, " % coords2.x + "%.3f" % coords2.y + ")"
				rect2.position = points[points.size() - j] - rect2.size/2
				coordLabel2.position = rect2.position + rect2.size/2
				coordLabel2.check_coords()
			else: rDone = true
		elif(right):
			if(coordLabel != null && coordLabel.position.x + coordLabel.size.x > coordLabel2.position.x && coordLabel.position.y < coordLabel2.position.y + coordLabel2.size.y):
				coordLabel2.position.y = coordLabel2.position.y - coordLabel2.size.y
			coordLabel2.check_coords()
		await get_tree().create_timer(speed).timeout
		speed *= rate
		i += 1
		if(i != 1): j += 1
		queue_redraw()
	animProgLeft = Util.convert_to_real_coords(origin, Vector2(-1,0)).x
	animProgRight = Util.convert_to_real_coords(origin, Vector2(200000,0)).x
	animating = false
	$AnimationControls.visible = false
	if(left): 
		rect.queue_free()
		coordLabel.queue_free()
	if(right):
		rect2.queue_free()
		coordLabel2.queue_free()
	limit_point.queue_free()
	
# using limit definition of derivative
# f'(x) = lim_{h->0} ( f(x+h) - f(x) ) / h
func animate_derivative(x: float):
	animating = true
	$AnimationControls.visible = true
	
	# display box for equation of line
	var line_slope: CoordLabel = CoordLabel.new()
	line_slope.position = Vector2(10, 50)
	add_child(line_slope)
	
	x = floorf(x*grid_spacing) 
	var target: Vector2
	var target_point = TextureRect.new()
	# finding point representing x in functionValues
	var found = false
	for point in functionValues:
		if Util.convert_to_real_coords(origin, point)[0] == x:
			target = Util.convert_to_real_coords(origin, point)/grid_spacing
			#drawing a point at the target derivative location
			target_point.texture = load("res://Solid_Black_Circle.png")
			target_point.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			target_point.size = Vector2(10, 10)
			target_point.position = point - Vector2(5, 5)
			add_child(target_point)
			found = true
			break
	if !found:
		print("Target x coordinate not on screen")
		$AnimationControls.visible = false
		animating = false
		line_slope.free()
		target_point.free()
		return
	
	var speed = .0015
	var i: int = len(functionValues)-1
	
	var rect = TextureRect.new()
	rect.texture = load("res://Yellow_Circle.png")
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.size = Vector2(10, 10)
	add_child(rect)		
	var coordLabel: CoordLabel = CoordLabel.new()
	add_child(coordLabel)
	while Util.convert_to_real_coords(origin, functionValues[i])[0] > int(x):
		# update position of the current position adjusted for offset
		coordLabel.text = "(%.0f, " % Util.convert_to_real_coords(origin, functionValues[i])[0] + "%.3f" % Util.convert_to_real_coords(origin, functionValues[i])[1] + ")"
		rect.position = functionValues[i] - rect.size/2
		coordLabel.position = rect.position + rect.size/2
		if(pause):
			await do_something
			i += frameOffset
			frameOffset = 0
		var pos: Vector2 = Util.convert_to_real_coords(origin, functionValues[i])/grid_spacing # the point representing h
		# calculate the secant line
		# y = mx + b
		var m: float = ( pos[1] - target[1] ) / ( pos[0] - target[0] )
		var b: float = target[1] - m*target[0]
		line_slope.text = "Slope: %.3f" % m
		var left: float = -(origin.x + window_width/2.0)
		var right: float = left + window_width
		var x0: float = (left)/grid_spacing
		var x1: float = (right)/grid_spacing
		var y0: float = m*x0+b
		var y1: float = m*x1+b
		x0 *= grid_spacing
		x1 *= grid_spacing
		y0 *= grid_spacing
		y1 *= grid_spacing
		
		secant_line_left = Util.convert_to_godot_coords(origin, Vector2(x0, y0))
		secant_line_right = Util.convert_to_godot_coords(origin, Vector2(x1, y1))
		queue_redraw()
		await get_tree().create_timer(speed).timeout
		i -= 1
	#perform one more update after the fact
	coordLabel.text = "(%.0f, " % Util.convert_to_real_coords(origin, functionValues[i])[0] + "%.3f" % Util.convert_to_real_coords(origin, functionValues[i])[1] + ")"
	rect.position = functionValues[i] - rect.size/2
	coordLabel.position = rect.position + rect.size/2
	
	$AnimationControls.visible = false
	animating = false
	animProgLeft = Util.convert_to_real_coords(origin, Vector2(-1,0)).x
	
	# freeing components added to the script
	rect.free()
	line_slope.free()
	coordLabel.free()
	target_point.free()
	secant_line_left = Vector2.ZERO
	secant_line_right = Vector2.ZERO
	queue_redraw()
	
func animate_Integral(type: String):
	if type not in ["LEFT", "RIGHT"]:
		print("Invalid argument")
		return
	animating = true
	$AnimationControls.visible = true
	
	#var speed = .0015
	var speed = 1
	var maxRectangleCount: int = len(functionValues)-2
	var currentRectangleCount: int = 2
	while currentRectangleCount <= maxRectangleCount:
		if(pause): 
			await do_something
			frameOffset = 0
		@warning_ignore("integer_division")
		var increment = maxRectangleCount/currentRectangleCount
		
		# left side Riemann sum
		for i in range(1, maxRectangleCount-increment, increment):
			var rect_position: Vector2
			if type == "LEFT":
				rect_position = functionValues[i]
			elif type == "RIGHT":
				rect_position = functionValues[i+increment-1]
				rect_position[0] -= increment
			var width: float = increment
			var height: float = Util.convert_to_real_coords(origin, rect_position)[1]
			var rect_size: Vector2 = Vector2(width, height)
			rectangles.append(Rect2(rect_position, rect_size))
		# calculate current area
		queue_redraw()
		await get_tree().create_timer(speed).timeout
		rectangles.clear()
		currentRectangleCount *= 2
	queue_redraw()
	animating = false
	$AnimationControls.visible = false
	
func _on_play_pause_pressed() -> void:
	pause = !pause
	if(!pause): 
		do_something.emit()
		$AnimationControls/PlayPause.text = "Pause"
	else:
		$AnimationControls/PlayPause.text = "Play"

func _on_next_pressed() -> void:
	do_something.emit()

func _on_back_pressed() -> void:
	if(pause): frameOffset = -2
	do_something.emit()
