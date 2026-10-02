extends Node

func _ready() -> void:
	print("--- GiNaC Test Suite ---")
	
	# Test expand
	print("expand (x+1)^2:         ", GiNaC.expand("(x+1)^2"))
	# Expected: x^2+2*x+1

	# Test differentiate
	print("differentiate x^3+2*x:  ", GiNaC.differentiate("x^3+2*x"))
	# Expected: 3*x^2+2

	# Test differentiate_nth (2nd derivative)
	print("2nd derivative x^3+2*x: ", GiNaC.differentiate_nth("x^3+2*x", 2))
	# Expected: 6*x

	# Test integrate
	print("integrate x^2:          ", GiNaC.integrate("x^2"))
	# Expected: x^3/3 (or equivalent)

	# Test integrate_definite
	print("integral x^2 from 0->3: ", GiNaC.integrate_definite("x^2", 0.0, 3.0))
	# Expected: 9.0

	# Test evaluate
	print("evaluate x^2 at x=4:    ", GiNaC.evaluate("x^2", 4.0))
	# Expected: 16.0

	# Test limit
	print("limit 1 / (x - 2)^2 as x->2:      ", GiNaC.limit("1 / (x - 2)^2", 2.0))
	# Expected: 4

	print("--- Done ---")
