## input_panel.gd
## GUI panel for Opticos.
##
## This node must be a child of the same parent as Animator (i.e. a sibling of
## Animator under the Control/grid node).  It reads origin and grid_spacing from
## that parent at animation-time so panning is always reflected correctly.
##
## Scene path expected:  Control (grid.gd)
##                         ├── Animator  (animator.gd)
##                         └── InputPanel  ← this script

extends Control

# ── node references ──────────────────────────────────────────────────────────

## The Animator sibling.  Resolved in _ready(); null-checked before use.
var _animator: Control = null

# ── UI node handles ───────────────────────────────────────────────────────────

var _expr_input:         LineEdit
var _type_buttons:       Array[Button] = []

var _limit_params:       Control
var _limit_value_input:  LineEdit
var _from_left_check:    CheckBox
var _from_right_check:   CheckBox

var _deriv_params:       Control
var _deriv_x_input:      LineEdit

var _integral_params:    Control
var _integral_type_opt:  OptionButton
var _integral_left_input:  LineEdit
var _integral_right_input: LineEdit

var _animate_btn:        Button
var _error_label:        Label

# ── state ─────────────────────────────────────────────────────────────────────

enum AnimType { LIMIT, DERIVATIVE, INTEGRAL }
var _current_type: AnimType = AnimType.LIMIT

const _PANEL_WIDTH:  int = 300
const _PANEL_MARGIN: int = 12

# ── lifecycle ─────────────────────────────────────────────────────────────────

func _ready() -> void:
	# Resolve sibling Animator node.
	_animator = get_parent().get_node_or_null("Animator")
	if _animator == null:
		push_error("InputPanel: could not find sibling node 'Animator'. " +
				   "Make sure InputPanel is a child of the same node as Animator.")

	# Anchor to top-left and set a fixed width; height expands with content.
	set_anchors_preset(Control.PRESET_TOP_LEFT)
	position = Vector2(_PANEL_MARGIN, _PANEL_MARGIN)
	size     = Vector2(_PANEL_WIDTH, 0)

	_build_ui()
	_show_params_for(AnimType.LIMIT)

# ── UI construction ───────────────────────────────────────────────────────────

func _build_ui() -> void:
	# Root: PanelContainer gives the translucent background and border.
	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left",   12)
	margin.add_theme_constant_override("margin_right",  12)
	margin.add_theme_constant_override("margin_top",    12)
	margin.add_theme_constant_override("margin_bottom", 12)
	panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	margin.add_child(vbox)

	# ── Title ────────────────────────────────────────────────────────────────
	var title := Label.new()
	title.text = "Opticos"
	title.add_theme_font_size_override("font_size", 18)
	vbox.add_child(title)
	vbox.add_child(_make_separator())

	# ── Expression input ─────────────────────────────────────────────────────
	var expr_row := HBoxContainer.new()
	expr_row.add_theme_constant_override("separation", 6)
	vbox.add_child(expr_row)

	var expr_lbl := Label.new()
	expr_lbl.text = "f(x) ="
	expr_row.add_child(expr_lbl)

	_expr_input = LineEdit.new()
	_expr_input.placeholder_text = "e.g.  x^2 + 2*x"
	_expr_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	# Allow pressing Enter to trigger animation.
	_expr_input.text_submitted.connect(func(_t): _on_animate_pressed())
	expr_row.add_child(_expr_input)

	vbox.add_child(_make_separator())

	# ── Visualization type ───────────────────────────────────────────────────
	var type_lbl := Label.new()
	type_lbl.text = "Visualization type:"
	vbox.add_child(type_lbl)

	var type_row := HBoxContainer.new()
	type_row.add_theme_constant_override("separation", 4)
	vbox.add_child(type_row)

	var type_names := ["Limit", "Derivative", "Integral"]
	for i in type_names.size():
		var btn := Button.new()
		btn.text          = type_names[i]
		btn.toggle_mode   = true
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.pressed.connect(_on_type_pressed.bind(i))
		type_row.add_child(btn)
		_type_buttons.append(btn)
	_type_buttons[0].button_pressed = true

	vbox.add_child(_make_separator())

	# ── Parameter panels ─────────────────────────────────────────────────────
	_limit_params    = _build_limit_params()
	_deriv_params    = _build_deriv_params()
	_integral_params = _build_integral_params()
	vbox.add_child(_limit_params)
	vbox.add_child(_deriv_params)
	vbox.add_child(_integral_params)

	vbox.add_child(_make_separator())

	# ── Animate button ───────────────────────────────────────────────────────
	_animate_btn = Button.new()
	_animate_btn.text = "▶   Animate"
	_animate_btn.pressed.connect(_on_animate_pressed)
	vbox.add_child(_animate_btn)

	# ── Error label ──────────────────────────────────────────────────────────
	_error_label = Label.new()
	_error_label.add_theme_color_override("font_color", Color(1.0, 0.35, 0.35))
	_error_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_error_label.visible = false
	vbox.add_child(_error_label)


func _build_limit_params() -> Control:
	var c := VBoxContainer.new()
	c.add_theme_constant_override("separation", 6)

	var hdr := Label.new()
	hdr.text = "Limit parameters:"
	c.add_child(hdr)

	var row1 := HBoxContainer.new()
	row1.add_theme_constant_override("separation", 6)
	c.add_child(row1)
	var lbl1 := Label.new()
	lbl1.text = "x approaches:"
	row1.add_child(lbl1)
	_limit_value_input = LineEdit.new()
	_limit_value_input.placeholder_text = "e.g.  2.0"
	_limit_value_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row1.add_child(_limit_value_input)

	var row2 := HBoxContainer.new()
	row2.add_theme_constant_override("separation", 12)
	c.add_child(row2)
	_from_left_check = CheckBox.new()
	_from_left_check.text = "From left"
	_from_left_check.button_pressed = true
	row2.add_child(_from_left_check)
	_from_right_check = CheckBox.new()
	_from_right_check.text = "From right"
	_from_right_check.button_pressed = true
	row2.add_child(_from_right_check)

	return c


func _build_deriv_params() -> Control:
	var c := VBoxContainer.new()
	c.add_theme_constant_override("separation", 6)

	var hdr := Label.new()
	hdr.text = "Derivative parameters:"
	c.add_child(hdr)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	c.add_child(row)
	var lbl := Label.new()
	lbl.text = "At x ="
	row.add_child(lbl)
	_deriv_x_input = LineEdit.new()
	_deriv_x_input.placeholder_text = "e.g.  1.0"
	_deriv_x_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(_deriv_x_input)

	return c


func _build_integral_params() -> Control:
	var c := VBoxContainer.new()
	c.add_theme_constant_override("separation", 6)

	var hdr := Label.new()
	hdr.text = "Integral parameters:"
	c.add_child(hdr)

	var type_row := HBoxContainer.new()
	type_row.add_theme_constant_override("separation", 6)
	c.add_child(type_row)
	var type_lbl := Label.new()
	type_lbl.text = "Riemann sum:"
	type_row.add_child(type_lbl)
	_integral_type_opt = OptionButton.new()
	_integral_type_opt.add_item("Left")
	_integral_type_opt.add_item("Right")
	_integral_type_opt.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	type_row.add_child(_integral_type_opt)

	var bounds_row := HBoxContainer.new()
	bounds_row.add_theme_constant_override("separation", 4)
	c.add_child(bounds_row)
	var from_lbl := Label.new()
	from_lbl.text = "From:"
	bounds_row.add_child(from_lbl)
	_integral_left_input = LineEdit.new()
	_integral_left_input.placeholder_text = "a"
	_integral_left_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bounds_row.add_child(_integral_left_input)
	var to_lbl := Label.new()
	to_lbl.text = "  To:"
	bounds_row.add_child(to_lbl)
	_integral_right_input = LineEdit.new()
	_integral_right_input.placeholder_text = "b"
	_integral_right_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bounds_row.add_child(_integral_right_input)

	return c


func _make_separator() -> HSeparator:
	return HSeparator.new()

# ── event handlers ────────────────────────────────────────────────────────────

func _on_type_pressed(index: int) -> void:
	_current_type = index as AnimType
	# Keep exactly the pressed button toggled on; release the others.
	for i in _type_buttons.size():
		_type_buttons[i].button_pressed = (i == index)
	_show_params_for(_current_type)
	_clear_error()


func _on_animate_pressed() -> void:
	_clear_error()

	# ── guard: animator must exist ────────────────────────────────────────────
	if _animator == null:
		_show_error("Animator node not found. Check scene structure.")
		return

	# ── guard: no animation already running ───────────────────────────────────
	if _animator.animating:
		_show_error("An animation is already in progress.")
		return

	# ── validate expression ───────────────────────────────────────────────────
	var expr: String = _expr_input.text.strip_edges()
	if expr.is_empty():
		_show_error("Please enter an expression.")
		return

	# Quick sanity-check: evaluate at x = 1.  GiNaC will crash Godot on a
	# parse error, so we rely on the user writing valid syntax.  A future
	# improvement would be a C++-side try/catch exposed via GDExtension.
	var probe: float = GiNaC.evaluate(expr, 1.0)
	if is_nan(probe) or is_inf(probe):
		push_warning("InputPanel: f(1) is NaN/Inf — the expression may be " +
					 "undefined at some points, but animation will proceed.")

	# ── validate type-specific fields ─────────────────────────────────────────
	match _current_type:
		AnimType.LIMIT:
			var txt: String = _limit_value_input.text.strip_edges()
			if txt.is_empty():
				_show_error("Enter the x value that the limit approaches.")
				return
			if not txt.is_valid_float():
				_show_error("Limit value must be a number (e.g. 2.0).")
				return
			if not _from_left_check.button_pressed and not _from_right_check.button_pressed:
				_show_error("Select at least one approach direction.")
				return

		AnimType.DERIVATIVE:
			var txt: String = _deriv_x_input.text.strip_edges()
			if txt.is_empty():
				_show_error("Enter the x value at which to show the derivative.")
				return
			if not txt.is_valid_float():
				_show_error("x value must be a number (e.g. 1.0).")
				return

		AnimType.INTEGRAL:
			var ltxt: String = _integral_left_input.text.strip_edges()
			var rtxt: String = _integral_right_input.text.strip_edges()
			if ltxt.is_empty() or rtxt.is_empty():
				_show_error("Enter both integration bounds.")
				return
			if not ltxt.is_valid_float() or not rtxt.is_valid_float():
				_show_error("Bounds must be numbers (e.g. -2.0, 3.0).")
				return
			if float(rtxt) <= float(ltxt):
				_show_error("Right bound must be greater than left bound.")
				return

	# ── build function data and kick off animation ────────────────────────────
	var data: Dictionary = _build_function_data(expr)
	if data.is_empty():
		# Error message already set inside _build_function_data.
		return

	_animator.prepare_to_animate(
		data["function_values"],
		data["origin"],
		data["grid_spacing"],
		data["function_lines"]
	)

	match _current_type:
		AnimType.LIMIT:
			var limit_val: float   = float(_limit_value_input.text)
			var from_left: bool    = _from_left_check.button_pressed
			var from_right: bool   = _from_right_check.button_pressed
			_animator.animate_Limit(
				limit_val,
				data["function_values"],
				from_left, from_right,
				0.05,   # initial seconds-per-step
				0.985   # slow-down factor per step
			)

		AnimType.DERIVATIVE:
			_animator.animate_derivative(float(_deriv_x_input.text))

		AnimType.INTEGRAL:
			var int_type: String = "LEFT" if _integral_type_opt.selected == 0 else "RIGHT"
			var left_bound: float  = float(_integral_left_input.text)
			var right_bound: float = float(_integral_right_input.text)
			_animator.animate_Integral(int_type, left_bound, right_bound)

# ── helpers ───────────────────────────────────────────────────────────────────

## Samples the expression across every pixel column and returns:
##   function_values  – Array[Vector2] in Godot screen-space, indexed by pixel x.
##   function_lines   – Array[Array] of [Vector2, Vector2] line segments.
##   origin           – Vector2 read from the grid node.
##   grid_spacing     – int read from the grid node.
##
## Returns an empty Dictionary on error (error message is set before returning).
func _build_function_data(expr: String) -> Dictionary:
	var grid_node: Node = get_parent()

	# Read grid state from the parent (grid.gd).  Both variables are declared
	# as public `var` in grid.gd so they are accessible directly.
	if not "origin" in grid_node or not "grid_spacing" in grid_node:
		_show_error("Could not read 'origin' / 'grid_spacing' from the grid node. " +
					"Check that grid.gd exposes these as public variables.")
		return {}

	var origin: Vector2   = grid_node.origin
	var grid_spacing: int = grid_node.grid_spacing
	var window_w: int     = DisplayServer.window_get_size().x

	var function_values: Array[Vector2] = []
	var function_lines:  Array[Array]   = []

	# One sample per pixel column.  animator.gd indexes functionValues directly
	# by pixel x, so the array must cover indices 0 … window_w + 1.
	for px in range(window_w + 2):
		# Convert pixel column → real-world x value.
		var real_coords: Vector2 = Util.convert_to_real_coords(origin, Vector2(px, 0))
		var real_x: float = real_coords.x / float(grid_spacing)

		# Evaluate f(real_x).
		var real_y: float = GiNaC.evaluate(expr, real_x)

		# Guard against NaN / Inf so we don't insert garbage into the array.
		if is_nan(real_y) or is_inf(real_y):
			# Use the previous point (or origin) as a safe fallback.
			if function_values.is_empty():
				function_values.append(Util.convert_to_godot_coords(origin, Vector2.ZERO))
			else:
				function_values.append(function_values.back())
			continue

		# Convert real-world (x, y) → Godot screen-space.
		var screen_pos: Vector2 = Util.convert_to_godot_coords(
			origin,
			Vector2(real_x * grid_spacing, real_y * grid_spacing)
		)
		function_values.append(screen_pos)

	# Build line segments from consecutive sample pairs.
	for i in range(function_values.size() - 1):
		function_lines.append([function_values[i], function_values[i + 1]])

	return {
		"function_values": function_values,
		"function_lines":  function_lines,
		"origin":          origin,
		"grid_spacing":    grid_spacing,
	}


func _show_params_for(type: AnimType) -> void:
	_limit_params.visible    = (type == AnimType.LIMIT)
	_deriv_params.visible    = (type == AnimType.DERIVATIVE)
	_integral_params.visible = (type == AnimType.INTEGRAL)


func _show_error(msg: String) -> void:
	_error_label.text    = msg
	_error_label.visible = true


func _clear_error() -> void:
	_error_label.text    = ""
	_error_label.visible = false
