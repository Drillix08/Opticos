extends Node

var _node: GiNaCNode

func _ready() -> void:
	_node = GiNaCNode.new()
	add_child(_node)

# Expands an expression e.g. "(x+1)^2" -> "x^2+2*x+1"
func expand(expr: String) -> String:
	return _node.expand(expr)

# First derivative with respect to x
func differentiate(expr: String) -> String:
	return _node.differentiate(expr)

# nth derivative with respect to x
func differentiate_nth(expr: String, n: int) -> String:
	return _node.differentiate_nth(expr, n)

# Indefinite integral with respect to x
func integrate(expr: String) -> String:
	return _node.integrate(expr)

# Definite integral from a to b
func integrate_definite(expr: String, a: float, b: float) -> float:
	return _node.integrate_definite(expr, a, b)

# Evaluate y = f(x) at a given x value
func evaluate(expr: String, value: float) -> float:
	return _node.evaluate(expr, value)

# Limit as x approaches a value
func limit(expr: String, value: float) -> String:
	return _node.limit(expr, value)
