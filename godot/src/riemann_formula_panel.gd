class_name RiemannFormulaPanel
extends PanelContainer

const SCREEN_MARGIN: float = 12.0

@export var font_size: float = 24.0
@export var text_color := Color.WHITE

var _latexture_script: Script
var _placed: bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


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
		position = Vector2(get_viewport_rect().size.x - min_size.x - SCREEN_MARGIN, SCREEN_MARGIN)
		_placed = true
	_clamp_to_viewport()


func _clamp_to_viewport() -> void:
	var panel_size: Vector2 = size.max(get_combined_minimum_size())
	var limit: Vector2 = (get_viewport_rect().size - panel_size).max(Vector2.ZERO)
	global_position = global_position.clamp(Vector2.ZERO, limit)
