class_name RiemannFormulaPanel
extends PanelContainer

const LATEXTURE_PATH: String = "res://addons/godotex/LaTeXture.cs"
const SUMMAND: String = r"f(a + k \cdot \Delta x) \cdot \Delta x"

@export var font_size: float = 24.0
@export var text_color := Color.WHITE

var _latexture_script: Script
var _riemann_formula_rect: TextureRect
var _subinterval_width_rect: TextureRect
var _definite_integral_definition: String = ""
var _infinitesimal_width: String = ""
var _placed: bool = false
var _dragging: bool = false
var _drag_offset := Vector2.ZERO


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_latexture_script = load(LATEXTURE_PATH)
	assert(_latexture_script != null)

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.1, 0.1, 0.95)
	style.set_corner_radius_all(8)
	style.set_border_width_all(1)
	style.border_color = Color(1, 1, 1, 0.25)
	add_theme_stylebox_override("panel", style)

	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_default_cursor_shape = Control.CURSOR_MOVE

	var margin := MarginContainer.new()
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, Util.PANEL_PADDING)
	add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_theme_constant_override("separation", Util.PANEL_ROW_SEPARATION)
	margin.add_child(vbox)

	_riemann_formula_rect = _make_latex_rect()
	vbox.add_child(_riemann_formula_rect)
	_subinterval_width_rect = _make_latex_rect()
	vbox.add_child(_subinterval_width_rect)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		_dragging = event.pressed
		_drag_offset = get_global_mouse_position() - global_position
		accept_event()
	elif event is InputEventMouseMotion and _dragging:
		global_position = get_global_mouse_position() - _drag_offset
		_clamp_to_viewport()
		accept_event()


func show_riemann(n: int, delta_x: float, riemann_sum: float, is_right: bool, is_final: bool) -> void:
	# Left Riemann sum: k = 0 .. n-1 samples the left edges
	# Right Riemann sum: k = 1 .. n samples the right edges
	var k_start: int = 1 if is_right else 0
	var k_end: int = n if is_right else n - 1

	var riemann_formula: String
	var subinterval_width: String
	
	if is_final:
		var upper: String = "n" if is_right else "n - 1"
		riemann_formula = r"\int_{a}^{b} f(x)\,dx = \lim_{n \rightarrow \infty} \sum_{k = %d}^{%s} %s" % [k_start, upper, SUMMAND]
		subinterval_width = r"\Delta x = dx"
	else:
		riemann_formula = r"A = \sum_{k = %d}^{%d} %s = %.3f" % [k_start, k_end, SUMMAND, riemann_sum]
		subinterval_width = r"\Delta x = \frac{b - a}{%d} = %.3f" % [n, delta_x]

	_set_latex(_riemann_formula_rect, riemann_formula, _definite_integral_definition)
	_set_latex(_subinterval_width_rect, subinterval_width, _infinitesimal_width)
	_definite_integral_definition = riemann_formula
	_infinitesimal_width = subinterval_width

	_refit()


func _make_latex_rect() -> TextureRect:
	var rect := TextureRect.new()
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.stretch_mode = TextureRect.STRETCH_KEEP
	return rect


func _set_latex(rect: TextureRect, latex: String, previous: String) -> void:
	if latex == previous and rect.texture != null:
		 # nothing changed, skip the (relatively slow) re-render
		return

	if _latexture_script == null:
		return

	var renderer = _latexture_script.new()
	renderer.LatexExpression = latex
	renderer.FontSize = font_size
	renderer.MathColor = text_color

	rect.texture = renderer.Render()


func _refit() -> void:
	reset_size()
	if not _placed:
		var min_size: Vector2 = get_combined_minimum_size()
		position = Vector2(get_viewport_rect().size.x - min_size.x - Util.PANEL_SCREEN_MARGIN, Util.PANEL_SCREEN_MARGIN)
		_placed = true
	_clamp_to_viewport()


func _clamp_to_viewport() -> void:
	var panel_size: Vector2 = size.max(get_combined_minimum_size())
	var limit: Vector2 = (get_viewport_rect().size - panel_size).max(Vector2.ZERO)
	global_position = global_position.clamp(Vector2.ZERO, limit)
