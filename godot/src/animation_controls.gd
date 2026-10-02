extends Container


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Back.position = Vector2(5, 5)
	$PlayPause.position = Vector2($Back.size.x + 5, 5)
	$Next.position = Vector2($Back.size.x + $PlayPause.size.x + 5, 5)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
