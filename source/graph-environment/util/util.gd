class_name util extends Node
	
## Takes Vector2 of mathematical coordinates and origin offset, returns Vector2 of system coordinates for plotting
static func sys_to_math(sysCoords: Vector2, origin: Vector2) -> Vector2:
	var windowSize :Vector2i = DisplayServer.window_get_size()
	var x = sysCoords.x - origin.x - windowSize.x/2.0
	var y = -(sysCoords.y - origin.y - windowSize.y/2.0)
	return Vector2(x, y)
	
## Takes Vector2 of mathematical coordinates and origin offset, returns Vector2 of system coordinates for plotting
static func math_to_sys(mathCoords: Vector2, origin: Vector2) -> Vector2:
	var windowSize :Vector2i = DisplayServer.window_get_size()
	var x = mathCoords.x + origin.x + windowSize.x/2.0
	var y = -mathCoords.y + origin.y + windowSize.y/2.0
	return Vector2(x, y)
