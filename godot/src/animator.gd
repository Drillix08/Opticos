extends Control
const Util = preload("res://src/util.gd")

signal step_frame(something: int)
signal leftProg(n: int)
signal rightProg(n: int)
var animating: bool = false
var speed_multiplier: float = 1.0

var lineColor = Color.YELLOW
var functionColor = Color.RED

var window_size :Vector2i = DisplayServer.window_get_size()
var window_width :int = window_size.x
var window_height :int = window_size.y 

var origin: Vector2
var grid_spacing :int = 100
var gridline_thickness :float = 1.0

var functionValues: Array[Vector2] = [Vector2(-1, -1)]
var functionLines: Array[Array]
var animProgLeft: float = Util.convert_to_real_coords(origin, Vector2(-1,0)).x
var animProgRight: float = Util.convert_to_real_coords(origin, Vector2(200000,0)).x

var pause: bool = false
var frameOffset: int = 0

# for limit
var animating_limit = false
var limit: float
var points: Array[Vector2]
var left: bool
var leftPosition: int = -1
var right: bool
var rightPosition: int = -1
var limit_point: TextureRect = null
var rectLeft: TextureRect = null
var rectRight: TextureRect = null
var coordLabelLeft: CoordLabel = null
var coordLabelRight: CoordLabel = null

# for derivative
var secant_line_left: Vector2 = Vector2(0, 0)
var secant_line_right: Vector2 = Vector2(0, 0)

# for integration
var rectangles: Array[Rect2]

var labelOffset = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


func _draw() -> void:
	const LABEL_LIMIT = 64
	const X_LABEL_OFFSET = 5.0
	const TOP_LABEL_OFFSET = 10.0
	const BOTTOM_LABEL_OFFSET = 20.0
	draw_line(secant_line_left, secant_line_right, lineColor)
	for rectangle in rectangles: 
		draw_rect(rectangle, lineColor)
		if rectangle.size[0] > 1: # do not draw the border on the final iteration
			draw_rect(rectangle, Color.BLACK, false, 1) # rectangle outline
		# Draw function value labels
		if len(rectangles) <= LABEL_LIMIT:
			var height_label_y_pos = rectangle.position.y
			var width_label_y_pos = rectangle.position.y + rectangle.size.y
			if rectangle.size.y >= 0:
				height_label_y_pos -= TOP_LABEL_OFFSET
				width_label_y_pos += BOTTOM_LABEL_OFFSET
			else:
				height_label_y_pos += BOTTOM_LABEL_OFFSET
				width_label_y_pos -= TOP_LABEL_OFFSET
			# Rectangle height label
			#draw_string(ThemeDB.fallback_font,
			#		Vector2(rectangle.position.x + X_LABEL_OFFSET, height_label_y_pos),
			#		"%.1f" % rectangle.size.y)
			# Rectangle width label
			#draw_string(ThemeDB.fallback_font,
			#		Vector2(rectangle.position.x + X_LABEL_OFFSET, width_label_y_pos),
			#		"%.1f" % rectangle.size.x)
	# this if for drawing on top of integral
	for line in functionLines:
		if(line[0].x < animProgLeft || line[1].x > animProgRight): draw_line(line[0], line[1], lineColor, 2)
		else: draw_line(line[0], line[1], functionColor, 2)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if (pause):
		pass
	else:
		if (animating_limit):
			animate_Limit_Step()

func prepare_to_animate(_function_values: Array[Vector2], _origin: Vector2, _grid_spacing: int, _functionLines: Array[Array]):
	functionValues = _function_values
	functionLines = _functionLines
	origin = _origin
	grid_spacing = _grid_spacing

func update_position(point: Vector2, rect: TextureRect, label: CoordLabel):
	var coords: Vector2 = Util.convert_to_real_coords(origin, point)
	label.text = "(%.2f, " % (coords.x/100.0) + "%.2f" % (coords.y/100) + ")"

	rect.position = point - rect.size/2
	label.position = rect.position + rect.size/2
	label.check_coords()

## Function for animating values approaching a limit from left and/or right position
## initially at [code]speed[/code] seconds per point slowing at a rate of [code]rate[/code] per point
func animate_Limit(_limit: float, _points: Array[Vector2], _left: bool, _right: bool):
	if (!_right && !_left): return
	
	animating = true
	animating_limit = true;
	$AnimationControls.visible = true
	limit = _limit
	points = _points
	left = _left
	right = _right
	
	limit_point = TextureRect.new()
	add_child(limit_point)
	
	rectLeft = TextureRect.new()
	add_child(rectLeft)
	coordLabelLeft = CoordLabel.new()
	add_child(coordLabelLeft)
	
	rectRight = TextureRect.new()
	add_child(rectRight)
	coordLabelRight = CoordLabel.new()
	add_child(coordLabelRight)

func stop_animate_limit():
	animating = false
	$AnimationControls.visible = false
	animating_limit = false;
	pause = false;
	animProgLeft = Util.convert_to_real_coords(origin, Vector2(-1,0)).x
	animProgRight = Util.convert_to_real_coords(origin, Vector2(200000,0)).x
	functionLines.clear()
	leftPosition = -1
	rightPosition = -1
	
	limit_point.queue_free()
	limit_point = null
	
	rectLeft.queue_free()
	rectRight.queue_free()
	coordLabelLeft.queue_free()
	coordLabelRight.queue_free()
	rectLeft = null
	rectRight = null
	coordLabelLeft = null
	coordLabelRight = null

func animate_Limit_Step():
	var endpoint: float = Util.convert_to_godot_coords(origin, Vector2(limit*grid_spacing,0)).x
	if(endpoint < 0 || endpoint > window_size.x): 
		stop_animate_limit()
		return
	
	#step -= 1
	for coords in points:
		if coords.x == endpoint:
			limit_point.texture = load("res://assets/graph_environment/black_circle.png")
			limit_point.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			limit_point.size = Vector2(20, 20)
			limit_point.position = coords - Vector2(10, 10)
			#print("position: " + str(limit_point.position))
			break

	if(left): 
		rectLeft.texture = load("res://assets/graph_environment/yellow_circle.png")
		rectLeft.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		rectLeft.size = Vector2(10, 10)
	if(right):
		rectRight.texture = load("res://assets/graph_environment/yellow_circle.png")
		rectRight.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		rectRight.size = Vector2(10, 10)
	
	var initialDistanceFromLimit = max(endpoint, abs(window_size.x - endpoint))
	var distanceFromLimit = initialDistanceFromLimit
	if (leftPosition == -1):
		leftPosition = endpoint - initialDistanceFromLimit
	else:
		distanceFromLimit = endpoint - leftPosition
	if (rightPosition == -1):
		rightPosition = endpoint + initialDistanceFromLimit
	
	var percent_done = 1 - (distanceFromLimit / initialDistanceFromLimit)
	print(percent_done)
	var speed = (1) * speed_multiplier

	if(leftPosition <= endpoint):
		if(leftPosition == endpoint): _on_play_pause_pressed()
		
		#Paused stuff
		if(pause):
			var action: int = await step_frame
			if(action == -1): #back
				leftPosition -= 2
				rightPosition += 2
			elif(action == 0): #Play
				if(leftPosition != endpoint):
					leftPosition -= 1
					rightPosition += 1
					
		#updating positions
		if (left):
			if (leftPosition >= 0): 
				rectLeft.visible = true
				coordLabelLeft.visible = true
				update_position(functionValues[leftPosition], rectLeft, coordLabelLeft)
			else:
				rectLeft.visible = false
				coordLabelLeft.visible = false
				
		if (right):
			if (rightPosition + 1 <= window_size.x): 
				rectRight.visible = true
				coordLabelRight.visible = true
				update_position(functionValues[rightPosition], rectRight, coordLabelRight)
			else:
				rectRight.visible = false
				coordLabelRight.visible = false
		
		if(coordLabelLeft != null && coordLabelRight != null && coordLabelLeft.position.x + coordLabelLeft.size.x > coordLabelRight.position.x && coordLabelLeft.position.y < coordLabelRight.position.y + coordLabelRight.size.y):
			coordLabelRight.position.y = coordLabelRight.position.y - coordLabelRight.size.y
			coordLabelRight.check_coords()
		distanceFromLimit -= speed
		leftPosition += speed
		rightPosition -= speed
		
		if(left): animProgLeft = leftPosition
		if(right): animProgRight = rightPosition
		queue_redraw()
		
	else:
		print("Stopped")
		stop_animate_limit()
	


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
			target_point.texture = load("res://assets/graph_environment/solid_black_circle.png")
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
	rect.texture = load("res://assets/graph_environment/yellow_circle.png")
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.size = Vector2(10, 10)
	add_child(rect)		
	var coordLabel: CoordLabel = CoordLabel.new()
	add_child(coordLabel)
	while Util.convert_to_real_coords(origin, functionValues[i])[0] > int(x):
		# update position of the current position adjusted for offset
		coordLabel.text = "(%.3f, " % (Util.convert_to_real_coords(origin, functionValues[i])[0]/grid_spacing) + "%.3f" % (Util.convert_to_real_coords(origin, functionValues[i])[1]/grid_spacing) + ")"
		rect.position = functionValues[i] - rect.size/2
		coordLabel.position = rect.position + rect.size/2
		if(pause):
			var action: int = await step_frame
			if action == -1:
				i += 2
				i = min(i, len(functionValues))
			if action == 0:
				i += 1
				i = min(i, len(functionValues))
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
		await get_tree().create_timer(speed * speed_multiplier).timeout
		i -= 1
	#perform one more update after the fact
	coordLabel.text = "(%.0f, " % Util.convert_to_real_coords(origin, functionValues[i])[0] + "%.3f" % Util.convert_to_real_coords(origin, functionValues[i])[1] + ")"
	rect.position = functionValues[i] - rect.size/2
	coordLabel.position = rect.position + rect.size/2
	
	$AnimationControls.visible = false
	animating = false
	pause = false
	animProgLeft = Util.convert_to_real_coords(origin, Vector2(-1,0)).x
	
	# freeing components added to the script
	rect.free()
	line_slope.free()
	coordLabel.free()
	target_point.free()
	secant_line_left = Vector2.ZERO
	secant_line_right = Vector2.ZERO
	functionLines.clear()
	queue_redraw()
	
func animate_Integral(type: String, left_bound: float, right_bound: float, expr: String):
	if type not in ["LEFT", "RIGHT"]:
		print("Invalid argument")
		return
	if right_bound < left_bound: return
	animating = true
	$AnimationControls.visible = true
	
	var area_display: CoordLabel = CoordLabel.new()
	area_display.position = Vector2(10, 50)
	add_child(area_display)
	area_display.text = "Area: 0"
	
	var riemann_formula_panel := RiemannFormulaPanel.new()
	add_child(riemann_formula_panel)

	var definite_integral: float = NAN
	if expr != "":
		definite_integral = MathCoreWrapper.numerical_integrate(expr, "x", left_bound, right_bound)

	# initialize start and end to the left and right bound of the screen
	var true_origin_x: float = origin.x + DisplayServer.window_get_size().x / 2.0

	# pixel index = real_x + true_origin_x
	var start: int = roundi(left_bound * grid_spacing + true_origin_x)
	var end: int = roundi(right_bound * grid_spacing + true_origin_x)

	# Keep inside the valid sample range
	start = clampi(start, 1, len(functionValues) - 2)
	end = clampi(end, 1, len(functionValues) - 2)

	#var speed = .0015
	var speed = 1
	var maxRectangleCount: int = end-start
	var currentRectangleCount: int = 2
	while currentRectangleCount <= maxRectangleCount:
		
		# makes sure that the rectangles cover the whole bounds
		var tempRectangleCount = currentRectangleCount 
		# 3 is the margin of error
		# requiring a lower margin of error introduces the possibility of error
		# for example if it had to be perfectly divisibe, it would break for prime numbers
		while maxRectangleCount % tempRectangleCount > 3:
			tempRectangleCount += 1
			
		@warning_ignore("integer_division")
		var increment = maxRectangleCount/tempRectangleCount
		# left side Riemann sum
		for i in range(start, end-increment+1, increment):
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
		var area = 0
		var riemann_sum: float = 0.0
		for rectangle in rectangles:
			riemann_sum += rectangle.get_area() / (grid_spacing**2)
			if rectangle.size[1] > 0:
				area += rectangle.get_area() / (grid_spacing**2)
			else:
				area -= rectangle.get_area() / (grid_spacing**2)
		area_display.text = "Area: %.3f" % area

		# Update the Riemann sum shown in the side panel
		var is_last_frame: bool = currentRectangleCount * 2 > maxRectangleCount
		riemann_formula_panel.show_riemann(rectangles.size(), right_bound - left_bound, riemann_sum, type == "RIGHT", is_last_frame, definite_integral)

		queue_redraw()
		if !pause:
			await get_tree().create_timer(speed / speed_multiplier).timeout
		else:
			await get_tree().create_timer(0.001).timeout
		rectangles.clear()
		currentRectangleCount *= 2
		if(pause): 
			var action: int = await step_frame
			if action == -1:
				@warning_ignore("integer_division")
				currentRectangleCount /= 4
				currentRectangleCount = max(1, currentRectangleCount)
			if action == 0:
				@warning_ignore("integer_division")
				currentRectangleCount /= 2
				currentRectangleCount = max(1, currentRectangleCount)
	queue_redraw()
	pause = false
	animating = false
	$AnimationControls.visible = false
	functionLines.clear()
	area_display.free()
	riemann_formula_panel.queue_free()
	
func _on_play_pause_pressed() -> void:
	pause = !pause
	if(!pause): 
		step_frame.emit(0)
		$AnimationControls/PlayPause.text = "Pause"
	else:
		$AnimationControls/PlayPause.text = "Play"

func _on_next_pressed() -> void:
	step_frame.emit(1)

func _on_back_pressed() -> void:
	step_frame.emit(-1)


func _on_speed_up_pressed() -> void:
	speed_multiplier = clampf(speed_multiplier * 2, 0.00390625, 256)

func _on_slow_down_pressed() -> void:
	speed_multiplier = clampf(speed_multiplier * 0.5, 0.00390625, 256)
