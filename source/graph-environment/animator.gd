extends Control
signal do_something(something: int)
signal leftProg(n: int)
signal rightProg(n: int)
var animating: bool = false
var stepSize: int = 1
var moveDirection

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
	draw_line(secant_line_left, secant_line_right, Color.YELLOW)
	for rectangle in rectangles: 
		draw_rect(rectangle, Color.YELLOW) 
		if rectangle.size[0] > 1: # do not draw the border on the final iteration
			draw_rect(rectangle, Color.BLACK, false, 1) # rectangle outline
	# this if for drawing on top of integral
	for line in functionLines:
		if(line[0].x < animProgLeft || line[1].x > animProgRight): draw_line(line[0], line[1], Color.YELLOW, 2)
		else: draw_line(line[0], line[1], Color.RED, 2)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func prepare_to_animate(_function_values: Array[Vector2], _origin: Vector2, _grid_spacing: int, _functionLines: Array[Array]):
	functionValues = _function_values
	functionLines = _functionLines
	origin = _origin
	grid_spacing = _grid_spacing

func update_position(point: Vector2, rect: TextureRect, label: CoordLabel):
	var coords: Vector2 = Util.convert_to_real_coords(origin, point)
	label.text = "(%.2f, " % (coords.x/100.0) + "%.4f" % (coords.y/100) + ")"

	rect.position = point - rect.size/2
	label.position = rect.position + rect.size/2
	label.check_coords()
	pass

## Function for animating values approaching a limit from left and/or right position
## initially at [code]speed[/code] seconds per point slowing at a rate of [code]rate[/code] per point
func animate_Limit(limit: float, points: Array[Vector2], left: bool, right: bool, speed: float, rate: float, _step: int = 1):
	if(!(right || left)): return 
	var endpoint: float = Util.convert_to_godot_coords(origin, Vector2(limit,0)).x
	if(endpoint < 0 || endpoint > window_size.x): return
	if(endpoint < 0): return
	#step -= 1
	animating = true
	$AnimationControls.visible = true
	var limit_point: TextureRect = null
	for coords in points:
		if coords.x == endpoint:
			limit_point = TextureRect.new()
			limit_point.texture = load("res://Black_Circle.png")
			limit_point.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			limit_point.size = Vector2(20, 20)
			limit_point.position = coords - Vector2(10, 10)
			add_child(limit_point)
			break

	var rect: TextureRect = null
	var rect2: TextureRect = null
	var coordLabel: CoordLabel = null
	var coordLabel2: CoordLabel = null
	if(left): 
		rect = TextureRect.new()
		rect.position = Vector2(0,0)
		rect.texture = load("res://Yellow_Circle.png")
		rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		rect.size = Vector2(10, 10)
		add_child(rect)
		coordLabel = CoordLabel.new()
		add_child(coordLabel)
	if(right):
		rect2 = TextureRect.new()
		rect2.position = Vector2(0,0)
		rect2.texture = load("res://Yellow_Circle.png")
		rect2.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		rect2.size = Vector2(10, 10)
		add_child(rect2)
		coordLabel2 = CoordLabel.new()
		add_child(coordLabel2)
	var distanceFromLimit = max(endpoint, abs(window_size.x - endpoint))
	print(distanceFromLimit)
	var i: int = endpoint - distanceFromLimit
	var j: int = endpoint + distanceFromLimit
	print(i, " ", j)
	print(endpoint)

	while(i <= endpoint):
		if(i == endpoint): _on_play_pause_pressed()
		#Paused stuff
		if(pause):
			var action: int = await do_something
			if(action == -1): #back
				j += 2
				i -= 2
			elif(action == 0): #Play
				if(i != endpoint):
					j += 1
					i -= 1
		#updating positions
		if(left && i >= 0): 
			rect.visible = true
			coordLabel.visible = true
			update_position(functionValues[i + 1], rect, coordLabel)
		else:
			rect.visible = false
			coordLabel.visible = false
		if(right && j + 1 <= window_size.x): 
			rect2.visible = true
			coordLabel2.visible = true
			update_position(functionValues[j + 1], rect2, coordLabel2)
		else:
			rect2.visible = false
			coordLabel2.visible = false
		if(coordLabel != null && coordLabel.position.x + coordLabel.size.x > coordLabel2.position.x && coordLabel.position.y < coordLabel2.position.y + coordLabel2.size.y):
			coordLabel2.position.y = coordLabel2.position.y - coordLabel2.size.y
			coordLabel2.check_coords()
		i += 1
		j -= 1
		if(left): animProgLeft = i
		if(right): animProgRight = j
		queue_redraw()
		await get_tree().create_timer(speed).timeout
		speed *= rate
	animating = false
	$AnimationControls.visible = false
	if(left): 
		rect.queue_free()
		coordLabel.queue_free()
	if(right):
		rect2.queue_free()
		coordLabel2.queue_free()
	limit_point.queue_free()
	animProgLeft = Util.convert_to_real_coords(origin, Vector2(-1,0)).x
	animProgRight = Util.convert_to_real_coords(origin, Vector2(200000,0)).x
	functionLines = []
	queue_redraw()
	pause = false
	animating = false

	
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
		coordLabel.text = "(%.3f, " % (Util.convert_to_real_coords(origin, functionValues[i])[0]/grid_spacing) + "%.3f" % (Util.convert_to_real_coords(origin, functionValues[i])[1]/grid_spacing) + ")"
		rect.position = functionValues[i] - rect.size/2
		coordLabel.position = rect.position + rect.size/2
		if(pause):
			var action: int = await do_something
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
		await get_tree().create_timer(speed).timeout
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
	
func animate_Integral(type: String, left_bound: float, right_bound: float):
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
	
	# initialize start and end to the left and right bound of the screen
	var start: int = 1
	var end: int = len(functionValues)-2
	for i in range(len(functionValues)):
		if Util.convert_to_real_coords(origin, functionValues[i])[0] == left_bound*grid_spacing:
			if i == 0: start = i + 1
			else: start = i
		if Util.convert_to_real_coords(origin, functionValues[i])[0] == right_bound*grid_spacing:
			end = i
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
		for rectangle in rectangles:
			if rectangle.size[1] > 0:
				area += rectangle.get_area() / (grid_spacing**2)
			else:
				area -= rectangle.get_area() / (grid_spacing**2)
		area_display.text = "Area: %.3f" % area
		queue_redraw()
		if !pause:
			await get_tree().create_timer(speed).timeout
		else:
			await get_tree().create_timer(0.001).timeout
		rectangles.clear()
		currentRectangleCount *= 2
		if(pause): 
			var action: int = await do_something
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
	area_display.free()
	functionLines.clear()
	
func _on_play_pause_pressed() -> void:
	pause = !pause
	if(!pause): 
		do_something.emit(0)
		$AnimationControls/PlayPause.text = "Pause"
	else:
		$AnimationControls/PlayPause.text = "Play"

func _on_next_pressed() -> void:
	do_something.emit(1)

func _on_back_pressed() -> void:
	do_something.emit(-1)
