extends Container


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$PlayPause.position = Vector2(get_viewport_rect().size.x * 0.5 - ($PlayPause.size.x * 0.5), 12)
	$Next.position = Vector2($PlayPause.position.x - ($Next.size.x * 0.5) + ($PlayPause.size.x * 1.25), 12)
	$Back.position = Vector2($PlayPause.position.x - ($Back.size.x * 0.5) - ($PlayPause.size.x * 0.25), 12)
	$SpeedUp.position = Vector2($PlayPause.position.x - ($SpeedUp.size.x * 0.5) + ($Next.size.x * 1.5) + ($PlayPause.size.x * 1.25), 12)
	$SlowDown.position = Vector2($PlayPause.position.x - ($SlowDown.size.x * 0.5) - ($Back.size.x * 1.5) - ($PlayPause.size.x * 0.25), 12)
	
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
