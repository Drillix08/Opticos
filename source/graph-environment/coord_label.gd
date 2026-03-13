class_name CoordLabel extends Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_theme_color_override("gray", Color.DIM_GRAY)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if (position.x < 0):
		position.x = 0
	if (position.y < 0):
		position.y = 0
	if (position.y + size.y > DisplayServer.window_get_size().y):
		position.y = DisplayServer.window_get_size().y - size.y
	if (position.x + size.x > DisplayServer.window_get_size().x):
		position.x = DisplayServer.window_get_size().x - size.x
