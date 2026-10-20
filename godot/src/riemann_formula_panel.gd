class_name RiemannFormulaPanel
extends PanelContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _clamp_to_viewport() -> void:
	var panel_size: Vector2 = size.max(get_combined_minimum_size())
	var limit: Vector2 = (get_viewport_rect().size - panel_size).max(Vector2.ZERO)
	global_position = global_position.clamp(Vector2.ZERO, limit)
