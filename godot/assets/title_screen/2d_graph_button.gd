extends Button

var graph_environment_2d = "res://assets/graph_environment/graph_environment.tscn"


func _ready():
	pass


func _process(delta):
	pass


func _on_pressed():
	get_tree().change_scene_to_file(graph_environment_2d)
