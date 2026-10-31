extends Button

var graph_environment_3d = "res://assets/3d_environment/3d_env.tscn"


func _ready():
	pass


func _process(_delta):
	pass


func _on_pressed():
	get_tree().change_scene_to_file(graph_environment_3d)
