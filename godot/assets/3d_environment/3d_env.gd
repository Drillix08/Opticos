extends Node

@export var linedrawer: PackedScene

var title_screen = "res://assets/title_screen/title_screen.tscn"
var ld = null


func init_line_drawer():
	ld = linedrawer.instantiate()
	add_child(ld)


# Called when the node enters the scene tree for the first time.
func _ready():
	init_line_drawer()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("OpenMenu"):
		$OptionsPanel.visible = not $OptionsPanel.visible


func _on_exit_button_pressed():
	get_tree().change_scene_to_file(title_screen)


func _on_redraw_button_pressed():
	if ld != null:
		ld.queue_free()
		init_line_drawer()
