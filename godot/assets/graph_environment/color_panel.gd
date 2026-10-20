extends Control


var panel;
var vbox;


# Called when the node enters the scene tree for the first time.
func _ready() -> void:	
	panel = PanelContainer.new()
	
	panel.size = Vector2(150, 0)
	panel.position = Vector2(get_viewport_rect().size.x * 0.98 - panel.size.x, 12)
	
	add_child(panel)
	
	vbox = VBoxContainer.new()
	panel.add_child(vbox)
	
	_build_grid_color_picker()
	_build_tick_color_picker()
	_build_axis_color_picker()
	_build_function_color_picker()
	_build_line_color_picker()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _build_grid_color_picker() -> void:
	var label := Label.new()
	label.text = "Grid Color"
	vbox.add_child(label)
	
	var picker := ColorPickerButton.new()
	picker.custom_minimum_size = Vector2(150, 30)
	vbox.add_child(picker)
	picker.color_changed.connect(_on_grid_color_changed)


func _on_grid_color_changed(color: Color) -> void:
	var grid = get_parent()
	grid.gridColor = color
	grid.queue_redraw()


func _build_tick_color_picker() -> void:
	var label := Label.new()
	label.text = "Tick Color"
	vbox.add_child(label)
	
	var picker := ColorPickerButton.new()
	picker.custom_minimum_size = Vector2(150, 30)
	vbox.add_child(picker)
	picker.color_changed.connect(_on_tick_color_changed)


func _on_tick_color_changed(color: Color) -> void:
	var grid = get_parent()
	grid.tickColor = color
	grid.queue_redraw()


func _build_axis_color_picker() -> void:
	var label := Label.new()
	label.text = "Axis Color"
	vbox.add_child(label)
	
	var picker := ColorPickerButton.new()
	picker.custom_minimum_size = Vector2(150, 30)
	vbox.add_child(picker)
	picker.color_changed.connect(_on_axis_color_changed)


func _on_axis_color_changed(color: Color) -> void:
	var grid = get_parent()
	grid.axisColor = color
	grid.queue_redraw()


func _build_function_color_picker() -> void:
	var label := Label.new()
	label.text = "Function Color"
	vbox.add_child(label)
	
	var picker := ColorPickerButton.new()
	picker.custom_minimum_size = Vector2(150, 30)
	vbox.add_child(picker)
	picker.color_changed.connect(_on_function_color_changed)


func _on_function_color_changed(color: Color) -> void:
	var animator = get_parent().get_node("Animator")
	animator.functionColor = color
	animator.queue_redraw()

func _build_line_color_picker() -> void:
	var label := Label.new()
	label.text = "Line Color"
	vbox.add_child(label)
	
	var picker := ColorPickerButton.new()
	picker.custom_minimum_size = Vector2(150, 30)
	vbox.add_child(picker)
	picker.color_changed.connect(_on_line_color_changed)


func _on_line_color_changed(color: Color) -> void:
	var animator = get_parent().get_node("Animator")
	animator.lineColor = color
	animator.queue_redraw()
