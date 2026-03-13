extends Container


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Back.text = "<"
	$Next.text = ">"
	$Next.position = Vector2(200, 0)
	$PlayPause.text = "Pause"
	$PlayPause.position = Vector2(100, 0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
