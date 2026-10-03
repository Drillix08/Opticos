extends Node

var _math: MathCoreWrapper = MathCoreWrapper.new()

func _exit_tree() -> void:
	_math.free()

func evaluate_with_vars(expr: String, vars: Dictionary[String, float]) -> float:
	return _math.evaluate_with_vars(expr, vars)
