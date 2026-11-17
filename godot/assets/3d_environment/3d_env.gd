extends Node

@export var linedrawer: PackedScene

const title_screen = "res://assets/title_screen/title_screen.tscn"
var ld = null

const DEFAULT_SPEED_LEVEL = 3
const ld_speed_settings = [0.25, 0.5, 0.75, 1.0, 1.5, 2.0, 4.0, 8.0, 16.0, 32.0, 64.0]
var ld_speed_level = DEFAULT_SPEED_LEVEL


func init_line_drawer():
	const LD_DELAY = 0.05
	ld = linedrawer.instantiate()
	ld.init(LD_DELAY / ld_speed_settings[ld_speed_level])
	add_child(ld)


func update_anim_speed_button():
	$OptionsPanel/AnimSpeedButton.text = "Animation Speed: %.2f" % ld_speed_settings[ld_speed_level]


# Called when the node enters the scene tree for the first time.
func _ready():
	update_anim_speed_button()
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


func _on_anim_speed_button_pressed():
	ld_speed_level = DEFAULT_SPEED_LEVEL
	update_anim_speed_button()


func _on_left_speed_button_pressed():
	ld_speed_level = max(0, ld_speed_level - 1)
	update_anim_speed_button()


func _on_right_speed_button_pressed():
	ld_speed_level = min(len(ld_speed_settings) - 1, ld_speed_level + 1)
	update_anim_speed_button()
